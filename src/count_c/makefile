CC = gcc
CFLAGS = -lm -pthread -Ofast -march=native -funroll-loops -Wno-unused-result

all: vocab_count # cooccur

# cooccur : cooccur.c
# 	$(CC) cooccur.c -o cooccur $(CFLAGS)
vocab_count : vocab_count.c commoncore.h optparser.h
	$(CC) vocab_count.c -o vocab_count $(CFLAGS)

clean:
	rm -rf  cooccur vocab_count
