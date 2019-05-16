CXX := g++
CXXFLAGS := -Wall

ALL := train test

TINYDNN_PATH := ~/Documents/tiny-dnn
OPENCV := `pkg-config opencv --libs`
PTHREAD := -lpthread
BOOST := -lboost_system -lboost_filesystem

make: $(ALL)

train: train.cpp
	$(CXX) $(CXXFLAGS) -I $(TINYDNN_PATH) -o $@ $^ $(PTHREAD) $(OPENCV) $(BOOST)

test: test.cpp
	$(CXX) $(CXXFLAGS) -DDNN_USE_IMAGE_API -I $(TINYDNN_PATH) -o $@ $^ $(PTHREAD) $(OPENCV) $(BOOST)

clean:
	rm -f $(ALL) *.png
