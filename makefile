CC=nvcc #gcc
CFLAGS= -Wno-deprecated-gpu-targets

ODIR=obj

dot: dot.c dot.cu
	$(CC) -o $@ $^ $(CFLAGS)

.PHONY: clean

clean:
	rm -f dot
	