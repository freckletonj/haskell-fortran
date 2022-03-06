{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import Foreign (Ptr, alloca, poke, peek, Storable)
import Foreign.C.Types (CInt(..), CDouble(..))
import Foreign.Ptr (Ptr)
import Numeric.LinearAlgebra
import Numeric.LinearAlgebra.Devel
import System.IO.Unsafe (unsafePerformIO)
import Text.Printf (printf)


--------------------------------------------------
-- * 0) Simple.
--
-- Import straight from C's stdio (IE not any custom C file).

foreign import ccall "exp" myExp :: Double -> Double


--------------------------------------------------
-- * 1) Hello.
--
-- Demonstrates IO from Fortran with no parameter passing.

foreign import ccall "hello_" hello :: IO ()


--------------------------------------------------
-- * 2) FPow.
--
-- Demonstrates Fortran parameter passing.

-- this is a pure function that wraps the Fortran function. The Fortran function
-- expects pointers, and this C wrapper takes values, and handles passing on the
-- references to the Fortran function.
foreign import ccall "fpow" fpow :: Double -> Double -> Double

-- This function is the unwrapped Fortran function, FFI'd into C, and it expects
-- pointers, not values.
foreign import ccall "fpow_" fpow_ :: Ptr Double -> Ptr Double -> IO Double

fpowViaRefs :: Double -> Double -> IO Double
fpowViaRefs b e =
  alloca $ \base -> -- get a pointer
  alloca $ \exponent -> do
    poke base b -- set its value
    poke exponent e
    fpow_ base exponent -- note: pointers don't escape, just the final value


--------------------------------------------------
-- * 3) Transpose.
--
-- Demonstrates interfacing between C and HMatrix. C and HMatrix both use
-- row-major arrays.

foreign import ccall "transpose"
  transpose_ :: Double ::> Double ::> IO CInt

transpose :: Matrix Double -> Matrix Double
transpose m = let
  nrow = rows m
  ncol = cols m
  in unsafePerformIO $ do
  -- allocate some memory
  m' <- createMatrix RowMajor ncol nrow
  -- apply function to memory locations
  () <- (m #! m') transpose_ #| "transpose_"
  pure m'


--------------------------------------------------
-- * 4) Mat-Vec multiplication.
--
-- Demonstrates interfacing between Fortran and HMatrix. Fortran uses
-- colum-major arrays, so, HMatrix can correct that with `fmat`.

foreign import ccall "scalarmul"
  scalarmul :: Double ::> (Double -> IO CInt)

scalarMul :: Matrix Double -> Double -> Matrix Double
scalarMul m x = unsafePerformIO $ do
  let m' = fmat m -- copy array into Fortran's col-major ordering
  () <- (m' #! x) scalarmul #| "scalarMul"
  -- TODO: m' mutated. this is ugly, is there a better way?
  pure  m'


--------------------------------------------------
-- * Main.

main :: IO ()
main = do
  putStrLn "0_simple: `exp` comes from C's stdio:"
  putStrLn $ printf "myExp: e^3=%3.3f" (myExp 3)

  putStrLn "\n1_hello: Fortran can print to stdout on its own:"
  hello

  putStrLn "\n2_fpow: Passing data into Fortran:"
  putStrLn $ printf "pure fpow: %3.3f" (fpow 2 12)

  putStrLn "\n2_fpow: Passing pointers into Fortran:"
  putStrLn . printf "impure fpow: %3.3f" =<< fpowViaRefs 2 13

  putStrLn "\n3_transpose: Connecting C and HMatrix:"
  let m = (10><10) [0 :: Double ..]
      -- testing slices to make the problem more interesting, since HMatrix may
      -- still retain the larger array, but records the dimensions of the sliced
      -- array separately.
      sliceM = subMatrix (3, 3) (5, 7) m
  print sliceM
  print $ transpose sliceM

  putStrLn "\n4_scalarmul: Connecting Fortran and HMatrix:"
  let m2 = (10><10) [0 :: Double ..]
      sliceM2 = subMatrix (3, 3) (5, 7) m2
  print $ scalarMul sliceM2 1000


--------------------------------------------------
-- * HMatrix.Devel helpers

infixr 1 #
(#) :: TransArray c => c -> (b -> IO r) -> Trans c b -> IO r
a # b = apply a b
{-# INLINE (#) #-}

-- | Apply vectors and matrices to a c function
--
-- Usage Ex1:
--   (param1 # param2 # param3 #! param4) c_function #| "c_function"
(#!) :: (TransArray c, TransArray c1) => c1 -> c -> Trans c1 (Trans c (IO r)) -> IO r
a #! b = a # b # id
{-# INLINE (#!) #-}

-- This idea taken from the HMatrix library. TransArray instances, together with
-- `apply`, will set multiple parameters to pass into C.
infixr 5 :>, ::>

-- | Type for vector params passed to C
type (:>)  t r = CInt -- size of vector
              -> Ptr t -- pointer to vector
              -> r -- a continuation, allowing composition of params

-- | Type for matrix params passed to C
type (::>) t r =  CInt -- slice height (nrows)
               -> CInt -- slice width (ncols)
               -> CInt -- matrix height
               -> CInt -- matrix width
               -> Ptr t -- array pointer
               -> r -- a continuation, allowing composition of params

instance TransArray Double where
  type TransRaw Double b = Double -> b
  type Trans Double b = Double -> b
  apply x f g = f (g x)
  applyRaw x f g = f (g x)

instance TransArray Int where
  type TransRaw Int b = Int -> b
  type Trans Int b = Int -> b
  apply x f g = f (g x)
  applyRaw x f g = f (g x)
