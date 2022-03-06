##################################################
#
# Haskell, HMatrix and Fortran demo
#
##################################################


repl: libs
	hpack
	LD_LIBRARY_PATH=c/1_hello:c/2_fpow:c/4_scalarmul cabal repl

run: libs
	hpack
	LD_LIBRARY_PATH=c/1_hello:c/2_fpow:c/4_scalarmul cabal run

libs: libhello.a libfpow.a libscalarmul.a

libhello.a:
	# compile c code
	gcc -g -Wall -fPIC -lgfortran -c -o c/1_hello/lib.o c/1_hello/lib.c
	# compile fortran code
	gfortran -c -o c/1_hello/hello.o c/1_hello/hello.f95
	# dynamic linking
	gcc -shared -o c/1_hello/libhello.so c/1_hello/lib.o c/1_hello/hello.o

libfpow.a:
	# compile c code
	gcc -g -Wall -lgfortran -c -o c/2_fpow/lib.o c/2_fpow/lib.c
	# compile fortran code
	gfortran -c -o c/2_fpow/fpow.o c/2_fpow/fpow.f95
	# dynamic linking
	gcc -shared -o c/2_fpow/libfpow.so c/2_fpow/lib.o c/2_fpow/fpow.o


libscalarmul.a:
	# compile c code
	gcc -g -Wall -lgfortran -c -o c/4_scalarmul/lib.o c/4_scalarmul/lib.c
	# compile fortran code
	gfortran -c -o c/4_scalarmul/scalarmul.o c/4_scalarmul/scalarmul.f95
	# dynamic linking
	gcc -shared -o c/4_scalarmul/libscalarmul.so c/4_scalarmul/lib.o c/4_scalarmul/scalarmul.o

clean:
	rm -f c/1_hello/*.o
	rm -f c/1_hello/*.so
	rm -f c/1_hello/*.a

	rm -f c/2_fpow/*.o
	rm -f c/2_fpow/*.so
	rm -f c/2_fpow/*.a

	rm -f c/4_scalarmul/*.o
	rm -f c/4_scalarmul/*.so
	rm -f c/4_scalarmul/*.a
