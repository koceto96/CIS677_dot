/*
 * dot.c
 * Author: Simon Rüegg
 * A "driver" program that calls a routine (i.e. a kernel)
 * that executes on the GPU. The kernel calculates the dot product of two vectors
 *
 * Note: the kernel code is found in the file 'dot.cu'
 * compile both driver code and kernel code with nvcc, as in:
 * 			nvcc dot.c dot.cu
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

// The function calcDot is in the file dot.cu
extern void calcDot(uint32_t size, unsigned long long *dotResult);

int main(int argc, char *argv[])
{
    unsigned long long dotResult;

    if(argc < 2){
        printf("Usage: dot <sizeOfVector>\n");
        exit(1);
    }

    uint32_t vectorSize = atoi(argv[1]);

    // Call the function that will call the GPU function
    calcDot(vectorSize, &dotResult);

    // print the result
    printf("Result (size %d): %lu\n", vectorSize, dotResult);

    printf("\n");

    return 0;
}
