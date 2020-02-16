# install

## ifort installation

?
<https://www.webmo.net/support/ifort11.html>

source ifort

point mpif90 to ifort `mpif90 -f90=ifort ...`

<https://software.intel.com/en-us/forums/intel-clusters-and-hpc-technology/topic/288354>

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

CC = mpif90 -X -I/usr/include/hdf5/serial

locate hdf5.h

install zlib: sudo apt install zlib1g

... may need to compile hdf5 by using ifort
<https://software.intel.com/en-us/articles/performance-tools-for-software-developers-building-hdf5-with-intel-compilers>

tar xvzf hdf5-1.10.6-linux-centos7-x86_64-static.tar.gz

1
export CC=icc
export F9X=ifort
export CXX=icpc
export MPICC=mpicc
export MPICXX=mpiicpc
export CFLAGS="-O3 -xHost -fno-alias -align"
export FFLAGS="-O3 -xHost -fno-alias -align"
export CXXFLAGS="-O3 -xHost -fno-alias -align"
export FFlags="-I/opt/intel/impi/2019.6.166/intel64/include -L/opt/intel/impi/2019.6.166/intel64/lib"


2
cd hdf5-1.8.15
3
./configure --prefix=/usr/local/hdf5-ifort/ --enable-fortran 
<!-- --enable-parallel -->
<!-- --enable-cxx -->
4
... output of configure ...
5
make
6
... watch for fatal errors ...
7
make check
8
... verify that all tests return "PASS"
9
make install


source /opt/intel/bin/ifortvars.sh intel64
source /opt/intel/bin/compilervars.sh intel64
source /opt/intel/bin/iccvars.sh intel64
source /opt/intel/mkl/bin/mklvars.sh intel64
source /opt/intel/impi/2019.6.166/intel64/bin/mpivars.sh intel64

sudo -s
source /opt/intel/bin/ifortvars.sh intel64
source /opt/intel/bin/compilervars.sh intel64
source /opt/intel/bin/iccvars.sh intel64
source /opt/intel/mkl/bin/mklvars.sh intel64
source /opt/intel/impi/2019.6.166/intel64/bin/mpivars.sh intel64
make install


https://linuxcluster.wordpress.com/2016/09/30/compiling-hdf5-1-8-17-with-intel-15-0-6-and-intel-mpi-5-0-6/

vim .bashrc

source /usr/local/intel_2015/bin/compilervars.sh intel64
source /usr/local/intel_2015/impi/5.0.3.049/bin64/mpivars.sh intel64
source /usr/local/intel_2015/mkl/bin/mklvars.sh intel64
export CC=icc
export CXX=icpc
export F77=ifort
export MPICC=mpicc
export MPICXX=mpiicpc
export CFLAGS="-O3 -xHost -fno-alias -align"
export FFLAGS="-O3 -xHost -fno-alias -align"
export CXXFLAGS="-O3 -xHost -fno-alias -align"
export FFlags="-I/usr/local/intel_2015/impi/5.0.3.049/include64 -L/usr/local/intel_2015/impi/5.0.3.049/lib64"


Step 2: Compile zlib-1

See Compile zlib-1.2.8 with Intel-15.0.6
https://linuxcluster.wordpress.com/2016/09/30/compile-zlib-1-2-8-with-intel-15-0-6/

$ tar -zxvf hdf5-1.8.17.tar.gz
$ cd hdf5-1.8.17
$ ./configure --prefix=/usr/local/hdf5-1.8.17 --enable-fortran --enable-cxx
$ make
$ make check
$ make install



SZLIB:

export CC=icc
export CXX=icpc
export F77=ifort
export CFLAGS=’-O3 -xHost -ip’
export CXXFLAGS=’-O3 -xHost -ip’
export FFLAGS=’-O3 -xHost -ip’
tar -zxvf szip-2.1.tar.gz
cd szip-2.1
./configure –prefix=/home/user/Mohid/szip-2.1
make
make check
make install

ZLIB:

export CC=icc
export CFLAGS=’-O3 -xHost -ip’
tar -zxvf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure –prefix=/home/user/Mohid/zlib-1.2.8
make
make check
make install

hdf5:

export CC=icc
export FC=’ifort -fpp -DDEC$=DEC_ -DMS$=MS_’
export CXX=icpc
tar -zxvf hdf5-1.8.11.tar.gz
cd hdf5-1.8.11
./configure –prefix=/home/user/Mohid/hdf5-1.8.11 –enable-fortran –enable-fortran2003 –enable-cxx –enable-unsupported \
–with-szlib=/home/user/Mohid/szip-2.1 –with-zlib=/home/user/Mohid/zlib-1.2.8/include,/home/user/Mohid/zlib-1.2.8/lib –enable-production
make
make check
make install

----------------------------------------------------------------------
Libraries have been installed in:
   /mnt/c/Users/haixin/Downloads/hdf5-1.10.6/hdf5/lib

If you ever happen to want to link against installed libraries
in a given directory, LIBDIR, you must either use libtool, and
specify the full pathname of the library, or use the '-LLIBDIR'
flag during linking and do at least one of the following:
   - add LIBDIR to the 'LD_LIBRARY_PATH' environment variable
     during execution
   - add LIBDIR to the 'LD_RUN_PATH' environment variable
     during linking
   - use the '-Wl,-rpath -Wl,LIBDIR' linker flag
   - have your system administrator add LIBDIR to '/etc/ld.so.conf'

See any operating system documentation about shared libraries for
more information, such as the ld(1) and ld.so(8) manual pages.
----------------------------------------------------------------------


./configure --prefix=/usr/local/hdf5-ifort/ --enable-fortran --enable-cxx
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking whether make supports nested variables... (cached) yes
checking whether to enable maintainer-specific portions of Makefiles... no
checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking shell variables initial values... done
checking if basename works... yes
checking if xargs works... yes
checking for cached host... none
checking for config x86_64-unknown-linux-gnu... no
checking for config x86_64-unknown-linux-gnu... no
checking for config unknown-linux-gnu... no
checking for config unknown-linux-gnu... no
checking for config x86_64-linux-gnu... no
checking for config x86_64-linux-gnu... no
checking for config x86_64-unknown... no
checking for config linux-gnu... found
compiler 'icc' is Intel icc-19.1.0.166
compiler 'ifort' is Intel ifort-19.1.0.166
compiler 'icpc' is GNU g++-7.4.0
checking for config ./config/site-specific/host-NUC8q... no
checking build mode... production
checking for gcc... icc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables... 
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether icc accepts -g... yes
checking for icc option to accept ISO C89... none needed
checking whether icc understands -c and -o together... yes
checking for style of include used by make... GNU
checking dependency style of icc... gcc3
checking if unsupported combinations of configure options are allowed... no
checking how to run the C preprocessor... icc -E
checking for grep that handles long lines and -e... /bin/grep
checking for egrep... /bin/grep -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking for off_t... yes
checking for size_t... yes
checking for ssize_t... yes
checking for ptrdiff_t... yes
checking whether byte ordering is bigendian... no
checking size of char... 1
checking size of short... 2
checking size of int... 4
checking size of unsigned... 4
checking size of long... 8
checking size of long long... 8
checking size of __int64... 8
checking size of float... 4
checking size of double... 8
checking size of long double... 16
checking size of __float128... 16
checking size of _Quad... 0
checking quadmath.h usability... yes
checking quadmath.h presence... yes
checking for quadmath.h... yes
checking maximum decimal precision for C... 33
checking if Fortran interface enabled... yes
checking whether we are using the GNU Fortran compiler... no
checking whether ifort accepts -g... yes
checking for Fortran flag to compile .f90 files... none
checking whether we are using the GNU Fortran compiler... (cached) no
checking whether ifort accepts -g... (cached) yes
checking what ifort does with modules... MODULE.mod
checking how ifort finds modules... -I
checking if Fortran compiler version compatible with Fortran 2003 HDF... yes
checking how to get verbose linking output from ifort... -v
checking for Fortran libraries of ifort...  -L/opt/intel/compilers_and_libraries_2020.0.166/linux/mpi/intel64/libfabric/lib -L/opt/intel/compilers_and_libraries_2020.0.166/linux/ipp/lib/intel64 -L/opt/intel/compilers_and_libraries_2020.0.166/linux/compiler/lib/intel64_lin -L/opt/intel/compilers_and_libraries_2020.0.166/linux/mkl/lib/intel64_lin -L/opt/intel/compilers_and_libraries_2020.0.166/linux/tbb/lib/intel64/gcc4.8 -L/opt/intel/compilers_and_libraries_2020.0.166/linux/daal/lib/intel64_lin -L/opt/intel/compilers_and_libraries_2020.0.166/linux/daal/../tbb/lib/intel64_lin/gcc4.4 -L/opt/intel/compilers_and_libraries_2020.0.166/linux/daal/../tbb/lib/intel64_lin/gcc4.8 -L/opt/intel/compilers_and_libraries_2020.0.166/linux/mpi/intel64/libfabric/lib/../lib/ -L/usr/lib/gcc/x86_64-linux-gnu/7/ -L/usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu/ -L/usr/lib/gcc/x86_64-linux-gnu/7/../../../../lib64 -L/usr/lib/gcc/x86_64-linux-gnu/7/../../../../lib/ -L/lib/x86_64-linux-gnu/ -L/lib/../lib64 -L/lib/../lib/ -L/usr/lib/x86_64-linux-gnu/ -L/usr/lib/../lib64 -L/usr/lib/../lib/ -L/opt/intel/compilers_and_libraries_2020.0.166/linux/mpi/intel64/libfabric/lib/ -L/opt/intel/compilers_and_libraries_2020.0.166/linux/ipp/lib/intel64/ -L/opt/intel/compilers_and_libraries_2020.0.166/linux/compiler/lib/intel64_lin/ -L/opt/intel/compilers_and_libraries_2020.0.166/linux/mkl/lib/intel64_lin/ -L/opt/intel/compilers_and_libraries_2020.0.166/linux/tbb/lib/intel64/gcc4.8/ -L/opt/intel/compilers_and_libraries_2020.0.166/linux/daal/lib/intel64_lin/ -L/opt/intel/compilers_and_libraries_2020.0.166/linux/daal/../tbb/lib/intel64_lin/gcc4.8/ -L/usr/lib/gcc/x86_64-linux-gnu/7/../../../ -L/lib64 -L/lib/ -L/usr/lib64 -L/usr/lib -lifport -lifcoremt -limf -lsvml -lm -lipgo -lirc -lpthread -lirc_s -ldl
checking for dummy main to link with Fortran libraries... none
checking for Fortran name-mangling scheme... lower case, underscore, no extra underscore
checking if Fortran compiler supports intrinsic SIZEOF... yes
checking if Fortran compiler supports intrinsic C_SIZEOF... yes
checking if Fortran compiler supports intrinsic STORAGE_SIZE... yes
checking if Fortran compiler supports intrinsic module ISO_FORTRAN_ENV... yes
checking for Number of Fortran INTEGER KINDs... 4
checking for Fortran INTEGER KINDs... {1,2,4,8}
checking for Fortran REAL KINDs... {4,8,16}
checking for Fortran REALs maximum decimal precision... 33
checking sizeof of native KINDS... 
checking for Number of Fortran INTEGER KINDs... 4
checking for Fortran INTEGER KINDs... {1,2,4,8}
checking for Fortran REAL KINDs... {4,8,16}
checking for Fortran REALs maximum decimal precision... 33
checking sizeof of available INTEGER KINDs... {1,2,4,8}
checking sizeof of available REAL KINDs... {4,8,16}
checking if Fortran compiler supports intrinsic C_LONG_DOUBLE... yes
checking if Fortran C_LONG_DOUBLE is different from C_DOUBLE... yes
checking for Fortran interoperable KINDS with C... {4,8,16}
checking whether we are using the GNU C++ compiler... yes
checking whether icpc accepts -g... yes
checking dependency style of icpc... gcc3
checking how to run the C++ preprocessor... icpc -E
checking if c++ interface enabled... yes
checking if icpc needs old style header files in includes... no
checking if icpc can handle namespaces... yes
checking if icpc can handle static cast... yes
checking if icpc has offsetof extension... yes
checking if the high-level library is enabled... yes
checking for ar... ar
checking whether make sets $(MAKE)... (cached) yes
checking for tr... /usr/bin/tr
checking if srcdir= and time commands work together... yes
checking if Java JNI interface enabled... no
checking if shared Fortran libraries are supported... yes
checking if building tests is disabled... checking if building tools is disabled... checking how to print strings... printf
checking for a sed that does not truncate output... /bin/sed
checking for fgrep... /bin/grep -F
checking for ld used by icc... /usr/bin/ld
checking if the linker (/usr/bin/ld) is GNU ld... yes
checking for BSD- or MS-compatible name lister (nm)... /usr/bin/nm -B
checking the name lister (/usr/bin/nm -B) interface... BSD nm
checking whether ln -s works... yes
checking the maximum length of command line arguments... 1572864
checking how to convert x86_64-unknown-linux-gnu file names to x86_64-unknown-linux-gnu format... func_convert_file_noop
checking how to convert x86_64-unknown-linux-gnu file names to toolchain format... func_convert_file_noop
checking for /usr/bin/ld option to reload object files... -r
checking for objdump... objdump
checking how to recognize dependent libraries... pass_all
checking for dlltool... no
checking how to associate runtime and link libraries... printf %s\n
checking for archiver @FILE support... @
checking for strip... strip
checking for ranlib... ranlib
checking command to parse /usr/bin/nm -B output from icc object... ok
checking for sysroot... no
checking for a working dd... /bin/dd
checking how to truncate binary pipes... /bin/dd bs=4096 count=1
checking for mt... mt
checking if mt is a manifest tool... no
checking for dlfcn.h... yes
checking for objdir... .libs
checking if icc supports -fno-rtti -fno-exceptions... yes
checking for icc option to produce PIC... -fPIC -DPIC
checking if icc PIC flag -fPIC -DPIC works... yes
checking if icc static flag -static works... yes
checking if icc supports -c -o file.o... yes
checking if icc supports -c -o file.o... (cached) yes
checking whether the icc linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
checking whether -lc should be explicitly linked in... no
checking dynamic linker characteristics... GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking for shl_load... no
checking for shl_load in -ldld... no
checking for dlopen... yes
checking whether a program can dlopen itself... yes
checking whether a statically linked program can dlopen itself... no
checking whether stripping libraries is possible... yes
checking if libtool supports shared libraries... yes
checking whether to build shared libraries... yes
checking whether to build static libraries... yes
checking how to run the C++ preprocessor... icpc -E
checking for ld used by icpc... /usr/bin/ld -m elf_x86_64
checking if the linker (/usr/bin/ld -m elf_x86_64) is GNU ld... yes
checking whether the icpc linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
checking for icpc option to produce PIC... -fPIC -DPIC
checking if icpc PIC flag -fPIC -DPIC works... yes
checking if icpc static flag -static works... yes
checking if icpc supports -c -o file.o... yes
checking if icpc supports -c -o file.o... (cached) yes
checking whether the icpc linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
checking dynamic linker characteristics... (cached) GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking if libtool supports shared libraries... yes
checking whether to build shared libraries... yes
checking whether to build static libraries... yes
checking for ifort option to produce PIC... -fPIC
checking if ifort PIC flag -fPIC works... yes
checking if ifort static flag -static works... yes
checking if ifort supports -c -o file.o... yes
checking if ifort supports -c -o file.o... (cached) yes
checking whether the ifort linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
checking dynamic linker characteristics... (cached) GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking if we should install only statically linked executables... no
checking if -Wl,-rpath should be used to link shared libs in nondefault directories... yes
checking for ceil in -lm... yes
checking for dlopen in -ldl... yes
checking for ANSI C header files... (cached) yes
checking whether time.h and sys/time.h may both be included... yes
checking sys/resource.h usability... yes
checking sys/resource.h presence... yes
checking for sys/resource.h... yes
checking sys/time.h usability... yes
checking sys/time.h presence... yes
checking for sys/time.h... yes
checking for unistd.h... (cached) yes
checking sys/ioctl.h usability... yes
checking sys/ioctl.h presence... yes
checking for sys/ioctl.h... yes
checking for sys/stat.h... (cached) yes
checking sys/socket.h usability... yes
checking sys/socket.h presence... yes
checking for sys/socket.h... yes
checking for sys/types.h... (cached) yes
checking sys/file.h usability... yes
checking sys/file.h presence... yes
checking for sys/file.h... yes
checking stddef.h usability... yes
checking stddef.h presence... yes
checking for stddef.h... yes
checking setjmp.h usability... yes
checking setjmp.h presence... yes
checking for setjmp.h... yes
checking features.h usability... yes
checking features.h presence... yes
checking for features.h... yes
checking dirent.h usability... yes
checking dirent.h presence... yes
checking for dirent.h... yes
checking for stdint.h... (cached) yes
checking stdbool.h usability... yes
checking stdbool.h presence... yes
checking for stdbool.h... yes
checking mach/mach_time.h usability... no
checking mach/mach_time.h presence... no
checking for mach/mach_time.h... no
checking io.h usability... no
checking io.h presence... no
checking for io.h... no
checking winsock2.h usability... no
checking winsock2.h presence... no
checking for winsock2.h... no
checking sys/timeb.h usability... yes
checking sys/timeb.h presence... yes
checking for sys/timeb.h... yes
checking if libtool needs -no-undefined flag to build shared libraries... no
checking for _FILE_OFFSET_BITS value needed for large files... no
checking size of int8_t... 1
checking size of uint8_t... 1
checking size of int_least8_t... 1
checking size of uint_least8_t... 1
checking size of int_fast8_t... 1
checking size of uint_fast8_t... 1
checking size of int16_t... 2
checking size of uint16_t... 2
checking size of int_least16_t... 2
checking size of uint_least16_t... 2
checking size of int_fast16_t... 8
checking size of uint_fast16_t... 8
checking size of int32_t... 4
checking size of uint32_t... 4
checking size of int_least32_t... 4
checking size of uint_least32_t... 4
checking size of int_fast32_t... 8
checking size of uint_fast32_t... 8
checking size of int64_t... 8
checking size of uint64_t... 8
checking size of int_least64_t... 8
checking size of uint_least64_t... 8
checking size of int_fast64_t... 8
checking size of uint_fast64_t... 8
checking size of size_t... 8
checking size of ssize_t... 8
checking size of ptrdiff_t... 8
checking size of off_t... 8
checking size of bool... 1
checking size of time_t... 8
checking if dev_t is scalar... yes
checking for dmalloc library... suppressed
checking zlib.h usability... yes
checking zlib.h presence... yes
checking for zlib.h... yes
checking for compress2 in -lz... yes
checking for compress2... yes
checking for szlib... suppressed
checking for thread safe support... no
checking whether CLOCK_MONOTONIC is declared... yes
checking for tm_gmtoff in struct tm... yes
checking for global timezone variable... yes
checking for st_blocks in struct stat... no
checking for _getvideoconfig... no
checking for gettextinfo... no
checking for GetConsoleScreenBufferInfo... no
checking for getpwuid... yes
checking for _scrsize... no
checking for ioctl... yes
checking for struct videoconfig... no
checking for struct text_info... no
checking for TIOCGWINSZ... yes
checking for TIOCGETD... yes
checking for library containing clock_gettime... none required
checking for alarm... yes
checking for clock_gettime... yes
checking for difftime... yes
checking for fcntl... yes
checking for flock... yes
checking for fork... yes
checking for frexpf... yes
checking for frexpl... yes
checking for gethostname... yes
checking for getrusage... yes
checking for gettimeofday... yes
checking for lstat... yes
checking for rand_r... yes
checking for random... yes
checking for setsysinfo... no
checking for signal... yes
checking for longjmp... yes
checking for setjmp... yes
checking for siglongjmp... yes
checking for sigsetjmp... no
checking for sigprocmask... yes
checking for snprintf... yes
checking for srandom... yes
checking for strdup... yes
checking for symlink... yes
checking for system... yes
checking for strtoll... yes
checking for strtoull... yes
checking for tmpfile... yes
checking for asprintf... yes
checking for vasprintf... yes
checking for vsnprintf... yes
checking for waitpid... yes
checking for roundf... yes
checking for lroundf... yes
checking for llroundf... yes
checking for round... yes
checking for lround... yes
checking for llround... yes
checking for an ANSI C-conforming const... yes
checking if the compiler understands  __inline__... yes
checking if the compiler understands __inline... yes
checking if the compiler understands inline... yes
checking for __attribute__ extension... yes
checking for __func__ extension... yes
checking for __FUNCTION__ extension... yes
checking for C99 designated initialization support... yes
checking how to print long long... %ld and %lu
checking enable debugging symbols... no
checking enable asserts... no
checking enable developer warnings... no
checking profiling... no
checking optimization level... high
checking for internal debug output... none
checking whether function stack tracking is enabled... no
checking for API tracing... no
checking whether a memory checking tool will be used... no
checking whether internal memory allocation sanity checking is used... no
checking for parallel support files... skipped
checking whether O_DIRECT is declared... yes
checking for posix_memalign... yes
checking if the direct I/O virtual file driver (VFD) is enabled... no
checking if the Read-Only S3 virtual file driver (VFD) is enabled... no
checking for libhdfs... suppressed
checking for custom plugin default path definition... /usr/local/hdf5/lib/plugin
checking whether exception handling functions is checked during data conversions... yes
checking whether data accuracy is guaranteed during data conversions... yes
checking if the machine has window style path name... no
checking if using special algorithm to convert long double to (unsigned) long values... no
checking if using special algorithm to convert (unsigned) long to long double values... no
checking if correctly converting long double to (unsigned) long long values... yes
checking if correctly converting (unsigned) long long to long double values... yes
checking if the system is IBM ppc64le and cannot correctly convert some long double values... no
checking additional programs should be built... no
checking if deprecated public symbols are available... yes
checking which version of public symbols to use by default... v110
checking whether to perform strict file format checks... no
checking for pread... yes
checking for pwrite... yes
checking whether to use pread/pwrite instead of read/write in certain VFDs... yes
checking whether to have library information embedded in the executables... yes
checking if alignment restrictions are strictly enforced... no
configure: creating ./config.lt
config.lt: creating libtool
checking that generated files are newer than configure... done
configure: creating ./config.status
config.status: creating src/libhdf5.settings
config.status: creating Makefile
config.status: creating src/Makefile
config.status: creating test/Makefile
config.status: creating test/H5srcdir_str.h
config.status: creating test/testabort_fail.sh
config.status: creating test/testcheck_version.sh
config.status: creating test/testerror.sh
config.status: creating test/testexternal_env.sh
config.status: creating test/testflushrefresh.sh
config.status: creating test/testlibinfo.sh
config.status: creating test/testlinks_env.sh
config.status: creating test/testswmr.sh
config.status: creating test/testvds_env.sh
config.status: creating test/testvdsswmr.sh
config.status: creating test/test_filter_plugin.sh
config.status: creating test/test_usecases.sh
config.status: creating testpar/Makefile
config.status: creating testpar/testpflush.sh
config.status: creating tools/Makefile
config.status: creating tools/lib/Makefile
config.status: creating tools/libtest/Makefile
config.status: creating tools/src/Makefile
config.status: creating tools/src/h5dump/Makefile
config.status: creating tools/src/h5import/Makefile
config.status: creating tools/src/h5diff/Makefile
config.status: creating tools/src/h5jam/Makefile
config.status: creating tools/src/h5repack/Makefile
config.status: creating tools/src/h5ls/Makefile
config.status: creating tools/src/h5copy/Makefile
config.status: creating tools/src/misc/Makefile
config.status: creating tools/src/h5stat/Makefile
config.status: creating tools/test/Makefile
config.status: creating tools/test/h5dump/Makefile
config.status: creating tools/test/h5dump/h5dump_plugin.sh
config.status: creating tools/test/h5dump/testh5dump.sh
config.status: creating tools/test/h5dump/testh5dumppbits.sh
config.status: creating tools/test/h5dump/testh5dumpvds.sh
config.status: creating tools/test/h5dump/testh5dumpxml.sh
config.status: creating tools/test/h5ls/Makefile
config.status: creating tools/test/h5ls/h5ls_plugin.sh
config.status: creating tools/test/h5ls/testh5ls.sh
config.status: creating tools/test/h5ls/testh5lsvds.sh
config.status: creating tools/test/h5import/Makefile
config.status: creating tools/test/h5import/h5importtestutil.sh
config.status: creating tools/test/h5diff/Makefile
config.status: creating tools/test/h5diff/h5diff_plugin.sh
config.status: creating tools/test/h5diff/testh5diff.sh
config.status: creating tools/test/h5diff/testph5diff.sh
config.status: creating tools/src/h5format_convert/Makefile
config.status: creating tools/test/h5format_convert/Makefile
config.status: creating tools/test/h5format_convert/testh5fc.sh
config.status: creating tools/test/h5jam/Makefile
config.status: creating tools/test/h5jam/testh5jam.sh
config.status: creating tools/test/h5repack/Makefile
config.status: creating tools/test/h5repack/h5repack.sh
config.status: creating tools/test/h5repack/h5repack_plugin.sh
config.status: creating tools/test/h5copy/Makefile
config.status: creating tools/test/h5copy/testh5copy.sh
config.status: creating tools/test/misc/Makefile
config.status: creating tools/test/misc/testh5clear.sh
config.status: creating tools/test/misc/testh5mkgrp.sh
config.status: creating tools/test/misc/testh5repart.sh
config.status: creating tools/test/misc/vds/Makefile
config.status: creating tools/test/h5stat/Makefile
config.status: creating tools/test/h5stat/testh5stat.sh
config.status: creating tools/test/perform/Makefile
config.status: creating examples/Makefile
config.status: creating examples/run-c-ex.sh
config.status: creating examples/testh5cc.sh
config.status: creating bin/h5cc
config.status: creating bin/Makefile
config.status: creating c++/Makefile
config.status: creating c++/src/Makefile
config.status: creating c++/src/h5c++
config.status: creating c++/test/Makefile
config.status: creating c++/test/H5srcdir_str.h
config.status: creating c++/examples/Makefile
config.status: creating c++/examples/run-c++-ex.sh
config.status: creating c++/examples/testh5c++.sh
config.status: creating fortran/Makefile
config.status: creating fortran/src/h5fc
config.status: creating fortran/src/Makefile
config.status: creating fortran/src/H5fort_type_defines.h
config.status: creating fortran/test/Makefile
config.status: creating fortran/testpar/Makefile
config.status: creating fortran/examples/Makefile
config.status: creating fortran/examples/run-fortran-ex.sh
config.status: creating fortran/examples/testh5fc.sh
config.status: creating java/Makefile
config.status: creating java/src/Makefile
config.status: creating java/src/jni/Makefile
config.status: creating java/test/Makefile
config.status: creating java/test/junit.sh
config.status: creating java/examples/Makefile
config.status: creating java/examples/intro/Makefile
config.status: creating java/examples/intro/JavaIntroExample.sh
config.status: creating java/examples/datasets/Makefile
config.status: creating java/examples/datasets/JavaDatasetExample.sh
config.status: creating java/examples/datatypes/Makefile
config.status: creating java/examples/datatypes/JavaDatatypeExample.sh
config.status: creating java/examples/groups/Makefile
config.status: creating java/examples/groups/JavaGroupExample.sh
config.status: creating hl/Makefile
config.status: creating hl/src/Makefile
config.status: creating hl/test/Makefile
config.status: creating hl/test/H5srcdir_str.h
config.status: creating hl/tools/Makefile
config.status: creating hl/tools/gif2h5/Makefile
config.status: creating hl/tools/gif2h5/h52giftest.sh
config.status: creating hl/tools/h5watch/Makefile
config.status: creating hl/tools/h5watch/testh5watch.sh
config.status: creating hl/examples/Makefile
config.status: creating hl/examples/run-hlc-ex.sh
config.status: creating hl/c++/Makefile
config.status: creating hl/c++/src/Makefile
config.status: creating hl/c++/test/Makefile
config.status: creating hl/c++/examples/Makefile
config.status: creating hl/c++/examples/run-hlc++-ex.sh
config.status: creating hl/fortran/Makefile
config.status: creating hl/fortran/src/Makefile
config.status: creating hl/fortran/test/Makefile
config.status: creating hl/fortran/examples/Makefile
config.status: creating hl/fortran/examples/run-hlfortran-ex.sh
config.status: creating src/H5config.h
config.status: creating fortran/src/H5config_f.inc
config.status: executing pubconf commands
creating src/H5pubconf.h
Post process src/libhdf5.settings
config.status: executing depfiles commands
config.status: executing libtool commands
config.status: executing .classes commands
            SUMMARY OF THE HDF5 CONFIGURATION
            =================================

General Information:
-------------------
                   HDF5 Version: 1.10.6
                  Configured on: Sun Feb 16 01:00:00 CET 2020
                  Configured by: haixin@NUC8q
                    Host system: x86_64-unknown-linux-gnu
              Uname information: Linux NUC8q 4.4.0-18362-Microsoft #476-Microsoft Fri Nov 01 16:53:00 PST 2019 x86_64 x86_64 x86_64 GNU/Linux
                       Byte sex: little-endian
             Installation point: /usr/local/hdf5-ifort

Compiling Options:
------------------
                     Build Mode: production
              Debugging Symbols: no
                        Asserts: no
                      Profiling: no
             Optimization Level: high

Linking Options:
----------------
                      Libraries: static, shared
  Statically Linked Executables: 
                        LDFLAGS: 
                     H5_LDFLAGS: 
                     AM_LDFLAGS: 
                Extra libraries: -lz -ldl -lm 
                       Archiver: ar
                       AR_FLAGS: cr
                         Ranlib: ranlib

Languages:
----------
                              C: yes
                     C Compiler: /opt/intel/compilers_and_libraries_2020.0.166/linux/bin/intel64/icc ( Intel(R) C Intel(R) 64 Compiler Version 19.1.0.166 Build 20191121)
                       CPPFLAGS: 
                    H5_CPPFLAGS: -D_GNU_SOURCE -D_POSIX_C_SOURCE=200809L   -DNDEBUG -UH5_DEBUG_API
                    AM_CPPFLAGS: 
                        C Flags: 
                     H5 C Flags:   -std=c99 -Wcheck -Wall  -Wl,-s  -O3
                     AM C Flags: 
               Shared C Library: yes
               Static C Library: yes


                        Fortran: yes
               Fortran Compiler: /opt/intel/compilers_and_libraries_2020.0.166/linux/bin/intel64/ifort ( Intel(R) Fortran Intel(R) 64 Compiler Version 19.1.0.166 Build 20191121)
                  Fortran Flags: 
               H5 Fortran Flags:    -O3
               AM Fortran Flags: 
         Shared Fortran Library: yes
         Static Fortran Library: yes

                            C++: yes
                   C++ Compiler: /opt/intel/compilers_and_libraries_2020.0.166/linux/bin/intel64/icpc ( Intel(R) C++ Intel(R) 64 Compiler Version 19.1.0.166 Build 20191121)
                      C++ Flags: 
                   H5 C++ Flags:   -pedantic -Wall -W -Wundef -Wshadow -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings -Wconversion -Wredundant-decls -Winline -Wsign-promo -Woverloaded-virtual -Wold-style-cast -Weffc++ -Wreorder -Wnon-virtual-dtor -Wctor-dtor-privacy -Wabi -finline-functions -s -O
                   AM C++ Flags: 
             Shared C++ Library: yes
             Static C++ Library: yes

                           Java: no


Features:
---------
                   Parallel HDF5: no
Parallel Filtered Dataset Writes: no
              Large Parallel I/O: no
              High-level library: yes
                Build HDF5 Tests: yes
                Build HDF5 Tools: yes
                    Threadsafety: no
             Default API mapping: v110
  With deprecated public symbols: yes
          I/O filters (external): deflate(zlib)
                             MPE: no
                      Direct VFD: no
              (Read-Only) S3 VFD: no
            (Read-Only) HDFS VFD: no
                         dmalloc: no
  Packages w/ extra debug output: none
                     API tracing: no
            Using memory checker: no
 Memory allocation sanity checks: no
          Function stack tracing: no
       Strict file format checks: no
    Optimization instrumentation: no




libtool: warning: relinking 'libhdf5_fortran.la'
libtool: install: (cd /mnt/c/Users/haixin/Downloads/hdf5-1.10.6/fortran/src; /bin/bash "/mnt/c/Users/haixin/Downloads/hdf5-1.10.6/libtool"  --silent --tag FC --mode=relink ifort -O3 -I../../src -I../../fortran/src -version-info 102:1:0 -o libhdf5_fortran.la -rpath /usr/local/hdf5-ifort/lib H5f90global.lo H5fortran_types.lo H5_ff.lo H5Aff.lo H5Dff.lo H5Eff.lo H5Fff.lo H5Gff.lo H5Iff.lo H5Lff.lo H5Off.lo H5Pff.lo H5Rff.lo H5Sff.lo H5Tff.lo H5Zff.lo H5_gen.lo H5fortkit.lo H5f90kit.lo H5_f.lo H5Af.lo H5Df.lo H5Ef.lo H5Ff.lo H5Gf.lo H5If.lo H5Lf.lo H5Of.lo H5Pf.lo H5Rf.lo H5Sf.lo H5Tf.lo H5Zf.lo HDF5.lo ../../src/libhdf5.la -lz -ldl -lm )
/mnt/c/Users/haixin/Downloads/hdf5-1.10.6/libtool: line 10545: ifort: command not found
libtool:   error: error: relink 'libhdf5_fortran.la' with the above command before installing it
Makefile:921: recipe for target 'install-libLTLIBRARIES' failed
make[4]: *** [install-libLTLIBRARIES] Error 1
make[4]: Leaving directory '/mnt/c/Users/haixin/Downloads/hdf5-1.10.6/fortran/src'
Makefile:1277: recipe for target 'install-am' failed
make[3]: *** [install-am] Error 2
make[3]: Leaving directory '/mnt/c/Users/haixin/Downloads/hdf5-1.10.6/fortran/src'
Makefile:1271: recipe for target 'install' failed
make[2]: *** [install] Error 2
make[2]: Leaving directory '/mnt/c/Users/haixin/Downloads/hdf5-1.10.6/fortran/src'
Makefile:820: recipe for target 'install-recursive' failed
make[1]: *** [install-recursive] Error 1
make[1]: Leaving directory '/mnt/c/Users/haixin/Downloads/hdf5-1.10.6/fortran'
Makefile:660: recipe for target 'install-recursive' failed
make: *** [install-recursive] Error 1