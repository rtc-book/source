#include <time.h>
#include <stdio.h>

    int 
main (void) {
    int i;
    FILE *fp;                               // file pointer
    clock_t tic = clock();                  // start clock
    fp = fopen("file.txt", "w+");           // open file to write
    for(i=0; i < 1000000; i++) {            // 1M writes
        fputc('a', fp);                     // write 'a' repeatedly
    }
    fclose(fp);                             // close file
    clock_t toc = clock();                  // stop clock
    printf("Run-time: %f s\n",              // print cycle time
        (double)(toc - tic)/CLOCKS_PER_SEC  // from time.h
    );
    return 0;
}