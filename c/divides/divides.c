#include <time.h>                           // for clock(), etc.
#include <stdio.h>
#include <stdlib.h>                         // for random numbers

#define M 50000                             // elements of array
int a[M];                                   // array to be averaged
const int n = 10000;                        // repetitions of mean calc

double time_it( void (*f)(void) );
void mean_sum_first(void);
void mean_div_first(void);

    int 
main(void)
{
    double t_sum_first, t_div_first;
    for (int i = 0; i < M; ++i) {           // populate a w/ random ints
        a[i] = rand();                      // see <\cite[§ 7.20.2]{c99}>
    }
    t_div_first = time_it(&mean_div_first);
    t_sum_first = time_it(&mean_sum_first);
    printf( "Dividing first was %.1f times slower than "
            "summing first.\n", t_div_first/t_sum_first);
    return 0;
}

    void 
mean_div_first(void)                        // naïve divide-first mean
{
    double mean = 0.0, sum = 0.0;
    for (int i=0; i < n; i++) {             // repeat mean calc n times
        sum = 0.0;
        for (int j = 0; j < M; ++j) {
            sum += (double)a[j]/M;          // cast for double division
        }
        mean = sum;
    }
}

    void
mean_sum_first(void)                        // faster sum-first mean
{
    double mean;
    int sum = 0;
    for (int i=0; i < n; i++) {             // repeat mean calc n times
        sum = 0.0;
        for (int j = 0; j < M; ++j) {
            sum += a[j];                    // integer sums
        }
        mean = (double)sum/M;               // cast for double division
    }
}

    double
time_it( void (*f)(void) ) {                // function pointer argument
    clock_t tic = clock();
    (*f)();                                 // evaluate the function
    clock_t toc = clock();                          
    double run_time = (double)(toc - tic)/CLOCKS_PER_SEC;
    printf("Run-time: %f s\n",run_time);
    return run_time;
}