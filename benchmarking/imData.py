# imData.py
# Cameron Shinn

'''
imData.py does the following operations...
1. Takes input images
2. Resizes them
3. Converts them to grayscale
4. Outputs a .csv file containing the pixel values for each image (row major order)

imData.py takes 3 or more command line arguments
argument 1 -- pixel width that image will be resized to
argument 2 -- pixel height that image will be resized to
argument 3+ -- 1 or more paths to image files or directories that contain image files

Note: Be wary of how many input files you use. ~5000 .png files at 128x128 generated a .csv that was roughly 250MB
'''

import os, sys, glob
import csv
import PIL
from PIL import Image

FILE_TYPE = '.png'
OUTPUT_NAME = 'imageData.csv'

def processImage(imagePath, size):  # performs desired image processes
    image = PIL.Image.open(imagePath).convert('L')  # open file in grayscale
    image = image.resize(size, PIL.Image.ANTIALIAS)  # resize to input size
    return list(image.getdata())  # return list of grayscale (8-bit) pixel values in row major order

def intListToHex(intList):  # convert list values to hex to reduce csv size
    tempList = []
    for num in intList:
        tempList.append(hex(num)[2:])  # add grayscale hex value to list (without the "0x")

    return tempList


# check if size arguments are correct
if len(sys.argv) < 3 or not (sys.argv[1].isdigit() and sys.argv[2].isdigit()):
    print('Argument Error: command line arguments 1 (pixel width) and 2 (pixel height) must be integers')
    sys.exit()


# initialize variables
imageNum = 0
size = (int(sys.argv[1]), int(sys.argv[2]))  # first argument is width and second is height


# create csv file and write first line (header)
headerList = ['File Name']
for pixelY in range(size[1]):  # note that coordinate system has (0,0) as the top left corner
    for pixelX in range(size[0]):
        headerList.append('Pixel({}.{})'.format(str(pixelX), str(pixelY)))

csvFile = open(OUTPUT_NAME, 'w', newline='')
fileWriter = csv.writer(csvFile, delimiter=',', quoting=csv.QUOTE_MINIMAL)
fileWriter.writerow(headerList)


# process through images
for path in sys.argv[3:]:
    if os.path.isdir(path):  # if input string is a directory
        for file in glob.glob(os.path.join(path, '*{}'.format(FILE_TYPE))):  # for every FILE_TYPE file in directory
            imageNum += 1  # increment image number for string output
            print('\rProcessing image {}'.format(imageNum), end='')  # print string output
            hexList = intListToHex(processImage(file, size))
            hexList.insert(0,file)
            fileWriter.writerow(hexList)

    elif path.endswith(FILE_TYPE):  # if the file is of type FILE_TYPE
        imageNum += 1  # increment image number for string output
        print('\rProcessing image {}'.format(imageNum), end='')  # print string output
        hexList = intListToHex(processImage(path, size))
        hexList.insert(0, path)
        fileWriter.writerow(hexList)

print('\rDone: .csv file \'{}\' output to \"{}\"'.format(OUTPUT_NAME, os.path.dirname(os.path.abspath(__file__))))
