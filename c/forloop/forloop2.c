#include <time.h>
#include <stdio.h>
#include <stdint.h>

const int n = 1000000;
int i;

int plus_one(int x);

    int
main(int argc, const char * argv[]) {
    int x = 0;
    clock_t tic = clock();
    for (i=0; i < n; i++) {
        x = plus_one(x);
    }
    clock_t toc = clock();
    printf("Run-time: %f s\n",
        ((double) (toc - tic))/CLOCKS_PER_SEC
    );
    return 0;
}

    int
plus_one(int x)
{
    return x+1;
}
