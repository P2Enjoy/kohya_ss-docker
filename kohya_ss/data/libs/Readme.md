## What's here?

You should download and put here the relevant libnvinfer*7.deb as to be installed offline in your container.  
For some strange reasons, the CUDA package seems not to install these but are recommended by Tensorflow:
- libnvinfer7_7.2.2-1+cuda11.1_amd64
- libnvinfer-dev_7.2.2-1+cuda11.1_amd64
- libnvinfer-plugin7_7.2.2-1+cuda11.1_amd64
- libnvinfer-plugin-dev_7.2.2-1+cuda11.1_amd64

Use these [NVidia Debian Package website 1](https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/) and [NVidia Debian Package website 2](https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/) to search and download the library is you're not willing to compile them by yourself, then put the *.deb here and compile the docker image.