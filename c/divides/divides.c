#include <time.h>                     // for clock(), etc.
#include <stdio.h>
#include <stdlib.h>                   // for random numbers

#define M 50000                       // elements of array
int a[M];                             // array to be averaged
const int n = 10000;                  // repetitions of mean calc

void mean_div_first(void)             // naïve divide-first mean
{
  double mean = 0.0, sum = 0.0;
  for (int i=0; i < n; i++,sum=0.0) { // repeat mean n times
    for (int j = 0; j < M; ++j)
      sum += (double)a[j]/M;          // cast for double division
    mean = sum;
  }
}

void mean_sum_first(void)             // faster sum-first mean
{
  double mean; int sum = 0;
  for (int i=0; i < n; i++,sum=0.0) { // repeat mean n times
    for (int j = 0; j < M; ++j)
      sum += a[j];                    // integer sums
    mean = (double)sum/M;             // cast for double division
  }
}

int main(void)
{
  for (int i = 0; i < M; i++)         // populate a w/randos
    a[i] = rand();                    // \cite[7.20.2]{c99}
  clock_t tic_div_first = clock();
  mean_div_first();                   // divide first
  clock_t toc_div_first = clock();
  int cyc_div_first = (int) (toc_div_first - tic_div_first);
  clock_t tic_sum_first = clock();
  mean_sum_first();                   // sum first
  clock_t toc_sum_first = clock();
  int cyc_sum_first = (int) (toc_sum_first - tic_sum_first);
  double ratio = (double)cyc_div_first/cyc_sum_first;
  printf("Dividing first was %.1f times slower than "
         "summing first.\n", ratio);
}
