BUILD := build

all:
	mkdir -p $(BUILD)
	gcc -Wall -O2 -o $(BUILD)/q1-vector q1-vector.c
	gcc -Wall -O2 -o $(BUILD)/q1-uf8 q1-uf8.c
	gcc -Wall -O2 -o $(BUILD)/q1-bfloat16 q1-bfloat16.c

clean:
	rm -rf build
