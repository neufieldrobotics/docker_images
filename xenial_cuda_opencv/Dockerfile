FROM nvidia/cuda:10.2-devel-ubuntu16.04
LABEL maintainers="Vikrant Shah <shah.vi@northeastern.edu>"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV ROS_DISTRO kinetic
ENV OPENCV_VERSION=3.3.1
ENV CERES_VERSION=1.14.0

# install basic packages
RUN apt-get update && \
    apt-get install -q -y --no-install-recommends \
    build-essential tree wget dirmngr gnupg2 vim nano git && \
    rm -rf /var/lib/apt/lists/*

# install ROS
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros1-latest.list

# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-$ROS_DISTRO-ros-base=1.3.2-0* ros-$ROS_DISTRO-image-transport build-essential python-rosdep python-rosinstall python-vcstools \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO

COPY ./*.sh /

RUN ./build_and_install_ceres.sh

RUN ./build_and_install_opencv.sh

RUN apt-get update && \
    apt-get install -q -y --no-install-recommends \
    python-pip && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip && \
    pip install numpy==1.15.2 jupyter Pillow scipy tensorflow-gpu==1.12.0

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
