BUILD := build

all:
	mkdir -p $(BUILD)
	gcc -Wall -O2 -o $(BUILD)/q1-vector q1-vector.c
	gcc -Wall -O2 -o $(BUILD)/q1-uf8 problem_B/q1-uf8.c
	gcc -Wall -O2 -o $(BUILD)/q1-bfloat16 problem_C/q1-bfloat16.c

clean:
	rm -rf $(BUILD)