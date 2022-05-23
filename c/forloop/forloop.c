#include <time.h>
#include <stdio.h>
#include <stdint.h>

const int n = 1000000;
int i;

void time_it(int (*f)(int), int x);
int plus_one(int x);
int plus_one_for(int x);
int plus_one_nest(int x);

    int
main(int argc, const char * argv[]) {
    time_it(&plus_one_for,1);
    time_it(&plus_one_nest,1);
    return 0;
}

    int
plus_one(int x)
{
    return x+1;
}

    int
plus_one_for(int x)
{
    for (i=0; i < n; i++) {
        x += 1;
    }
    return x;
}

    int
plus_one_nest(int x)
{
    for (i=0; i < n; i++) {
        x = plus_one(x);
    }
    return x;
}

    void
time_it(int (*f)(int), int x) 
{
    clock_t tic = clock();
    (*f)(x);
    clock_t toc = clock();
    printf("Run-time: %f s\n",
        ((double) (toc - tic))/CLOCKS_PER_SEC
    );
}
