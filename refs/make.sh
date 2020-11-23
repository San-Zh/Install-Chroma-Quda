#!/bin/bash -l

INSTALL=/public/home/ybyang/opt/new
INSTALL2=/public/home/ybyang/opt/new
precision="double"
quda_path=/public/home/ybyang/soft/build_quda_new

#flag='11000111' ## pure gpu
#flag='11111101' ## pure cpu
flag='00000002' 

if [ ${flag:0:1} -eq '1' ]; then
dir="qmp";
#git clone --recursive  git://github.com/usqcd-software/${dir}.git
mkdir build_${dir}
cd build_${dir}
#make clean
../${dir}/configure --prefix=${INSTALL}/${dir}  \
     CC="mpicc" CXX="mpicxx"\
     CXXFLAGS="-fopenmp -D_REENTRANT -g -O3 -finline-limit=50000 -std=c++11 -mavx2" \
     CFLAGS="-fopenmp -D_REENTRANT -g -O3 -std=gnu99" --with-qmp-comms-type=MPI
make -j
make install
cd ..
fi

if [ ${flag:1:1} -eq '1' ]; then
dir="qio";
#git clone --recursive  git://github.com/usqcd-software/${dir}.git
mkdir build_${dir}
cd build_${dir}
#make clean
#./autogen.sh
../${dir}/configure --prefix=${INSTALL}/${dir} \
     CC="mpicc" CXX="mpicxx"\
     -with-qmp=${INSTALL}/qmp -enable-largefile -enable-dml-output-buffering\
     CFLAGS="-fopenmp -D_REENTRANT -g -O3 -std=gnu99" 
make -j
make install
cd ..
fi

if [ ${flag:2:1} -eq '1' ]; then
dir="qla"
#git clone --recursive  git://github.com/usqcd-software/${dir}.git
mkdir build_${dir}
cd build_${dir}
#make clean
../${dir}/configure --prefix=${INSTALL}/${dir} \
     CC="mpicc" CXX="mpicxx"\
      --enable-sse3 --enable-temp-precision=D \
      CFLAGS="-Wall -std=gnu99 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer"
make -j
make install
cd ..
fi

if [ ${flag:3:1} -eq '1' ]; then
dir="qdp"
#git clone --recursive  git://github.com/usqcd-software/${dir}.git
mkdir build_${dir}
cd build_${dir}
#make clean
../${dir}/configure --prefix=${INSTALL}/${dir} \
     CC="mpicc" CXX="mpicxx"\
        --with-qmp=${INSTALL}/qmp --with-qio=${INSTALL}/qio --with-qla=${INSTALL}/qla --enable-sse\
        CFLAGS="-Wall -std=gnu99 -O3 -fargument-noalias-global -funroll-all-loops -fpeel-loops -ftree-vectorize"
make -j
make install
cd ..
fi

if [ ${flag:4:1} -eq '1' ]; then
dir="qopqdp"
#git clone --recursive  git://github.com/usqcd-software/${dir}.git
mkdir build_${dir}
cd build_${dir}
#make clean
../${dir}/configure --prefix=${INSTALL}/${dir} \
     CC="mpicc" CXX="mpicxx"\
        --with-qmp=${INSTALL}/qmp --with-qio=${INSTALL}/qio --with-qla=${INSTALL}/qla --with-qdp=${INSTALL}/qdp\
        --enable-underscores CFLAGS="-fopenmp -D_REENTRANT -g -std=gnu99 -O3"
make -j
make install
cd ..
fi

if [ ${flag:5:1} -eq '1' ]; then
dir="qdpxx"
#git clone --recursive  git://github.com/usqcd-software/${dir}.git
mkdir build_${dir}_${precision}
cd build_${dir}_${precision}
../${dir}/configure --prefix=${INSTALL}/${dir}_${precision}\
     CC="mpicc" CXX="mpicxx"\
        --with-qmp=${INSTALL}/qmp --enable-precision=${precision} --enable-parallel-arch=parscalar\
        --enable-largefile --enable-sse2 --enable-openmp\
        --enable-parallel-io --enable-dml-output-buffering \
        CFLAGS="-fopenmp -D_REENTRANT -g -std=gnu99 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math"\
        CXXFLAGS="-fopenmp -D_REENTRANT -g -std=c++11 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math"
make  -j
make install
cd ..
fi

if [ ${flag:6:1} -eq '1' ]; then
#for quda
make cmake
make hack
make build
#quda_path=../build_quda
fi

if [ ${flag:7:1} -eq '1' ]; then
dir="chroma"
mkdir build_${dir}_${precision}_cpu
cd build_${dir}_${precision}_cpu
#make clean
../${dir}/configure --prefix=${INSTALL2}/${dir}_cpu_${precision} \
     FC=mpif90 CC="mpicc" CXX="mpicxx"\
        --with-qmp=${INSTALL}/qmp --with-qdp=${INSTALL}/qdpxx_${precision} --enable-qop-mg \
        --with-qio=${INSTALL}/qio --with-qla=${INSTALL}/qla --with-qdpc=${INSTALL}/qdp \
        --with-qopqdp=${INSTALL}/qopqdp --enable-precision=${precision} --enable-parallel-arch=parscalar\
        --enable-sse3 --enable-sse-wilson-dslash \
        CFLAGS="-fopenmp -D_REENTRANT -g -std=gnu99 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math"\
        CXXFLAGS="-fopenmp -D_REENTRANT -g -std=c++11 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math -fpermissive"

make -j 8
make install
fi

if [ ${flag:7:1} -eq '2' ]; then
dir="chroma"
mkdir build_${dir}_${precision}
cd build_${dir}_${precision}
#make clean
../${dir}/configure --prefix=${INSTALL2}/${dir}_gpu_${precision} \
     FC=mpif90 CC="mpicc" CXX="mpicxx"\
        --with-qmp=${INSTALL}/qmp --with-qdp=${INSTALL}/qdpxx_${precision} --enable-qop-mg \
        --with-qio=${INSTALL}/qio --with-qla=${INSTALL}/qla --with-qdpc=${INSTALL}/qdp \
        --with-qopqdp=${INSTALL}/qopqdp --enable-precision=${precision} --enable-parallel-arch=parscalar\
        --enable-sse3 --enable-sse-wilson-dslash \
	--with-quda=${quda_path}\
        CFLAGS="-fopenmp -D_REENTRANT -g -std=gnu99 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math"\
        CXXFLAGS="-fopenmp -D_REENTRANT -g -std=c++11 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math -fpermissive"
make -j 8
make install
fi
