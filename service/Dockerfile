# syntax=docker/dockerfile:1
ARG pyimage
ARG pyver

############################################################################################################################################################################################
FROM $pyimage as base

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ARG TORCH_CUDA_ARCH_LIST
ARG CUDNN_VERSION
ARG NVCC_FLAGS
ARG pyver
ARG PIP_REPOSITORY

ENV NVCC_FLAGS=${NVCC_FLAGS}
ENV TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_PREFER_BINARY=1
ENV PIP_REPOSITORY=${PIP_REPOSITORY}
ENV PIP_NO_CACHE_DIR=1
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

RUN <<EOF
# apt for general container dependencies
apt-get update 
apt-get install fonts-dejavu-core rsync git jq moreutils dos2unix gcc g++ -y
apt-get full-upgrade -y
apt-get autopurge -y
EOF

RUN <<EOF
# apt for extensions/custom scripts
apt-get install curl unzip gnupg2 moreutils git tk libglib2.0-0 libaio-dev gcc g++ wget -y
EOF

RUN <<EOF
# cuda
wget https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
export VERSION_CODENAME="$(cat /etc/*-release | fgrep VERSION_CODENAME | cut -d'=' -f2)"
export VERSION_ID="$(cat /etc/*-release | fgrep VERSION_ID | cut -d'=' -f2)"
echo "
# Full debian sources
deb http://deb.debian.org/debian $VERSION_CODENAME main contrib
deb http://deb.debian.org/debian $VERSION_CODENAME main non-free
deb http://deb.debian.org/debian $VERSION_CODENAME main non-free-firmware

# Nvidia Official channel (not yet available for debian12)
deb https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/ /

" >> /etc/apt/sources.list
apt-get update
EOF

COPY ./scripts/install-container-dep.sh /docker/
RUN <<EOF
# cuda cudnn + cutlass + tensorrt
/bin/bash /docker/install-container-dep.sh nvidia-cudnn-cu11==${CUDNN_VERSION}
/bin/bash /docker/install-container-dep.sh cutlass
/bin/bash /docker/install-container-dep.sh install nvidia-tensorrt
EOF

############################################################################################################################################################################################
FROM base as kohya_base

SHELL ["/bin/bash", "-ceuxo", "pipefail"]

ARG TORCH_COMMAND
ARG XFORMERS_COMMAND
ARG TENSORFLOW_COMMAND
ARG DS_BUILD_OPS
ARG pyver

ARG DEEPSPEED
ARG DEEPSPEED_VERSION
ARG TORCH_CUDA_ARCH_LIST
ARG TRITON_VERSION
ARG JAX
ARG TPU

ENV pyver=${pyver}

ENV ROOT=/koyah_ss

ENV CUDART_PATH=/venv/lib/python${pyver}/site-packages/nvidia/cuda_runtime
ENV CUDNN_PATH=/venv/lib/python${pyver}/site-packages/nvidia/cudnn
ENV TENSORRT_PATH=/venv/lib/python${pyver}/site-packages/tensorrt
ENV LD_LIBRARY_PATH=$TENSORRT_PATH:$CUDNN_PATH/lib:$CUDART_PATH/lib:$LD_LIBRARY_PATH

RUN <<EOF
git clone https://github.com/P2Enjoy/kohya_ss.git ${ROOT}
cd ${ROOT}
python -m ensurepip
EOF

WORKDIR ${ROOT}

RUN <<EOF
# Build requirements
/bin/bash /docker/install-container-dep.sh setuptools
/bin/bash /docker/install-container-dep.sh wheel
/bin/bash /docker/install-container-dep.sh ninja
/bin/bash /docker/install-container-dep.sh pyngrok
EOF

#COPY ./data/*.whl /docker/
RUN <<EOF
# tensorflow
$TENSORFLOW_COMMAND
EOF

RUN <<EOF
# torch, torchvision, torchaudio
$TORCH_COMMAND
EOF

RUN <<EOF
# xformers
$XFORMERS_COMMAND
EOF

RUN <<EOF
# deepspeed
/bin/bash /docker/install-container-dep.sh triton==${TRITON_VERSION}
if [[ ! -z "${DEEPSPEED}" ]] && [[ "${DEEPSPEED}" == "True" ]]
then
  export NVCC_FLAGS=${NVCC_FLAGS}
  export TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}
  export DS_BUILD_OPS=${DS_BUILD_OPS}
  export DS_BUILD_SPARSE_ATTN=0 
  /bin/bash /docker/install-container-dep.sh deepspeed==${DEEPSPEED_VERSION}
fi
EOF

ENV TPU_LIBRARY_PATH="/venv/lib/python${pyver}/site-packages/libtpu/"
RUN <<EOF
#jax/tpu
if [[ ! -z "${TPU}" ]] && [[ "${TPU}" == "True" ]]
then
  /bin/bash /docker/install-container-dep.sh tpu -f https://storage.googleapis.com/jax-releases/libtpu_releases.html
fi
if [[ ! -z "${JAX}" ]] && [[ "${JAX}" == "True" ]]
then
  /bin/bash /docker/install-container-dep.sh "jax[cuda11_cudnn805]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
fi
EOF

#################################################################################################################################################
FROM kohya_base as kohya_cuda

ARG CUDA_VERSION
ARG pyver

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=$PATH:$CUDA_HOME/bin
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib:$LD_LIBRARY_PATH

RUN <<EOF
# Hotfix for libnvinfer7
ln -s $TENSORRT_PATH/libnvinfer.so.8 $TENSORRT_PATH/libnvinfer.so.7
ln -s $TENSORRT_PATH/libnvinfer_plugin.so.8 $TENSORRT_PATH/libnvinfer_plugin.so.7
EOF

RUN <<EOF
# cuda driver update
apt-get update
apt-get -y install $CUDA_VERSION
EOF

############################################################################################################################################################################################
FROM kohya_cuda as kohya

WORKDIR ${ROOT}

RUN <<EOF
# installing kohya trainer scripts
git pull --rebase
/bin/bash /docker/install-container-dep.sh --use-pep517 --upgrade -r ${ROOT}/requirements.txt
EOF

#################################################################################################################################################
COPY ./scripts/*.sh /docker/
RUN <<EOF
chmod +x /docker/{run,mount,debug}.sh
EOF

# Kohya gui
EXPOSE 7680
# Tensorboard
EXPOSE 6006

ENTRYPOINT $RUNNER $RUN_ARGS

