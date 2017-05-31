#include <stdio.h>


int alength(int *a) {
  int result = 0;
  for( ;*a;a++) result++;
  return(result);
}

int main(void) {
  
  int five = 5;
  int *ten = &five; 
  int ints[3] = {1, 2, 3};
  int trouble[] = {1, 2, 3};
  int problema[7] = {1,2,3,4,5,6,7};
  int *problem = problema;
  /*value at *(array + arraylength) == 0 always*/

  printf("Value at address %p is: %i\n", &five, five);
  printf("Value at pointer %p is: %i\n\n", ten, *ten);

  printf("Size of ints in bytes = %lu\n", sizeof(ints));
  printf("Size of (int) in bytes = %lu\n", sizeof(int));
  int size = sizeof(ints)/sizeof(int);
  printf("Size of ints in elements = %i\n", size);
  printf("alength = %i\n\n", alength(ints));

  printf("Size of trouble in bytes = %lu\n", sizeof(trouble));
  printf("Size of (int) in bytes = %lu\n", sizeof(int));
   size = sizeof(trouble)/sizeof(int);
  printf("Size of trouble in elements = %i\n", size);
  printf("alength = %i\n\n", alength(trouble));

  printf("Size of problem in bytes = %lu\n", sizeof(*problem));
  printf("Size of (int) in bytes = %lu\n", sizeof(int));
   size = sizeof(problem)/sizeof(int);
  printf("Size of problem in elements = %i\n", size);
  printf("alength = %i\n\n", alength(problem));

  printf("problema[2] = %i\n", problema[2]);
  printf("problem+2   = %i\n", *(problem+2));
  printf("problem[2]  = %i\n", problem[2]);

  int *p = ints;
  printf("%i\n", *(p + 2));
  printf("%i\n", *(p + 3));
  printf("%i\n", *(p + 4));
  

  return(0);
}
