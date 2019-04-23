# getData.py
# Cameron Shinn

'''
getData.py does the following operations...
1. Opens .csv file containing image names and labels
2. Searches for image names in specified directory
3. Resizes them
4. Converts them to grayscale
5. Outputs a .csv file containing the name, label, and pixel values for each image (row major order)

getData.py takes 4 command line arguments
argument 1 -- input csv file name
argument 2 -- paths to directory that contains image files
argument 3 -- pixel width that image will be resized to
argument 4 -- pixel height that image will be resized to

Note: Be wary of how many input files you use. ~5000 png files at 128x128 generated a csv that was roughly 250MB
'''

import os, sys, glob
import csv
import PIL
from PIL import Image

FILE_TYPE = 'png'
OUTPUT_NAME = 'image_data.csv'

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
if len(sys.argv) < 4 or not (sys.argv[3].isdigit() and sys.argv[4].isdigit()):
    print('Argument Error: command line arguments 3 (pixel width) and 4 (pixel height) must be integers')
    sys.exit()


# initialize variables
imageNum = 0
size = (int(sys.argv[3]), int(sys.argv[4]))  # first argument is width and second is height


# create csv file and write first line (header)
csvOutFile = open(OUTPUT_NAME, 'w', newline='')
fileWriter = csv.writer(csvOutFile, delimiter=',', quoting=csv.QUOTE_MINIMAL)
headerList = ['Image Index', 'Finding Labels']

for pixelY in range(size[1]):  # note that coordinate system has (0,0) as the top left corner
    for pixelX in range(size[0]):
        headerList.append('Pixel({}.{})'.format(str(pixelX), str(pixelY)))

fileWriter.writerow(headerList)


# open new csv file to read from using csvReader
csvInFile = open(sys.argv[1], 'r')
csvReader = csv.DictReader(csvInFile)
next(csvReader)

# process through images
os.chdir(sys.argv[2])
for row in csvReader:  # start reading from the second row of .csv (since first is headers)
    file = row['Image Index']
    if file in glob.glob('*.{}'.format(FILE_TYPE)):
        imageNum += 1  # increment image number for string output
        print('\rProcessing image {}'.format(imageNum), end='')  # print string output
        hexList = intListToHex(processImage(file, size))
        hexList.insert(0, file)  # insert file name at 
        hexList.insert(1, row['Finding Labels'])  # insert classification label
        fileWriter.writerow(hexList)

csvOutFile.close()
print('\rDone: csv file \'{}\' output to \"{}\"'.format(OUTPUT_NAME, os.path.dirname(os.path.abspath(__file__))))
