# Install gtsam
set -x
CWD=`pwd`
git clone --depth 1 https://github.com/borglab/gtsam gtsam

apt-get update && \
apt-get install -q -y --no-install-recommends \
    libtbb-dev && \
rm -rf /var/lib/apt/lists/*

cd gtsam

pip install -r cython/requirements.txt

mkdir build
cd build

cmake -DGTSAM_ALLOW_DEPRECATED_SINCE_V4=OFF \
      -DGTSAM_INSTALL_MATLAB_TOOLBOX=OFF \
      -DGTSAM_INSTALL_CYTHON_TOOLBOX=ON \
      -DCMAKE_INSTALL_PREFIX=$CWD/gtsam_bin \
      -DGTSAM_BUILD_UNSTABLE=OFF \
      .. || exit 1

echo Docker Memory Limit: $(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
echo Total Memory: $(awk '/^MemTotal:/ { print $2; }' /proc/meminfo)

echo BUILD_LOC $BUILD_LOC
# Dockerhub has a memory limit of 2G, so build with fewer processes

if [ "${BUILD_LOC}" == "DOCKERHUB" ]; then
    echo "Variable BUILD_LOC is set to ${BUILD_LOC}, this is being built on docker hub";
    sleep 3
    make -j1 || exit 1
else
    echo "Variable BUILD_LOC not set to DOCKERHUB, this is being built locally";
    sleep 3
    make -j$(nproc) || exit 1  
fi

make install || exit 1

cd ../..
