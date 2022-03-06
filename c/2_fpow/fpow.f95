function fpow(xbase, xexponent) result(y)
  REAL*8, intent(in) :: xbase
  REAL*8, intent(in) :: xexponent
  REAL*8 :: y
  y = xbase ** xexponent
end function fpow
