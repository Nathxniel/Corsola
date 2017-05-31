#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  switch (argc) {
    case 1:
      printf("case1: argv[0] = %s, args: %i\n", argv[0], argc);
      break;
    case 2:
      printf("case2: argv[0] = %s, args: %i\n", argv[0], argc);
      printf("case2: argv[1] = %s, args: %i\n", argv[1], argc);
      break;
    default:
      for(int i=0; i<argc; i++)
      printf("case3: argv[%i] = %s, args: %i\n", i, argv[i], argc);
      break;
  }

  printf("The answer is %i\n", atoi(argv[1]) +1);
  return(0);
}
