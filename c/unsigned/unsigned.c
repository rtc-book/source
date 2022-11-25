//
//  main.c
//  unsigned
//
//  Created by Rico Picone on 4/15/22.
//

#include <time.h>
#include <stdio.h>
#include <stdint.h>

const signed int n = 10000000;
const unsigned int m = 10000000u;
signed int i, x;
unsigned int j, y;

void time_it( void (*f)(void) );
void signed_mod(void);
void unsigned_mod(void);

int main(int argc, const char * argv[]) {
    time_it(&signed_mod);
    time_it(&unsigned_mod);
    return 0;
}

void signed_mod(void)
{
    for (i=0; i < n; i++) {
        x = i/2;
    }
}

void unsigned_mod(void)
{
    for (j=0; j < m; j++) {
        y = j/2u;
    }
}

    void
time_it( void (*f)(void) ) {
    clock_t tic = clock();
    (*f)();
    clock_t toc = clock();
    printf("Run-time: %f s\n",
        ((double) (toc - tic))/CLOCKS_PER_SEC
    );
}
