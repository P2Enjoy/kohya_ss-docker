#!/bin/bash
#install-container-dep

source ${ROOT}/kohya_venv/bin/activate
if [ ! -f "/docker/kohya-requirements.txt" ]; 
then
  pip install --extra-index-url ${PIP_REPOSITORY} $@
fi;
