#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#define NUMBER_OF_GUESSES 4
#define NUMBER_OF_CODES 5
#define guessLowrBnd 1
#define guessUpperBnd 9

int anotherGame(void) {
  char answer;
  int loop;
  int ansIsYes;

  do {
    printf("Do you want to play another game? [y/n]: ");
    answer = getchar();
    /*It asks you whether you want to play twice for some reason
     * TODO: figure out why*/
    while(getchar() != '\n');
    answer = tolower(answer);
    ansIsYes = (answer == 'y');
    loop = !ansIsYes && (answer != 'n');
  } while (loop);
  return(ansIsYes);
}

int *readGuess(void) {
  printf("Enter your guess:\n");
  /*
   * guess is a local variable,
   * in C you can't return the address of a local variable
   * outside of a function
   */
  static int guess[NUMBER_OF_GUESSES];
  int buffer = 0;
  for (int i=0; i<NUMBER_OF_GUESSES; i++) {
    do {
      printf("number %i: ", i+1);
      scanf("%i", &buffer);
      guess[i] = buffer;
    } while (guess[i] < guessLowrBnd || guess[i] > guessUpperBnd);
  }
  return(guess);
}

/*array length helper function*/
/*TODO: generalise*/
int intArrLength(int *a) {
  int result = 0;
  for( ; *a; a++) result++;
  return(result);
}

int blackScore(int guess[], int code[]) {
  /*assert (intArrLength(guess) == intArrLength(code));
   *TODO: fix intArrLenth*/
  int score = 0;
  for (int i=0; i<intArrLength(guess); i++) {
    if (code[i] == guess[i]) {
      score++;
    }
  } 
  return(score);
}

int whiteScore(int guess[], int code[]) {
  /*assert (intArrLength(guess) == intArrLength(code));
   *TODO: fix intArrLenth*/
  int score = 0;
  for (int i=0; i<intArrLength(guess); i++) {
    for (int j=0; j<intArrLength(guess); j++) {
      if (i != j && code[i] == guess[j]) {
        score++;
      }
    }
  }
  return(score);
}

void printScore(int g[], int c[]) {
  printf("(%i, %i)\n", blackScore(g,c), whiteScore(g,c));
}

int main(void) {
  int codes[NUMBER_OF_CODES][NUMBER_OF_GUESSES]
    = {{1,8,9,2}, {2,4,6,8}, {1,9,8,3}, {7,4,2,1}, {4,6,8,9}}; 

  for (int i=0; i<NUMBER_OF_CODES; i++) {
    int *guess = readGuess();
    while (blackScore(guess, codes[i]) != NUMBER_OF_GUESSES) {
      printScore(guess, codes[i]);
      guess = readGuess();
    }

    printf("You have guessed correctly!\n");
    if (i < NUMBER_OF_CODES-1) {
      int another = anotherGame();
      if (!another) {
        break;
      }
    }
  }
  return(0);
}
