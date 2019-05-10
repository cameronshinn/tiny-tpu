CXX := g++
CXXFLAGS := -Wall

TINYDNN_PATH := ~/Documents/tiny-dnn
libs := `pkg-config opencv --libs` -lpthread -lboost_system -lboost_filesystem

make: train

train: train.cpp
	$(CXX) $(CXXFLAGS) -I $(TINYDNN_PATH) -o $@ $^ $(libs)

clean:
	rm -f train
