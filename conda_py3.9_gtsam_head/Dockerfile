FROM continuumio/miniconda3:latest
LABEL maintainers="Vikrant Shah <shah.vi@northeastern.edu>"

# Set BUILD_LOC to DOCKERHUB when performing automated build
ARG BUILD_LOC
ENV BUILD_LOC=$BUILD_LOC

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.9
#ENV OPENCV_VERSION=3.3.1

# Make RUN commands use `bash --login`:
SHELL ["/bin/bash", "--login", "-c"]

RUN echo BUILD_LOC $BUILD_LOC

# install basic packages
RUN apt-get update && \
    apt-get install -q -y --no-install-recommends \
    build-essential tree wget cmake vim nano git ffmpeg libsm6 libxext6 && \
    rm -rf /var/lib/apt/lists/*

COPY ./*.yml /

RUN conda update -n base -c defaults conda \
    && conda env create -f conda_env.yml \
    && conda clean -afy \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete

# Initialize conda in bash config fiiles:
RUN conda init bash

# Activate the environment, and make sure it's activated:
RUN echo "conda activate py39_env" >> ~/.bashrc

COPY ./*.sh /

RUN ./build_and_install_gtsam.sh

RUN echo "CONDA_PREFIX" $CONDA_PREFIX

RUN python -m gtsam.examples.VisualISAM2Example

CMD ["bash"]
