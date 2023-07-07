#!/bin/bash

set -Eeuo pipefail

. /docker/mount.sh

# Load environment
source "/venv/bin/activate"

# Hack ProtoBuffer
wget https://raw.githubusercontent.com/protocolbuffers/protobuf/main/python/google/protobuf/internal/builder.py -O /venv/lib/python${pyver}/site-packages/google/protobuf/internal/builder.py

# check python
python --version
# check libraries
pip freeze | tee /data/requirements.txt
#check tensors
python <<EOF
import torch
for devid in range(0,torch.cuda.device_count()):
        print('torch.cuda.get_device_name()')
        print(torch.cuda.get_device_name(devid))

import tensorflow
from tensorflow.python.compiler.tensorrt import trt_convert as trt

print('tensorflow.__version__')
print(tensorflow.__version__)
print('trt.trt_utils._pywrap_py_utils.get_linked_tensorrt_version()')
print(trt.trt_utils._pywrap_py_utils.get_linked_tensorrt_version())
print('trt.trt_utils._pywrap_py_utils.get_loaded_tensorrt_version()')
print(trt.trt_utils._pywrap_py_utils.get_loaded_tensorrt_version())
EOF

# Workaround for memory leak
if [[ ! -L "/usr/lib/x86_64-linux-gnu/libtcmalloc.so" ]]; then
  apt-get -y install libgoogle-perftools-dev
fi
export LD_PRELOAD=libtcmalloc.so

cd "${ROOT}" && bash ./upgrade.sh
if [[ -n "${ACCELERATE}" ]] && [[ "${ACCELERATE}" = "True" ]] && [[ -x "$(command -v accelerate)" ]]
then
    echo "Accelerating SD with distributed GPU+CPU..."
    accelerate launch --num_cpu_threads_per_process=6 $@
else
    python -u $@
fi

echo "Shutting down in 10 seconds"
sleep 10
