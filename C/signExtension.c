#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>


int main(int argc, char **argv) {
  
  int32_t offset = atoi(argv[1]);
  
  printf("input: %i\n", offset);

  offset <<= 2;

  printf("shifted input: %i\n", offset);

  return(0);
}
