```
mpif90  -Ofast -ipo -g -heap-arrays -xHost -traceback -check bounds -module MOD  -c SRC/hdf5_wrapper.f90 -o OBJ/hdf5_wrapper.o 
gfortran: error: bounds: No such file or directory
gfortran: error: unrecognized command line option '-ipo'
gfortran: error: unrecognized command line option '-h'
gfortran: error: unrecognized command line option '-traceback'
gfortran: error: unrecognized command line option '-check'; did you mean '-fcheck='?
gfortran: error: unrecognized command line option '-module'; did you mean '-mhle'?
makefile:92: recipe for target 'OBJ/hdf5_wrapper.o' failed
make: *** [OBJ/hdf5_wrapper.o] Error 1
```


conda install -c conda-forge hdf5
conda install -c conda-forge openmpi

```
mpifort -Ofast -ipo -g -heap-arrays -xHost -traceback -check bounds -module MOD  -c SRC/hdf5_wrapper.f90 -o OBJ/hdf5_wrapper.o 
x86_64-conda_cos6-linux-gnu-gfortran.bin: error: bounds: No such file or directory
x86_64-conda_cos6-linux-gnu-gfortran.bin: error: unrecognized command line option '-h'
x86_64-conda_cos6-linux-gnu-gfortran.bin: error: unrecognized command line option '-traceback'
x86_64-conda_cos6-linux-gnu-gfortran.bin: error: unrecognized command line option '-check'; did you mean '-fcheck='?
makefile:93: recipe for target 'OBJ/hdf5_wrapper.o' failed
make: *** [OBJ/hdf5_wrapper.o] Error 1
```

sudo apt-get install libhdf5-serial-dev


fortran flags

https://faculty.washington.edu/rjl/uwamath583s11/sphinx/notes/html/gfortran_flags.html