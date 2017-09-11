#include <stdio.h>
#include <stdlib.h>

#define MAX 100
#define DIFF(a, b) ((a - b) < 0) ? (b - a) : (a - b)

int calc(int width, int height) {
  int answer = 0;

  for (int w=width; w>0; w--) {
    for (int h=height; h>0; h--) {
      answer += w*h;
    }
  }

  return answer;
}

int *solve(void) {
  static int out[2];
  int smallestDifference = 100000;

  for (int i=1; i<MAX; i++) {
    for (int j=1; j<MAX; j++) {
      if (DIFF(calc(i, j), 2000000) < smallestDifference) {
        out[0] = i;
        out[1] = j;
      }
    }
  }

  printf("width: %i, height: %i\nnoSquares: %i\n", out[0], out[1], calc(out[0], out[1]));
  return out;

}

/*
int main(int argc, char **argv) {
  int width = atoi(argv[1]);
  int height = atoi(argv[2]);

  printf("answer %i\n", calc(width, height)); 

}
*/

int main(void) {
  solve();
  printf("our guess: %i\n", calc(53,52));
}
