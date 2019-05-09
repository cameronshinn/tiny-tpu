// data.cpp
// Cameron Shinn

#include "data.h"

Classif::Classif(std::string cls_str) : num_map(init_map()), nums(clsfy_str(cls_str, '|')) {}

Classif::get_nums(void) { return nums; }

Classif::init_map(void)
{
    std::map<std::string, double> num_map {
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
    }

    return num_map;
}

Classif::clsfy_str(std::string cls_str, char delim)
{
    std::vector<std::string> tokens;
    std::stringstream stream(cls_str);
    std::string str_buf;

    while (getline(stream, str_buf, delim)) {
        if (num_map.find(str_buf) == num_map.end()) { // key doesn't exist
            std::cerr << "Find Error: Label " << token_str
                      << " has no classification" << std::endl;
        } else { // key exists
            // add classification number to vector
            classif_vec[0].push_back(classif_nums[token_str]);
        }
    }
}