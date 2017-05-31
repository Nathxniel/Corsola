#include <stdio.h>
#include <stdint.h>

#define N 1288243249

long unsigned decimalToBinary(long n) {
  int remainder;
  long binary = 0, i = 1;
  while(n != 0) {
    remainder = n%2;
    n = n/2;
    binary = binary + (remainder*i);
    i = i*10;
  }
  return(binary);
}

void printBits(uint32_t x) {
  printf("%ld\n", decimalToBinary(x));
}

int main(void) {
  printBits(N);
  return(0);
}
