// train Tiny DNN to classify chest xray images

#include <iostream>
#include <vector>

// includes for image parsing
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <boost/foreach.hpp>
#include <boost/filesystem.hpp>

#include "tiny_dnn/tiny_dnn.h"
#include "csv.h" // csv parsing

using namespace boost::filesystem;

void randomize_csv(std::string csv_path)
{

}

tiny_dnn::vec_t str_to_labels(std::string label_str)
{     
    tiny_dnn::vec_t label_set(15, 0.0);
    std::stringstream str_stream(label_str);
    std::string tmp_str;
    std::map<std::string, double> classif_table {
        {"No Finding",          0},
        {"Atelectasis",         1},
        {"Cardiomegaly",        2},
        {"Consolidation",       3},
        {"Edema",               4},
        {"Effusion",            5},
        {"Emphysema",           6},
        {"Fibrosis",            7},
        {"Hernia",              8},
        {"Infiltration",        9},
        {"Mass",               10},
        {"Nodule",             11},
        {"Pleural_Thickening", 12},
        {"Pneumonia",          13},
        {"Pneumothorax",       14}
    };

    while (getline(str_stream, tmp_str, '|')) { 
        if (classif_table.find(tmp_str) == classif_table.end()) {
            std::cerr << "Find Error: Label "
                      << tmp_str
                      << " has no classification"
                      << std::endl;
        } else {
            label_set[classif_table[tmp_str]] = 1;
        }
    }
    //std::sort(label_set.begin(), label_set.end());
    return label_set;
}

// convert image from filename into a vector for processing
void convert_image(const std::string& imagefilename,
                   double scale,
                   int w,
                   int h,
                   std::vector<tiny_dnn::vec_t>& data)
{
    auto img = cv::imread(imagefilename, cv::IMREAD_GRAYSCALE);
    if (img.data == nullptr) return; // cannot open, or it's not an image

    cv::Mat_<uint8_t> resized;
    cv::resize(img, resized, cv::Size(w, h));
    tiny_dnn::vec_t d;

    std::transform(resized.begin(), resized.end(), std::back_inserter(d),
                   [=](uint8_t c) { return c * scale; });
    
    data.push_back(d);
}

void parse_csv_data(const std::string directory,
                    const std::string csv_path,
                    std::vector<tiny_dnn::vec_t> *training_images,
                    std::vector<tiny_dnn::vec_t> *training_labels,
                    std::vector<tiny_dnn::vec_t> *testing_images,
                    std::vector<tiny_dnn::vec_t> *testing_labels)
{
    io::CSVReader<2> label_csv(csv_path);
    label_csv.read_header(io::ignore_extra_column,
                          "Image Index",
                          "Finding Labels");
    std::string filename;
    std::string classif_str;
    std::string img_path;
    int i = 0; // counter for saving every 10th image for testing

    while (label_csv.read_row(filename, classif_str)) {
        img_path = directory + "/" + filename;
        if (i == 0) { // save for testing
            convert_image(img_path, 1, 128, 128,
                          *testing_images);
            testing_labels->push_back(str_to_labels(classif_str));
        } else { // use for training
            convert_image(img_path, 1, 128, 128,
                          *training_images);
            training_labels->push_back(str_to_labels(classif_str));
        }
        std::cout << "converting image " << filename << "\r";
        i = (i + 1) % 10;
    }
    std::cout << std::endl;
}

static void construct_net(tiny_dnn::network<tiny_dnn::sequential> &nn,
                          tiny_dnn::core::backend_t backend_type)
{
    // connection table [Y.Lecun, 1998 Table.1]
    #define O true
    #define X false
    // clang-format off
    // 6 rows x 16 cols?
    static const bool tbl[] = {
        O, X, X, X, O, O, O, X, X, O, O, O, O, X, O, O,
        O, O, X, X, X, O, O, O, X, X, O, O, O, O, X, O,
        O, O, O, X, X, X, O, O, O, X, X, O, X, O, O, O,
        X, O, O, O, X, X, O, O, O, O, X, X, O, X, O, O,
        X, X, O, O, O, X, X, O, O, O, O, X, O, O, X, O,
        X, X, X, O, O, O, X, X, O, O, O, O, X, O, O, O
    };
    // clang-format on
    #undef O
    #undef X

    // construct nets
    //
    // C : convolution
    // S : sub-sampling
    // F : fully connected
    // clang-format off
    using fc = tiny_dnn::layers::fc;
    using conv = tiny_dnn::layers::conv;
    using ave_pool = tiny_dnn::layers::ave_pool;
    using relu = tiny_dnn::activation::relu;

    using tiny_dnn::core::connection_table;
    using padding = tiny_dnn::padding;

    nn << conv(128, 128, 5, 1, 6,   // C1, 1@128x128-in, 6@124x124-out
               padding::valid, true, 1, 1, 1, 1, backend_type)
       << relu()
       << ave_pool(124, 124, 6, 2)   // S2, 6@124x124-in, 6@62x62-out
       << relu()
       << conv(62, 62, 5, 6, 16,   // C3, 6@62x62-in, 16@58x58-out
               connection_table(tbl, 6, 16),
               padding::valid, true, 1, 1, 1, 1, backend_type)
       << relu()
       << ave_pool(58, 58, 16, 2)  // S4, 16@58x58-in, 16@29x29-out
       << relu()
       << conv(29, 29, 5, 16, 2,   // C5, 16@29x29-in, 1250@1x1-out
               padding::valid, true, 1, 1, 1, 1, backend_type)
       << relu()
       << fc(1250, 15, true, backend_type)  // F6, 1250-in, 15-out
       << relu();
}

static void train_lenet(const std::string &data_dir_path,
                        double learning_rate,
                        const int n_train_epochs,
                        const int n_minibatch,
                        tiny_dnn::core::backend_t backend_type)
{
    // specify loss-function and learning strategy
    tiny_dnn::network<tiny_dnn::sequential> nn;
    tiny_dnn::adagrad optimizer;

    construct_net(nn, backend_type);

    std::cout << "load models..." << std::endl;

    // load MNIST dataset
    std::vector<tiny_dnn::vec_t> train_labels, test_labels;
    std::vector<tiny_dnn::vec_t> train_images, test_images;

    parse_csv_data(data_dir_path,
                   data_dir_path + "/../" + "sample_labels.csv",
                   &train_images,
                   &train_labels,
                   &test_images,
                   &test_labels);

    std::cout << "start training" << std::endl;

    tiny_dnn::progress_display disp(train_images.size());
    tiny_dnn::timer t;

    optimizer.alpha *=
    std::min(tiny_dnn::float_t(4),
             static_cast<tiny_dnn::float_t>(sqrt(n_minibatch) * learning_rate));

    int epoch = 1;
    // create callback

    auto on_enumerate_epoch = [&]() {
        std::cout << std::endl << "Epoch " << epoch << "/" << n_train_epochs << " finished. "
                  << t.elapsed() << "s elapsed." << std::endl;
        ++epoch;

        // show loss (can't figure out how to show accuracy)
        std::cout << "Loss: "
                  << nn.get_loss<tiny_dnn::mse>(test_images, test_labels) // causing runtime error
                  << std::endl;

        disp.restart(train_images.size());
        t.restart();
    };

    auto on_enumerate_minibatch = [&]() { disp += n_minibatch; };

    // train (using fit for vec_t classification opposed tovtrain for label_t)
    nn.fit<tiny_dnn::mse>(optimizer, train_images, train_labels, n_minibatch,
                          n_train_epochs, on_enumerate_minibatch,
                          on_enumerate_epoch);

    std::cout << "end training." << std::endl;

    // test and show resulting loss (can't figure out how to show accuracy)
    std::cout << "Loss: "
              << nn.get_loss<tiny_dnn::mse>(test_images, test_labels)
              << std::endl;
    
    // save network model & trained weights
    nn.save("xray-diagnosis-model");
}

static tiny_dnn::core::backend_t parse_backend_name(const std::string &name)
{
    const std::array<const std::string, 5> names = {{
    "internal", "nnpack", "libdnn", "avx", "opencl",
    }};
    
    for (size_t i = 0; i < names.size(); ++i) {
        if (name.compare(names[i]) == 0) {
            return static_cast<tiny_dnn::core::backend_t>(i);
        }
    }
    
    return tiny_dnn::core::default_engine();
}

static void usage(const char *argv0)
{
    std::cout << "Usage: " << argv0 << " --data_path path_to_dataset_folder"
              << " --learning_rate 1"
              << " --epochs 10"
              << " --minibatch_size 16"
              << " --backend_type internal" << std::endl;
}

int main(int argc, char **argv)
{
    double learning_rate                   = 1;
    int epochs                             = 10;
    std::string data_path                  = "";
    int minibatch_size                     = 16;
    tiny_dnn::core::backend_t backend_type = tiny_dnn::core::default_engine();

    if (argc == 2) {
        std::string argname(argv[1]);
        if (argname == "--help" || argname == "-h") {
            usage(argv[0]);
            return 0;
        }
    }
    for (int count = 1; count + 1 < argc; count += 2) {
        std::string argname(argv[count]);
        if (argname == "--learning_rate") {
            learning_rate = atof(argv[count + 1]);
        } else if (argname == "--epochs") {
            epochs = atoi(argv[count + 1]);
        } else if (argname == "--minibatch_size") {
            minibatch_size = atoi(argv[count + 1]);
        } else if (argname == "--backend_type") {
            backend_type = parse_backend_name(argv[count + 1]);
        } else if (argname == "--data_path") {
            data_path = std::string(argv[count + 1]);
        } else {
            std::cerr << "Invalid parameter specified - \"" << argname << "\""
                      << std::endl;
            usage(argv[0]);
            return -1;
        }
    }
    if (data_path == "") {
        std::cerr << "Data path not specified." << std::endl;
        usage(argv[0]);
        return -1;
    }
    if (learning_rate <= 0) {
        std::cerr
        << "Invalid learning rate. The learning rate must be greater than 0."
        << std::endl;
        return -1;
    }
    if (epochs <= 0) {
        std::cerr << "Invalid number of epochs. The number of epochs must be "
                     "greater than 0."
                  << std::endl;
        return -1;
    }
    if (minibatch_size <= 0 || minibatch_size > 60000) {
        std::cerr
        << "Invalid minibatch size. The minibatch size must be greater than 0"
           " and less than dataset size (60000)."
        << std::endl;
    return -1;
    }
    std::cout << "Running with the following parameters:" << std::endl
              << "Data path: " << data_path << std::endl
              << "Learning rate: " << learning_rate << std::endl
              << "Minibatch size: " << minibatch_size << std::endl
              << "Number of epochs: " << epochs << std::endl
              << "Backend type: " << backend_type << std::endl
              << std::endl;
    try {
        train_lenet(data_path, learning_rate, epochs,
                    minibatch_size, backend_type);
    } catch (tiny_dnn::nn_error &err) {
        std::cerr << "Exception: " << err.what() << std::endl;
    }
    return 0;
}
