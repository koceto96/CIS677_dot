/*
 * dot.cu
 * Author: Simon Rüegg
 *
 * includes setup funtion and kernel function called from "driver" program
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/time.h>

#define BLOCK_SIZE 1024

__global__ void cu_calcDot(unsigned long long *vector_d, uint32_t vectorSize, unsigned long long *dotResult_d)
{
	uint32_t x = blockIdx.x * blockDim.x + threadIdx.x;
	if(x >= vectorSize) return;

	unsigned long long force_d = x < vectorSize/2 ? x+1 : vectorSize/2 - (x-vectorSize/2);
	unsigned long long distance_d = (x % 10) + 1;

	*dotResult_d = 0;

    // calculate products
	vector_d[x] = force_d * distance_d;
}

__global__ void cu_reduce(unsigned long long *vector_d, uint32_t vectorSize, unsigned long long *result_d)
{
	uint32_t x = blockIdx.x * blockDim.x + threadIdx.x;
	
	if(x >= vectorSize) return;
	
	// reduce to sum
	atomicAdd(result_d, vector_d[x]);
}

// This function is called from the host computer.
// It manages memory and calls the function that is executed on the GPU
extern "C" void calcDot(uint32_t vectorSize, unsigned long long *dotResult)
{
    // force_d and dotResult reside on the GPU
	unsigned long long *force_d;
	unsigned long long *dotResult_d;
	cudaError_t result;

    // allocate space on the device
	result = cudaMalloc((void **)&force_d, sizeof(unsigned long long) * vectorSize);
	if (result != cudaSuccess)
	{
		fprintf(stderr, "cudaMalloc (force) failed: %s\n", cudaGetErrorString(result));
		exit(1);
	}
	result = cudaMalloc((void **)&dotResult_d, sizeof(unsigned long long));
	if (result != cudaSuccess)
	{
		fprintf(stderr, "cudaMalloc (dotResult) failed: %s\n", cudaGetErrorString(result));
		exit(1);
	}

    // set execution configuration
	dim3 dimblock(BLOCK_SIZE);
	dim3 dimgrid(ceil((double)vectorSize / BLOCK_SIZE));

	// Start timing
    struct timeval tval_before, tval_after, tval_result;
    gettimeofday(&tval_before, NULL);

    // actual computation: Call the kernel
	cu_calcDot<<<dimgrid, dimblock>>>(force_d, vectorSize, dotResult_d);
	cu_reduce<<<dimgrid, dimblock>>>(force_d, vectorSize, dotResult_d);

    // transfer results back to host
	result = cudaMemcpy(dotResult, dotResult_d, sizeof(unsigned long long), cudaMemcpyDeviceToHost);
	if (result != cudaSuccess)
	{
		fprintf(stderr, "cudaMemcpy host <- dev (dotResult) failed: %s\n", cudaGetErrorString(result));
		exit(1);
	}

	// Stop timing
    gettimeofday(&tval_after, NULL);
    timersub(&tval_after, &tval_before, &tval_result);
    printf("Time elapsed: %ld.%06lds\n", (long int)tval_result.tv_sec, (long int)tval_result.tv_usec);

    // release the memory on the GPU
	result = cudaFree(force_d);
	if (result != cudaSuccess)
	{
		fprintf(stderr, "cudaFree (force) failed: %s\n", cudaGetErrorString(result));
		exit(1);
	}
	result = cudaFree(dotResult_d);
	if (result != cudaSuccess)
	{
		fprintf(stderr, "cudaFree (dotResult) failed: %s\n", cudaGetErrorString(result));
		exit(1);
	}
}
