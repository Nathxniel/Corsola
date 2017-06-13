#include <stdio.h>
#include <assert.h>

int outer = 4;

typedef struct {
  int deep;
} s;

void update(int *i) {
  assert(i != NULL);
  (*i)++;
}

void inc(int i) {
  i++;
}

int main(void) {  
  int inner = 3;
  s sinner;
  sinner.deep = 2;

  printf("INIT>   inner =  %i, outer = %i, deep = %i\n", 
      inner, outer, sinner.deep);
  update(&inner);
  update(&outer);
  update(&sinner.deep);
  printf("UPDATE> inner =  %i, outer = %i, deep = %i\n", 
      inner, outer, sinner.deep);
  inc(inner);
  inc(outer);
  inc(sinner.deep);
  printf("INC>    inner =  %i, outer = %i, deep = %i\n", 
      inner, outer, sinner.deep);


}
