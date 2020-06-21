#!/usr/bin/env bash
set -x

CWD=`pwd`
#OPENCV_VERSION=3.3.1

apt-get update && \
apt-get install -q -y --no-install-recommends \
    build-essential cmake libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev libtbb2 libtbb-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libgtk-3-dev libatlas-base-dev gfortran libgphoto2-dev libeigen3-dev libhdf5-dev doxygen libavresample-dev qt5-default libdc1394-22-dev libxine2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libopenblas-dev liblapack-dev liblapacke-dev libgoogle-glog-dev libgflags-dev && \
rm -rf /var/lib/apt/lists/*

git clone -b $OPENCV_VERSION --depth 1 https://github.com/opencv/opencv.git opencv
git clone -b $OPENCV_VERSION --depth 1 https://github.com/opencv/opencv_contrib.git opencv_contrib
cd opencv

mkdir build
cd build

echo "Building OpenCV with Python2 support"
cmake -DCMAKE_BUILD_TYPE=RELEASE \
      -DOPENCV_EXTRA_MODULES_PATH=$CWD/opencv_contrib/modules \
      -DWITH_CUDA=ON \
      -DWITH_OPENGL=ON \
      -DWITH_TBB=ON \
      -DWITH_V4L=ON \
      -DWITH_QT=ON \
      -DBUILD_opencv_xfeatures2d=ON \
      -DBUILD_opencv_java=OFF \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_opencv_apps=OFF \
      -DBUILD_DOCS=OFF \
      -DBUILD_PERF_TESTS=OFF \
      -DBUILD_TESTS=OFF \
      -DBUILD_opencv_dnn=OFF \
      .. || exit 1
make -j$(nproc) || exit 1
make install || exit 1

cd ../..
rm -r opencv opencv_contrib
