#!/bin/bash
#install-container-dep

if [ ! -d "/venv" ];
then
  pip install --upgrade virtualenv
  virtualenv -p python3 /venv
fi
source /venv/bin/activate;
pip install --extra-index-url ${PIP_REPOSITORY} $@ | tee >(ts "%d-%m-%y-%H-%M-%.S" > /docker/build-$(date "+%Y.%m.%d-%H.%M.%S.%N").log)
