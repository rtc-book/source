
# include <stdio.h>
# include <string.h>

int insert_sort(int T[], int n);

  int
main(void)
{
  int n = 10;
  int T[] = {88,14,34,62,90,16,55,19,48,73};
  int Tp[n];
  memcpy(Tp,T,n*sizeof(int));
  insert_sort(Tp,n);
  for (int i = 0; i < n; ++i) {
    printf("%d\t%d\t%d\n",i,T[i],Tp[i]);
  }
  return 0;
}

  int
insert_sort(int T[],int n)
{
  int key,j;
  for (int i = 1; i < n; ++i) {
    key = T[i];
    j = i - 1;
    while (j >= 0 && T[j] > key) {
      T[j+1] = T[j];
      j--;
    }
    T[j+1] = key;
  }
  return 0;
}
