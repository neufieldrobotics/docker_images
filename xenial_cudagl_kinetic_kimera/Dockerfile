FROM nvidia/cudagl:10.2-devel-ubuntu16.04
LABEL maintainers="Vikrant Shah <shah.vi@northeastern.edu>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV ROS_DISTRO kinetic
ENV OPENCV_VERSION=3.3.1

# install basic packages
RUN apt-get update && \
    apt-get install -q -y --no-install-recommends \
    build-essential tree wget dirmngr gnupg2 vim nano git ssh x11-apps mesa-utils && \
    rm -rf /var/lib/apt/lists/*

# install ROS
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros1-latest.list

# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-$ROS_DISTRO-desktop-full=1.3.2-0* ros-$ROS_DISTRO-image-transport ros-$ROS_DISTRO-image-geometry ros-$ROS_DISTRO-pcl-ros ros-$ROS_DISTRO-cv-bridge \
    ros-$ROS_DISTRO-catkin python-wstool python-catkin-tools build-essential python-rosdep python-rosinstall python-vcstools \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO

# Add credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN chmod 600 ~/.ssh/id_rsa

# Make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

# Install Kimera Prerequisities

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake build-essential apt-utils unzip pkg-config autoconf libboost-all-dev \
    libjpeg-dev libpng12-dev libtiff5-dev libvtk6-dev libgtk2.0-dev \
    libatlas-base-dev gfortran libparmetis-dev automake libtool \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ~/catkin_ws/src && cd ~/catkin_ws/ && \
    catkin init && \
    catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DGTSAM_USE_SYSTEM_EIGEN=ON && \
    catkin config --merge-devel

# Add workspace to bashrc for automatic sourcing of workspace.
RUN echo 'source ~/catkin_ws/devel/setup.bash' >> ~/.bashrc

# Clone repo
RUN cd ~/catkin_ws/src && \
    git clone --depth 1 https://github.com/MIT-SPARK/Kimera-VIO-ROS.git

# Install dependencies from rosinstall file using wstool
RUN cd ~/catkin_ws/src && \
    wstool init && \
    wstool merge Kimera-VIO-ROS/install/kimera_vio_ros_https.rosinstall && \
    wstool update

# For 16.04 cmake, we need to comment this line in dbow2_catkin
RUN sed -i '/GIT_PROGRESS 1$/s/^/#/' ~/catkin_ws/src/dbow2_catkin/CMakeLists.txt 

# We will use opencv from ROS so delete the one from wstools
RUN rm -rf ~/catkin_ws/src/opencv3_catkin/

# Use develop branch for gtsam
RUN cd ~/catkin_ws/src/gtsam && git checkout develop

# Compile code
RUN /bin/bash -c "source /opt/ros/$ROS_DISTRO/setup.bash && cd ~/catkin_ws/src && catkin build"

COPY ./*.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
