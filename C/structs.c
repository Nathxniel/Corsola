#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Person {
  char name[50];
  int age;
};

struct Person createPerson(char name[50], int age) {
  struct Person p;
  strcpy(p.name, name);
  p.age = age;
  return(p);
}

struct Person getPerson(void) {
  struct Person p;
  fgets(p.name, 50, stdin);
  scanf("%i", &p.age);
  return(p);
}

void printPeople(struct Person *people, int n) {
  for (int i=0; i<n; i++) {
    printf("name: %s, age: %i\n", people[i].name, people[i].age);
  }
}

int main(void) {
  struct Person a = createPerson("joe", 18);
  struct Person b = createPerson("sar", 28);
  struct Person people[2] = {a, b};  
  printPeople(people, 2);
  return(0);
}
