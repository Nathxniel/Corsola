#include <stdio.h>
#include <stdlib.h>

#define ASIZE 4

int calcSize(int *a) {
  int result = 0;
  for ( ;*a;a++) result++;
  return(result);
}

int main(void) {
  int *array;
  /*allocate 4 for elements 1 for size*/
  array = (int *) malloc(ASIZE + 1);
  *array = ASIZE;
  array++;
  for (int i=0; i<ASIZE; i++) {
    array[i] = 8;
  }
  

  printf("Array size: %i\n", calcSize(array));
  printf("Array size: %i\n", array[-1]);
  printf("First item: %i\n", *array);
  printf("First item: %i\n\n", array[0]);

  free(array);
  printf("Segmentation fault?%i\n", array[0]);


  return(0);
}

