# syntax=docker/dockerfile:1

############################################################################################################################################################################################
FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04

SHELL ["/bin/bash", "-ceuxo", "pipefail"]
ARG TORCH_COMMAND
ARG PYTORCH_CUDA_ALLOC_CONF
ARG MAX_GCC_VERSION
ARG JAX
ARG TPU
ARG PIP_REPOSITORY
ARG TORCH_CUDA_ARCH_LIST
ARG DS_BUILD_OPS
ARG TRITON_VERSION
ARG DEEPSPEED_VERSION
ARG DEEPSPEED

ENV TRITON_VERSION=${TRITON_VERSION}
ENV DEEPSPEED_VERSION=${DEEPSPEED_VERSION}
ENV DEEPSPEED=${DEEPSPEED}
ENV TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}
ENV DS_BUILD_OPS=${DS_BUILD_OPS}
ENV PIP_REPOSITORY=${PIP_REPOSITORY}
ENV TORCH_COMMAND=${TORCH_COMMAND}
ENV PYTORCH_CUDA_ALLOC_CONF=${PYTORCH_CUDA_ALLOC_CONF}
ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_PREFER_BINARY=1
ENV PIP_NO_CACHE_DIR=1
ENV ROOT=/koyah_ss
ENV TF_ENABLE_ONEDNN_OPTS=1

ENV RUNNER='echo Please specify the command line runner from the composer; ARGS: '
ENV RUN_ARGS=""

RUN <<EOF
# apt for general container dependencies
apt-get update 
apt-get install curl unzip gnupg2 moreutils git tk libglib2.0-0 libaio-dev gcc-$MAX_GCC_VERSION g++-$MAX_GCC_VERSION -y
update-alternatives --install /usr/bin/gcc gcc $(which gcc-$MAX_GCC_VERSION) 1
update-alternatives --install /usr/bin/g++ g++ $(which g++-$MAX_GCC_VERSION) 1
apt-get full-upgrade -y
apt-get autopurge -y
EOF

RUN <<EOF
# python
apt-get update
. /etc/os-release
echo "
deb https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu ${VERSION_CODENAME} main 
deb-src https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu ${VERSION_CODENAME} main 
" > /etc/apt/sources.list.d/python.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776
apt-get update

apt-get install -y python3.10 python3.10-dev python3.10-tk python3.10-venv
update-alternatives --install /usr/bin/python python $(which python3.10) 1

curl https://bootstrap.pypa.io/get-pip.py | python
update-alternatives --install /usr/bin/pip pip $(which pip3) 1
EOF

COPY ./data/libs/*.deb /docker/
RUN <<EOF
# cuda
#. /etc/os-release
ID="ubuntu"
VERSION_ID="20.04"
curl -O /etc/apt/preferences.d/cuda-repository-pin-600 https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID/\./}/x86_64/cuda-${ID}${VERSION_ID/\./}.pin
echo "
deb https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID/\./}/x86_64 /
" > /etc/apt/sources.list.d/cuda.list

VERSION_ID="18.04"
echo "
deb https://developer.download.nvidia.com/compute/machine-learning/repos/${ID}${VERSION_ID/\./}/x86_64 /
" > /etc/apt/sources.list.d/tensorRT.list

apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID/\./}/x86_64/7fa2af80.pub
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/${ID}${VERSION_ID/\./}/x86_64/3bf863cc.pub

apt-get update
apt install /docker/*.deb -y
EOF

############################################################################################################################################################################################
WORKDIR ${ROOT}

RUN <<EOF
git clone https://github.com/P2Enjoy/kohya_ss.git ${ROOT}

pip install --upgrade virtualenv
virtualenv -p python3 ${ROOT}/kohya_venv/
EOF

COPY ./data/*.whl /docker/
COPY ./scripts/install-container-dep.sh ./data/*-requirements.txt /docker/
RUN <<EOF
# tensorflow, torch, torchvision, torchaudio
$TORCH_COMMAND
EOF

RUN <<EOF
# xformers
/bin/bash /docker/install-container-dep.sh --upgrade-strategy only-if-needed /docker/xformers-*.whl
EOF

RUN <<EOF
# deepspeed
pip install triton==${TRITON_VERSION}
[[ ! -z "${DEEPSPEED}" ]] && [ "${DEEPSPEED}"="True" ] && TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST} DS_BUILD_OPS=${DS_BUILD_OPS} DS_BUILD_SPARSE_ATTN=0 pip install deepspeed==${DEEPSPEED_VERSION}
EOF

RUN <<EOF
# Build requirements
/bin/bash /docker/install-container-dep.sh --use-pep517 --upgrade -r ${ROOT}/requirements.txt
EOF

#################################################################################################################################################

#ENV TPU_LIBRARY_PATH="/stable-diffusion-webui/venv/lib/python3.10/site-packages/libtpu/"
RUN <<EOF
# jax/tpu
[[ ! -z "${TPU}" ]] && [ "${TPU}"="True" ] && pip install tpu -f https://storage.googleapis.com/jax-releases/libtpu_releases.html
[[ ! -z "${JAX}" ]] && [ "${JAX}"="True" ] && pip install "jax[cuda11_cudnn805]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
EOF

ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda-11.1/targets/x86_64-linux/lib/:/usr/local/cuda-11.0/targets/x86_64-linux/lib"
RUN <<EOF
# fix LDCONFIG
ldconfig
EOF

#################################################################################################################################################
COPY ./scripts/*.sh /docker/
RUN <<EOF
chmod +x /docker/{run,mount,debug}.sh
#sed -i 's/in_app_dir = .*/in_app_dir = True/g' /usr/local/lib/python3.10/site-packages/gradio/routes.py
EOF

# Kohya gui
EXPOSE 7680
# Tensorboard
EXPOSE 6006

ENTRYPOINT $RUNNER $RUN_ARGS

