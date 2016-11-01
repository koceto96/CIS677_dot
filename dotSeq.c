/*
 * dotSeq.c
 * Author: Simon Rüegg
 * Sequential version of dot product for two vectors
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/time.h>

int main(int argc, char *argv[])
{
    unsigned long long dotResult = 0;

    if(argc < 2){
        printf("Usage: dot <sizeOfVector>\n");
        exit(1);
    }

    uint32_t vectorSize = atoi(argv[1]);
    unsigned long long force;
    unsigned long long distance;
    uint32_t halfSize = vectorSize/2;

    // Start timing
    struct timeval tval_before, tval_after, tval_result;
    gettimeofday(&tval_before, NULL);
    for(uint32_t i=0; i<vectorSize; i++){
        force = i < halfSize ? i+1 : halfSize - (i-halfSize);
        distance = (i%10) + 1;

        force *= distance;

        dotResult += force;
    }

    // Stop timing
    gettimeofday(&tval_after, NULL);
    timersub(&tval_after, &tval_before, &tval_result);
    printf("Time elapsed: %ld.%06lds\n", (long int)tval_result.tv_sec, (long int)tval_result.tv_usec);

    // print the result
    printf("Result (size %d): %lu\n", vectorSize, dotResult);

    printf("\n");

    return 0;
}
