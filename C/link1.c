#include <stdio.h>
#include "link1head.h"

int linkint = 2;
linker variable;

void sayHello(void) {
  printf("hello! %i\n", linkint);
}

void sayHi(void) {
  printf("hi! %i\n", variable.linkerint);
}
