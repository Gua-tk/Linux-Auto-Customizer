
CC = gcc
CFLAGS = -O3 -Wall

all : c_script

c_script : c_script.c
	$(CC) $(CFLAGS) c_script.c -o c_script -lm

run : c_script
	./c_script

.PHONY : clean
clean :
	rm -f c_script
