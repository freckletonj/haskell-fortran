subroutine scalarmul(nrows, ncols, m, scalar)
  real*8, intent(inout) :: m(nrows, ncols)
  real*8, intent(in) :: scalar
  m = m * scalar
end subroutine scalarmul
