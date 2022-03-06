#include <stdio.h>

// Function from fortran. It requires pointers passed in.
double fpow_(double *xbase, double *xexponent);

// fortran requires non-array params passed by reference. Here's a wrapper so
// that Haskell can call this function using pure values.
double fpow (double xbase, double xexponent) {
  return fpow_(&xbase, &xexponent);
}
