#!/bin/bash -l
# Created by ybyang
# Modified by kelong

INSTALL=/public/home/kelong/software/chroma
INSTALL_PACKAGE=${INSTALL}/packages
precision="single"
# quda_path=/gpfs/share/home/1701110085/software/quda/quda-1.0.0/build

#flag='11000111' ## pure gpu
#flag='11111101' ## pure cpu
 flag='00000100' 

if [ ${flag:0:1} -eq '1' ]; then
dir="qmp";
# git clone  --recursive https://github.com/usqcd-software/${dir}.git
#mkdir build_${dir}
cd ${INSTALL_PACKAGE}/${dir}/build
#make clean
${INSTALL_PACKAGE}/${dir}/src/configure --prefix=${INSTALL_PACKAGE}/${dir}  \
     CXXFLAGS="-fopenmp -D_REENTRANT -g -O3 -finline-limit=50000 -std=c++11 -mavx2" \
     CC="mpicc" CXX="mpicxx"\
     CFLAGS="-fopenmp -D_REENTRANT -g -O3 -std=gnu99" --with-qmp-comms-type=MPI
make 
make install
cd ..
fi

if [ ${flag:1:1} -eq '1' ]; then
dir="qio";
# git clone --recursive  https://github.com/usqcd-software/${dir}.git
# git submodule update --init --recursive
# mkdir build_${dir}
cd ${INSTALL_PACKAGE}/${dir}/build
${INSTALL_PACKAGE}/${dir}/src/autogen.sh
${INSTALL_PACKAGE}/${dir}/src/configure --prefix=${INSTALL_PACKAGE}/${dir}  \
     CC="mpicc" CXX="mpicxx"\
     -with-qmp=${INSTALL}/build_qmp -enable-largefile -enable-dml-output-buffering\
     CFLAGS="-fopenmp -D_REENTRANT -g -O3 -std=gnu99" 

#make clean
make -j 4
make install
cd ..
fi

if [ ${flag:2:1} -eq '1' ]; then
dir="qla"
# git clone --recursive  https://github.com/usqcd-software/${dir}.git
# mkdir build_${dir}
cd ${INSTALL_PACKAGE}/${dir}/src
autoreconf -f
cd ${INSTALL_PACKAGE}/${dir}/build
# ${INSTALL_PACKAGE}/${dir}/src/autogen.sh
${INSTALL_PACKAGE}/${dir}/src/configure --prefix=${INSTALL_PACKAGE}/${dir}  \
     CC="mpicc" CXX="mpicxx"\
      --enable-sse3 --enable-temp-precision=D \
      CFLAGS="-Wall -std=gnu99 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer"
make -j
make install
cd ..
fi

if [ ${flag:3:1} -eq '1' ]; then
dir="qdp"
# git clone --recursive  https://github.com/usqcd-software/${dir}.git
mkdir build_${dir}
cd ${dir}
#make clean
autoreconf -f
./configure --prefix=${INSTALL}/build_${dir} \
     CC="mpicc" CXX="mpicxx"\
        --with-qmp=${INSTALL}/build_qmp --with-qio=${INSTALL}/build_qio --with-qla=${INSTALL}/qla --enable-sse\
        CFLAGS="-Wall -std=gnu99 -O3 -fargument-noalias-global -funroll-all-loops -fpeel-loops -ftree-vectorize"
make -j
make install
cd ..
fi

if [ ${flag:4:1} -eq '1' ]; then
dir="qopqdp"
# git clone --recursive  git://github.com/usqcd-software/${dir}.git
# mkdir build_${dir}
cd ${dir}
#make clean
autoreconf -f
./configure --prefix=${INSTALL_PACKAGE}/${dir} \
     CC="mpicc" CXX="mpicxx"\
        --with-qmp=${INSTALL_PACKAGE}/qmp --with-qio=${INSTALL_PACKAGE}/qio --with-qla=${INSTALL_PACKAGE}/qla --with-qdp=${INSTALL_PACKAGE}/qdp\
        --enable-underscores CFLAGS="-fopenmp -D_REENTRANT -g -std=gnu99 -O3"
make -j 16
make install
cd ..
fi

if [ ${flag:5:1} -eq '1' ]; then
dir="qdpxx"
# git clone --recursive  https://github.com/usqcd-software/${dir}.git
# git submodule update --init --recursive
# mkdir build_${dir}_${precision}
cd ${INSTALL_PACKAGE}/${dir}/${precision}/src
./autogen.sh
cd ${INSTALL_PACKAGE}/${dir}/${precision}/build
# ${INSTALL_PACKAGE}/${dir}/src/autogen.sh
${INSTALL_PACKAGE}/${dir}/${precision}/src/configure --prefix=${INSTALL_PACKAGE}/${dir}  \
     CC="mpicc" CXX="mpicxx"\
        --with-qmp=${INSTALL_PACKAGE}/qmp --enable-precision=${precision} --enable-parallel-arch=parscalar \
        --enable-largefile --enable-sse2 --enable-openmp \
        --enable-parallel-io --enable-dml-output-buffering \
        CFLAGS="-fopenmp -D_REENTRANT -g -std=gnu99 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math"\
        CXXFLAGS="-fopenmp -D_REENTRANT -g -std=c++11 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math"
# make  -j 8
# make install
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
BTYPE="cpu"
# git clone --recursive https://github.com/usqcd-software/${dir}.git
# git clone --recursive https://github.com/JeffersonLab/${dir}.git
#git submodule update --init --recursive
mkdir build_${dir}_${BTYPE}_${precision}
cd ${dir}
./autogen.sh
#make clean
./configure --prefix=${INSTALL2}/build_${dir}_${BTYPE}_${precision}
     FC=mpif90 CC="mpicc" CXX="mpicxx"\
        --with-qmp=${INSTALL}/build_qmp --with-qdp=${INSTALL}/build_qdpxx_${precision} --enable-qop-mg \
        --with-qio=${INSTALL}/build_qio --with-qla=${INSTALL}/build_qla --with-qdpc=${INSTALL}/build_qdp \
        --with-qopqdp=${INSTALL}/build_qopqdp --enable-precision=${precision} --enable-parallel-arch=parscalar\
        --enable-sse3 --enable-sse-wilson-dslash \
        CFLAGS="-fopenmp -D_REENTRANT -g -std=gnu99 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math"\
        CXXFLAGS="-fopenmp -D_REENTRANT -g -std=c++11 -O3 -mfpmath=sse -ffast-math -funroll-loops -fprefetch-loop-arrays -fomit-frame-pointer -ftree-vectorize -fassociative-math -fpermissive"
#        --with-quda=${quda_path}\
make
make install
fi
