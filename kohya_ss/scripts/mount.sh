#!/bin/bash

set -Eeuo pipefail

declare -A MOUNTS

MOUNTS["/usr/local/cuda-11.1/targets/x86_64-linux/lib/libnvrtc-builtins.so"]="/usr/local/cuda/lib64/libnvrtc-builtins.so"
MOUNTS["/usr/local/cuda-11.1/targets/x86_64-linux/lib/libnvrtc.so"]="/usr/local/cuda/lib64/libnvrtc.so"
MOUNTS["/usr/local/cuda-11.0/targets/x86_64-linux/lib/libcudart.so.11.0"]="/usr/local/cuda/lib64/libcudart.so"
MOUNTS["/usr/local/cuda-11.0/targets/x86_64-linux/lib/libcudart.so.11.0"]="/usr/local/cuda/lib64/libcudart.so.11.0"

MOUNTS["/usr/local/cuda-11.1/targets/x86_64-linux/lib/libnvrtc-builtins.so"]="/usr/lib/x86_64-linux-gnu/libnvrtc-builtins.so"
MOUNTS["/usr/local/cuda-11.1/targets/x86_64-linux/lib/libnvrtc.so"]="/usr/lib/x86_64-linux-gnu/libnvrtc.so"
MOUNTS["/usr/local/cuda-11.0/targets/x86_64-linux/lib/libcudart.so.11.0"]="/usr/lib/x86_64-linux-gnu/libcudart.so"
MOUNTS["/usr/local/cuda-11.0/targets/x86_64-linux/lib/libcudart.so.11.0"]="/usr/lib/x86_64-linux-gnu/lib64/libcudart.so.11.0"

MOUNTS["${ROOT}/data"]="/data"

# main
#MOUNTS["${ROOT}/models/VAE-approx"]="/data/VAE-approx"

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

