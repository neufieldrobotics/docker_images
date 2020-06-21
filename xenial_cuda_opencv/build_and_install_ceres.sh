#!/usr/bin/env bash
set -x

CWD=`pwd`
#CERES_VERSION=1.14.0

apt-get update && \
apt-get install -q -y --no-install-recommends \
    cmake libgoogle-glog-dev libatlas-base-dev libeigen3-dev libsuitesparse-dev && \
rm -rf /var/lib/apt/lists/*

wget http://ceres-solver.org/ceres-solver-$CERES_VERSION.tar.gz
tar -zxvf ceres-solver-$CERES_VERSION.tar.gz

cd ceres-solver-$CERES_VERSION
mkdir build
cd build

cmake .. || exit 1
make -j$(nproc) || exit 1
make -j$(nproc) test || exit 1
make install || exit 1

cd ../..
rm -rf ceres-solver-$CERES_VERSION
rm ceres-solver-$CERES_VERSION.tar.gz
