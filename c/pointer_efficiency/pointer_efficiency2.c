//
//  main.c
//  pointer_efficiency2
//
//  Created by Rico Picone on 4/15/22.
//

#include <time.h>
#include <stdio.h>

const int N = 100000000;
int x[N] = { 0 };
int y[N] = { 0 };
int *yp = y;
int i;

void time_it( void (*f)(void) );
void index_looper(void);
void pointer_looper(void);

int main(int argc, const char * argv[]) {
  time_it(&index_looper);
  time_it(&pointer_looper);
  return 0;
}

void index_looper(void)
{
  for (i=0; i < N; i++) {
    x[i] = 1;
  }
}

void pointer_looper(void)
{
  for (i=0; yp < &y[N];) {
    *yp++ = 1;
  }
}

void time_it( void (*f)(void) ) {
  clock_t tic = clock();
  (*f)();
  clock_t toc = clock();
  printf(
    "Run-time: %f s\n",
    (double)(toc - tic)/CLOCKS_PER_SEC
  );
}
