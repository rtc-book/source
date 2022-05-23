//
//  main.c
//  unsigned
//
//  Created by Rico Picone on 4/15/22.
//

#include <time.h>
#include <stdio.h>
#include <stdint.h>

const int32_t n = 1000000;
const uint32_t m = n;
int32_t i, x;
uint32_t j, y;

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
    for (i=0; i > (-1*n); i--) {
        x = i % 16;
    }
}

void unsigned_mod(void)
{
    for (j=0; j < m; j++) {
        // y = j % 16U;
        y = j & 1;
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
