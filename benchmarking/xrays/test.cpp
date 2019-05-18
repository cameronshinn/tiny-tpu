/*
    Copyright (c) 2013, Taiga Nomi and the respective contributors
    All rights reserved.

    Use of this source code is governed by a BSD-style license that can be found
    in the LICENSE file.
*/
#include <iostream>

// includes for image parsing
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <boost/foreach.hpp>
#include <boost/filesystem.hpp>

#include "tiny_dnn/tiny_dnn.h"

void convert_image(const std::string& imagefilename,
                   double scale,
                   int w,
                   int h,
                   tiny_dnn::vec_t &data)
{
    auto img = cv::imread(imagefilename, cv::IMREAD_GRAYSCALE);
    if (img.data == nullptr) return; // cannot open, or it's not an image

    cv::Mat_<uint8_t> resized;
    cv::resize(img, resized, cv::Size(w, h)); 

    std::transform(resized.begin(), resized.end(), std::back_inserter(data),
                   [=](uint8_t c) { return c * scale; });

    for (unsigned int i = 0; i < 16384; i++) {
        data[i] = (data[i] / 128) - 1;
        //data[i] /= 255;
    }
}

void recognize(const std::string &dictionary, const std::string &src_filename) {
  tiny_dnn::network<tiny_dnn::sequential> nn;

  nn.load(dictionary);
  /*
  for (unsigned int i = 0; i < nn.depth(); i++) {
    auto img = nn[i]->output_to_image(); // visualize activations of recent input
    std::string file_name = "activations_layer" + std::to_string(i) + ".bmp";
    img.write(file_name);
  }
  */
  // convert imagefile to vec_t
  tiny_dnn::vec_t data;

  std::cout << "testing image:" << std::endl;

  convert_image(src_filename, 1, 128, 128, data);

  //std::cout << data.size() << std::endl;
  
  for (unsigned int j = 0; j < 10; j++) {
      std::cout << data[j*150] << ", ";
  }
  
  std::cout << std::endl;

  // recognize
  auto res = nn.predict(data);
  std::vector<std::pair<double, int>> scores;

  // sort & print top-3 (all 15 for now)
  for (int i = 0; i < 15; i++)
    scores.emplace_back(res[i], i);

  sort(scores.begin(), scores.end(), std::greater<std::pair<double, int>>());

  for (int i = 0; i < 15; i++)
    std::cout << scores[i].second << "," << scores[i].first << std::endl;

  // save outputs of each layer
  for (size_t i = 0; i < nn.depth(); i++) {
    auto out_img  = nn[i]->output_to_image();
    auto filename = "layer_" + std::to_string(i) + ".png";
    out_img.save(filename);
  }

  // save filter shape of first convolutional layer
  {
    auto weight   = nn.at<tiny_dnn::convolutional_layer>(0).weight_to_image();
    auto filename = "weights.png";
    weight.save(filename);
  }
}

int main(int argc, char **argv) {
  if (argc != 2) {
    std::cout << "please specify image file" << std::endl;
    return 0;
  }
  recognize("xray-diagnosis-model", argv[1]);
}
