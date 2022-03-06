#include <stdio.h>

void scalarmul_(int *r, int *c, double * mat[], double *scalar);

// modify that matrix in-place
int scalarmul(int slice_r, int slice_c, int r, int c, double * mat[], double scalar){
  scalarmul_(&slice_r, &slice_c, mat, &scalar);
  return 0;
}
