# include <stdio.h>

	int
main(void)
{
	int x[3] = {1,2,3};
	int *xp = x;
	int u, v;
	int i;

	i = 1+1;				// set array index to third element
	xp = x+2;				// set pointer to third element

	u = x[i];				// get value using index
	v = *xp;				// get value using pointer
}