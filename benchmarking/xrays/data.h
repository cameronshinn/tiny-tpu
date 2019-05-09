// data.h
// Cameron Shinn

#ifndef DATA_H
#define DATA_H

#include <string>
#include <vector>
#include <map>

class Classif
{
    public:
        Classif(std::string cls_str);
        std::vector<double> get_nums(void);

    private:
        Classif(void);
        std::vector<double> clsfy_string(std::string cls_str);
        const std::vector<double> nums;
        static const std:map<std:string, double> num_map;
};

class Image
{
    public:
    
    private:

};

#endif DATA_H
