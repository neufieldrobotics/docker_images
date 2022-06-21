# Install gtsam
set -x
CWD=`pwd`
git clone https://github.com/borglab/gtsam gtsam

apt-get update && \
apt-get install -q -y --no-install-recommends \
    libtbb-dev && \
rm -rf /var/lib/apt/lists/*

cd gtsam
#git checkout 4.1.1

pip install -r python/requirements.txt 

ln -sf /usr/bin/x86_64-linux-gnu-ld.gold /usr/bin/ld

mkdir build
cd build

cmake -DGTSAM_BUILD_PYTHON=1 \
      -DCMAKE_INSTALL_PREFIX=$CWD/gtsam_bin \
      -DGTSAM_BUILD_UNSTABLE=OFF \
      -DCMAKE_C_FLAGS="--param ggc-min-expand=20 --param ggc-min-heapsize=32768" \
      -DCMAKE_CXX_FLAGS="--param ggc-min-expand=20 --param ggc-min-heapsize=32768" \
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
make python-install || exit 1

cd ../..

ln -sf /usr/bin/x86_64-linux-gnu-ld.bfd /usr/bin/ld
