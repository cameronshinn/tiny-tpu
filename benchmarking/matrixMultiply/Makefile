programs := multiply.x

all: $(programs)

CC := gcc
FLAGS := -Wall -Werror -std=c99

## Optimization Flag
ifneq ($(D),1)
FLAGS += -O3
else
FLAGS += -O0 -g
endif

%.x : %.c
	@echo "CC $@"
	$(CC) $(FLAGS) -o $@ $< 

clean:
	@echo "CLEAN"
	rm -rf $(programs) core
