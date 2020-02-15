# install

## ifort installation

?
<https://www.webmo.net/support/ifort11.html>

## problem that do not use ifort

```bash
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

```bash
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

```bash
.o OBJ/parquet_chi.o OBJ/parquet_BSE.o OBJ/parquet_PhiR.o OBJ/parquet_equation.o OBJ/parquet_EQMatrix.o OBJ/parquet_EQContribs.o OBJ/parquet_EQOuter.o OBJ/parquet_selfenergy.o OBJ/parquet_SDE.o OBJ/parquet_sus.o OBJ/parquet_check.o OBJ/preprocessing.o OBJ/loop.o OBJ/tups.o .//lib/libdfftpack.a -mkl -lhdf5_fortran -lhdf5hl_fortran -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -o TUPS
/home/haixin/miniconda3/bin/../lib/gcc/x86_64-conda_cos6-linux-gnu/7.3.0/../../../../x86_64-conda_cos6-linux-gnu/bin/ld: .//lib/libdfftpack.a(cffti1.o): relocation R_X86_64_32S against `.rodata' can not be used when making a PIE object; recompile with -fPIC
/home/haixin/miniconda3/bin/../lib/gcc/x86_64-conda_cos6-linux-gnu/7.3.0/../../../../x86_64-conda_cos6-linux-gnu/bin/ld: .//lib/libdfftpack.a(cfftb1.o): in function `cfftb1_':
cfftb1.f:(.text+0x1c1): undefined reference to `_intel_fast_memcpy'
/home/haixin/miniconda3/bin/../lib/gcc/x86_64-conda_cos6-linux-gnu/7.3.0/../../../../x86_64-conda_cos6-linux-gnu/bin/ld: .//lib/libdfftpack.a(cfftf1.o): in function `cfftf1_':
cfftf1.f:(.text+0x1c1): undefined reference to `_intel_fast_memcpy'
/home/haixin/miniconda3/bin/../lib/gcc/x86_64-conda_cos6-linux-gnu/7.3.0/../../../../x86_64-conda_cos6-linux-gnu/bin/ld: final link failed: symbol needs debug section which does not exist
collect2: error: ld returned 1 exit status
makefile:34: recipe for target 'TUPS' failed
make: *** [TUPS] Error 1
```

```bash
undefined reference to `_intel_fast_memcpy':
```

These are defined in libirc.a or libintlc.so. Make sure to link one of these in your build.

```bash
`.rodata' can not be used when making a PIE object; recompile with -fPIC
/home/haixin/miniconda3/bin/../lib/gcc/x86_64-conda_cos6-linux-gnu/7.3.0/../../../../x86_64-conda_cos6-linux-gnu/bin/ld: .//lib/libdfftpack.a(cfftb1.o): in function `cfftb1_':
```

PIE =  path independent..
-nopie to resolve