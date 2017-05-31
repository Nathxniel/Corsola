#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define mainArgsNo 2

/*NOTE: malloc may fail*/
char *createCommand(size_t size) {
  char *retStr = malloc(size+1);
  return(retStr);
}

/*NOTE: malloc may fail*/
char **createCommands(int n) {
  char **pointerArray = malloc(n);
  return(pointerArray);
}

char *getCommand(size_t size) {
  /*PRE: (command size) < (size)*/
  printf("> ");
  char *command = createCommand(size);
  fgets(command, size, stdin);
  return(command);
}

char **getCommands(int n, size_t size) {
  char **commands = createCommands(n);
  for(int i=0; i<n; i++) commands[i] = getCommand(size);
  return(commands);
}

void printCommands(char **commands, int n) {
  for(int i=0; i<n; i++) printf("%s", commands[i]);
}

void freeCommands(char **commands, int n) {
  for(int i=0; i<n; i++) free(commands[i]);
  free(commands);
}

int main(int argc, char **argv) {
  assert(argc==mainArgsNo+1);
  /* argv[0] is always the program name
   * argv[1] is number of commands
   * argv[2] is command size */

  /* convert argv[1] to int */
  int n = atoi(argv[1]);

  /* convert argv[2] to size_t */
  size_t size = (size_t) atoi(argv[2]); 
  
  char **commands = malloc((n * size)+1);
  commands = getCommands(n, size);
  /* checking allocations worked */
  /* if command is null then createCommands malloc failed */
  if (commands==NULL) {
    printf("error: commands allocation failed. terminating\n"); 
    return(1);
  }

  /* if command[i] is null then createCommand malloc failed */
  for (int i=0; i<n; i++) {
    if (commands[i]==NULL) {
      printf("error: allocation @%i failed. terminating\n", i);
      return(1);
    }
  }

  /* print commands and free memory locations */
  printCommands(commands, n);
  freeCommands(commands, n);
  return(0);
}
