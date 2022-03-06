#include <stdio.h>

// This function is purely in C (no Fortran), and simpler to incorporate into
// haskell since you don't need to compile library archives, but can directly
// link to the source files. It's used here as a demo for interfacing with
// HMatrix.
//
// The glut of extra parameters is meant to align with the HMatrix `TransArray`
// type family, along with the `apply` function. The dimensions of a single
// matrix are defined in 4 terms: 2 for row and column size of the array in
// memory, and 2 for row and column size of the slice you're interested in.
//
// NOTE: remember C and Haskell both use row-major arrays (Fortran will be
// column major), so the following algorithm has to take care to look at the
// correct dimensions of the input array by offsetting by the entire size of the
// array in memory, while the output array can collect results based on its
// sliced dimensions.
int transpose (int slice_nrow1, int slice_ncol1, int xrow1, int xcol1, double * inp[],
               int slice_nrow2, int slice_ncol2, int xrow2, int xcol2, double * out[]) {
  int r, c;
  for(r=0; r < slice_nrow2; r++) {
    for (c=0; c < slice_ncol2; c++) {
      out[r * slice_ncol2 + c] = inp[r + c * xrow1];
    }
  }
  return 0;
}
