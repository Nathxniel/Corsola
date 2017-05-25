#include <stdio.h>
#define EUR_PER_POUND 1.316

int main (void) {
  double euros, pounds;

  printf("Enter the amount of pounds to be converted> ");
  scanf("%lf", &pounds);

  euros = EUR_PER_POUND * pounds;
  printf("That equals %f euros. \n", euros);
  return(0);

}
