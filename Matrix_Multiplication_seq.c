#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 2000

float a[N * N];
float b[N * N];
float c[N * N];

void matgen(float* a, int n){
	int i, j;
	for(i = 0; i < n; i++){
		for(j = 0; j < n; j++){
		a[i *n + j] = (float)rand();
		}
	}
}

void matmult(float* a, float* b, float* c, int n){
	int i, j, k;
	for(i = 0; i < n; i++){
		for(j = 0; j < n; j++){
			float t = 0;
			for(k = 0; k < n; k++){
				t += a[i * n + k] * b[k * n + j];
			}
			c[i * n + j] = t;
		}
	}
}

int main(){
    int i;
    for(i = 8; i <= 1024; i = i * 2){	
        clock_t start = clock();
        matgen(a, i);
        matgen(b, i); 
        matmult(a, b, c, i);
	    clock_t end = (clock() - start) / 1000;
    	printf("%d * %d, uess time: %ldms\n", i, i, end);
    }
	return 0;
}
