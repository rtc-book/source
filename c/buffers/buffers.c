#include <time.h>
#include <stdio.h>

int main (void) {
  int i;
  FILE *fp;                               // file pointer
  clock_t tic = clock();                  // start clock
  fp = fopen("file.txt", "w+");           // open file to write
  for(i = 0; i < 1000000; i++) {          // 1M writes
    fputc('a', fp);                       // queue 'a' for write
    fflush(fp);                           // write to file
  }
  fclose(fp);                             // close file
  clock_t toc = clock();                  // stop clock
  printf("Clock cycles: %i\n", (int) (toc - tic));
}
