# Haskell-Fortran

Fortran ("Formula Translator") is a great imperative language intended to let mathematicians/scientists write performant code. In most industries, it's use is waning, but in many scientific industries, it's actually a critical component. For example, Python, and it' s library `numpy` are a workhorses in scientific communities and underneath it all are the Fortran libraries BLAS and LAPACK. Haskell's HMatrix library follows the same tact and links to those same battle-hardened libraries.

There are other FOSS Fortran libraries you might want to bring into the Haskell fold, or you might want an imperative, lightning fast language for some of your low-level work, while retaining Haskell's abstraction abilities, and type-safety.

This repository is a good place to start.


## TL;DR

You can accomplish:

```
C -> Haskell
C -> HMatrix
Fortran -> Haskell
Fortran -> HMatrix
```

## Description

To get connect the 2 languages, we must go through C, which isn't that bad.

```
Fortran  --FFI-->  C  --FFI-->  Haskell
```

This project builds up an example, step by step, for how to use Haskell's FFI, and C's Fortran FFI, to connect ultimately Fortran code to Haskell, and to Haskell's HMatrix library.


## The Demos

The best place to start is in [`src/Main.hs`](https://github.com/freckletonj/haskell-fortran/blob/master/src/Main.hs). In it you'll find:

0. An demo for getting the `exp` function out of C's stdio.

1. A hello world function, reaching all the way from Fortran to C, to Haskell.

2. A demo for passing values to Fortran. Fortran expects data passed by reference, so there are actually 2 examples. 1 passes references directly. The other utilizes a C wrapper function to help.

3. Connecting C arrays to HMatrix `Matrix`s.

4. And finally, doing array math in Fortran, and using it with HMatrix.


## Usage

1. An infelicity: Cabal won't resolve relative paths in `extra-lib-dirs`, so you must edit it to an absolute path into this repo. Look for these lines:

```
extra-lib-dirs:
  - EDIT_ME_TO_ABSOLUTE_PATH/c/1_hello
  - EDIT_ME_TO_ABSOLUTE_PATH/c/2_fpow
  - EDIT_ME_TO_ABSOLUTE_PATH/c/4_scalarmul
```

2. And we're off!

```sh
make run
```


## Notes

* GHC can link to static libraries (`*.a`) and dynamic libraries (`*.so`). We use dynamic libraries here because GHCi (the repl) only allows dynamic libraries.

* See the `Makefile` and `package.yaml` for how linking is done. Here's the gist:

    * First we compile C and Fortran code into objects that are not linked together yet:

    ```sh
    # C code. Notice it links in `gfortran`, needed by C's FFI.
    gcc -g -lgfortran -c -o OUTPUT_NAME.o C_CODE.c

    # Fortran code
    gfortran -c -o OUTPUT_NAME.o FORTRAN_CODE.f95
    ```

    * Then, link both those objects into a dynamic library

    ```sh
    gcc -shared -o OUTPUT_NAME.so OBJECT1.o OBJECT2.o ...
    ```

    * In `package.yaml`, you can include raw `C` files (without Fortran dependencies) without compiling them yourself via:

    ```
    include-dirs: SOME/DIR/
    c-sources: SOME/DIR/file.c
    ```

    * In `package.yaml`, you can link to the libraries you compiled via:

    ```
    extra-lib-dirs:
      - SOME/DIR

    extra-libraries
      - THELIBRARY
    ```

    * There is a naming convention you must follow. Libraries named `supercool` must be compiled to `libsupercool.so`, and in `package.yaml`, included as just `supercool`.


## My Questions

- Could I get a code review around some of the C, Makefile, and Fortran? I'm a total noob to all 3.

- If I have Fortran code mutate the underlying array, how can I do that safely in Haskell? [This line](https://github.com/freckletonj/haskell-fortran/blob/master/src/Main.hs#L90) seems a little sketchy to me. The other approach is to allocate an output array, and pass that to Fortran to mutate. But what if you want in-place mutation?

- Any opinions on generating C interfaces to Fortran code, and avoid C boilerplate? I found [f2c](http://www.netlib.org/f2c/) that seems interesting.
