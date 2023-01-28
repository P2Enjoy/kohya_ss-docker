#!/bin/bash

set -Eeuo pipefail

. /docker/mount.sh

# Load environment
source ${ROOT}/kohya_venv/bin/activate

# check python
python --version
# check libraries
pip freeze | tee /data/requirements.txt
#check tensors
python <<EOF

import tensorflow
from tensorflow.python.compiler.tensorrt import trt_convert as trt

print('tensorflow.__version__')
print(tensorflow.__version__)
print('trt.trt_utils._pywrap_py_utils.get_linked_tensorrt_version()')
print(trt.trt_utils._pywrap_py_utils.get_linked_tensorrt_version())
print('trt.trt_utils._pywrap_py_utils.get_loaded_tensorrt_version()')
print(trt.trt_utils._pywrap_py_utils.get_loaded_tensorrt_version())

import torch
for devid in range(0,torch.cuda.device_count()):
        print('torch.cuda.get_device_name()')
        print(torch.cuda.get_device_name(devid))
EOF

cd ${ROOT} && git pull
if [[ ! -z "${ACCELERATE}" ]] && [ "${ACCELERATE}" = "True" ] && [ -x "$(command -v accelerate)" ]
then
    echo "Accelerating SD with distributed GPU+CPU..."
    accelerate launch --num_cpu_threads_per_process=6 $@
else
    python -u $@
fi

echo "Shutting down in 10 seconds"
sleep 10
