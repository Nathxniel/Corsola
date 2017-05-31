#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int stringLength(char *string) {
  int length = 1;
  for ( ; *string!='\0'; string++) length++;
  return(length);
}

char *stringCat(char *string1, char *string2) {
  char *result;
  result = malloc(stringLength(string1)+stringLength(string2)+1);
  strcpy(result, string1);
  strcat(result, string2);
  return(result);
}

void printCommandLengths(char **commands, int n) {
  for (int i=0; i<n; i++) {
    printf("%s, length %i\n", commands[i], stringLength(commands[i]));
  }
}

void printCommandConcat(char **commands, int n) {
  char *result;
  char *buffer;

  size_t size = 0;
  /*calculating total size for result string*/
  for (int i=0; i<n; i++) {
    size = size + stringLength(commands[i]); 
  }
  /*allocating the appropriate amount of mem for result*/
  result = malloc(size+1);

  for (int i=0; i<n; i++) {
    buffer = stringCat(result, commands[i]);
    strcpy(result, buffer);
    free(buffer);
  }
  printf("%s\n", result);
}

int main(int argc, char **argv) {
  char *commands[3] = {"hello", "miss", "jackson"};
  printCommandLengths(commands, 3);
  printCommandConcat(commands, 3);
  return(0);
}
