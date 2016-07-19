#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define TILE_WIDTH 16

bool InitCUDA(){
	int count;
	cudaDeviceProp prop;

	cudaGetDeviceCount(&count);
	if(count == 0){
		fprintf(stderr, "There is no device.\n");
		return false;
	}

	int i;
	for(i = 0; i < count; i++){
		if(cudaGetDeviceProperties(&prop, i) == cudaSuccess){
			if(prop.major >= 1){
				break;
			}
		}
	} 

	if(i == count){
		fprintf(stderr, "There is no device supporting CUDA 1.x.\n");
		return false;
	}

	cudaSetDevice(i);
	return true;
}

void matgen(float* a, int n){
	int i, j;
	for(i = 0; i < n; i++){
		for(j = 0; j < n; j++){
			a[i * n + j] = (float)rand();
		}
	}
}	
__global__ void MatrixMulKernel(float* Md, float* Nd, float* Pd, int Width){
	
	int tx = blockIdx.x * TILE_WIDTH + threadIdx.x;
	int ty = blockIdx.y * TILE_WIDTH + threadIdx.y;
	float Pvalue = 0;

	for(int k = 0; k < Width; k++){
		float Mdelement = Md[ty * Width + k];
		float Ndelement = Nd[k * Width + tx];
		Pvalue += Mdelement * Ndelement;
	}
	Pd[ty * Width+ tx] = Pvalue;
}


int main(){
    FILE *f = fopen("result.txt", "w");
        if (f == NULL)
        {
          printf("Error opening file!\n");
          exit(1);
         }

	if(!InitCUDA())
		return 0;
	printf("CUDA initialized.\n");
    fprintf(f, "CUDA initialized.\n", end);


	int i;
    for(i = 8; i <= 1024; i *= 2){
    clock_t start = clock();
	float* M, *N, *P;
    M = (float*) malloc(sizeof(float) * i * i);
    N = (float*) malloc(sizeof(float) * i * i);
    P = (float*) malloc(sizeof(float) * i * i);
	
	srand(0);
	matgen(M, i);
	matgen(N, i);

	int size = i * i * sizeof(float);
	float* Md, *Nd, *Pd;

	cudaMalloc((void**) &Md, size);
	cudaMemcpy(Md, M, size, cudaMemcpyHostToDevice);
	cudaMalloc((void**) &Nd, size);
	cudaMemcpy(Nd, N, size, cudaMemcpyHostToDevice);
	cudaMalloc((void**) &Pd, size);

	dim3 dimBlock(TILE_WIDTH, TILE_WIDTH);
	dim3 dimGrid(ceil(float(i)/TILE_WIDTH), ceil(float(i)/TILE_WIDTH));
    MatrixMulKernel<<<dimGrid, dimBlock>>>(Md, Nd, Pd, i);

	cudaMemcpy(P, Pd, size, cudaMemcpyDeviceToHost);
	cudaFree(Md);
	cudaFree(Nd);
	cudaFree(Pd);

	clock_t end = (clock() - start) / 1000;
	printf("%d * %d, uses time: %ldms\n", i, i, end);
	fprintf(f, "%d * %d, uses time: %ldms\n", i, i, end);
    }

    fclose(f);
	return 0;
}
