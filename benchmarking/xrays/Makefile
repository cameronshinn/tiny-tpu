CXX := g++
CXXFLAGS := -Wall -Werror

tiny-dnn-path := /home/cameron/Documents/tiny-dnn
libs := `pkg-config opencv --libs` -lpthread -lboost_system

make: train

train: 
	$(CXX) train.cpp $(libs) -I $(tiny-dnn-path) -o $@

clean:
	rm -f train
