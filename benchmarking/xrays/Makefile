CXX := g++
CXXFLAGS := -Wall -Werror

TINYDNN_PATH := ~/Documents/tiny-dnn
libs := `pkg-config opencv --libs` -lpthread -lboost_system -lboost_filesystem

make: train

train: train.cpp
	$(CXX) $(CXXFLAGS) $(libs) -I $(TINYDNN_PATH) -o $@ $^

clean:
	rm -f train
