#include <stdio.h>

int main(void) {
  char name[30];
  do {
    printf("success\n");
    fgets(name, 256, stdin);
    printf("you said: %s", name);

  } while (1);

  return(0);
}
