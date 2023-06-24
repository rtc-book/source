/*
 * prime-checker.c
 * A program that checks an array for prime numbers.
 */

#include <stdio.h>
#include <math.h>

int primality(int x);              // prototype

int main(void)
{
  // int px, x=8;
  // px = primality(x);
  // if (px)
  // {
  //   printf("x = %d is prime\n",x);
  // } else {
  //   printf("x = %d is not prime\n",x);
  // }
  int i, j = 0;
  const int L = 10;               // array length
  int a[] = {0,1,4,11,121,4338,1901,7919,2022,2027};
  int ap[L];
  for (i = 0; i < L; i++) {          // each subscript of a
    if (primality(a[i])) {          // is prime
      ap[j] = a[i];
      j++;
    }
  }
  for (i = 0; i < j; i++) {
    printf("prime %d of %d is %d\n", i+1, j, ap[i]);
  }
}

/*
 * check if x is a prime number
 */
int primality(int x)
{
  int i;
  int max_divisor = floor(sqrt(x));       // Ibn al-Bann
  if (x < 2) {return 0;}            // 0 and 1 aren't prime
  if (x % 2 == 0 && x > 2) {return 0;}    // evens aren't prime
  for (i = 3; i < max_divisor+1; i += 2) {  // Sieve of Eratosthenes
    if (x % i == 0) {return 0;}        // divisible so not prime
  }
  return 1;                  // prime!
}
