#include <time.h>
#include <stdio.h>
#define BUFN 1000                           // buffer size sans '\0'

int main (void) {
  int i;
  char buf[BUFN+1];                       // char buffer
  buf[BUFN] = '\0';                       // null terminate
  char *bp = buf;                         // buffer pointer
  FILE *fp;
  clock_t tic = clock();
  fp = fopen("file-buffered.txt", "w+");
  for(i=1; i < 1000001; i++) {            // shifted 1 due to mod
    *bp++ = 'a';                          // assign char to buffer
    if (i % BUFN == 0) {                  // every BUFN
      fputs(buf, fp);                     // queue for write
      fflush(fp);                         // write to file
      bp = buf;                           // reset pointer
    }
  }
  fclose(fp);
  clock_t toc = clock();
  printf("Clock cycles: %i\n",(int) (toc - tic));
}
