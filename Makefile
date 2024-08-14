all:
	gcc -m32 main.s -o main

run: all
	./main
