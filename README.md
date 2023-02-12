# kohya_ss-docker
This is the tandem repository to exploit on linux the kohya_ss training webui converted to Linux.  

Read the data sections for [wheels](kohya_ss/data) and [packages](kohya_ss/data/libs) prior to compiling the image or IT WILL FAIL.

## Nvidia Docker Extensions

You will need the docker nvidia extensions, please refer to the installations details here: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-nvidia-container-toolkit

## TK and Xorgs

Remember to allow docker hosts to clients to your X server.

```bash
# Unsecure way to do (I take no responsability if you do this way) !! 
# You should add the exact host but I leave that to you.
xhost +
```

Once you have compiled (or downloaded) the wheels and the debian packages, you can pretty just run it via the `docker compose --profile kohya up --build` and wait for the build to finish.  
A message should notify the build is complete and you can access the gui via the link on the console.  
```bash
kohya-docker-kohya-1  | Running on local URL:  http://127.0.0.1:7680
```

Happy training on Linux!!!  

