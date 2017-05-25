#include <stdio.h>
#include <ctype.h>
#include <string.h>

#define MAX_READ_SIZE 256;
#define MAX_ANSWER_SIZE 1;

#define TRUTH 1;

int anotherGame(void) {
  int answerSize = MAX_ANSWER_SIZE;
  char answer[answerSize];
  int result = 1;

  while (result) {
    printf("Do you want to play another game? [y/n]: ");
    int readSize = MAX_READ_SIZE;
    fgets(answer, readSize, stdin);

    if (strlen(answer) > 1) {
      continue;
    }

    answer[0] = tolower(answer[0]);

    printf("%s\n", answer);
  }
}

int main(void) {
  anotherGame();
  int as = 'a' + 'a';
  printf("Okay so a+a = %i", as);
  return(0);
}
