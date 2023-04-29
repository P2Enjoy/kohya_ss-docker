# kohya_ss-docker
This is the tandem repository to exploit on linux the kohya_ss training webui converted to Linux.  

Read the data sections for [wheels](kohya_ss/data) and [packages](kohya_ss/data/libs) prior to compiling the image or IT WILL FAIL.

# Google collab version
Here is the OFFICIAL Google Collab implementation: 
- https://gist.github.com/martinobettucci/545adb371fcc6a72e8a72e66eae482dc

# Offline on your own hardware version

## Compile Tensorflow and XFormer for your architecture

There is a dockerised package of Stable Diffusion AUTOMATIC1111 we maintains here: [Stable Diffusion AUTOMATIC1111 P2Enjoy Docker Version](https://github.com/P2Enjoy/stable-diffusion-docker).  
You may find the profiles to compile tensorflows and xformers there althought there is no (yet) any public instructions on how-to do so: you're free to try to figure it out by yourself or patiently wait until we will find the time to make a guide.  

## Nvidia Docker Extensions

You will need the docker nvidia extensions, please refer to the installations details here: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-nvidia-container-toolkit

## TK and Xorgs

Remember to allow docker hosts to clients to your X server.

```bash
# Somewhat unsecure way to do (I take no responsability if you do this way).
# You should add the exact host but I leave that to you.
xhost local:docker
```

Once you have compiled (or downloaded) the wheels and the debian packages, you can pretty just run it via the `docker compose --profile kohya up --build` and wait for the build to finish.  
A message should notify the build is complete and you can access the gui via the link on the console.  
```bash
kohya-docker-kohya-1  | Running on local URL:  http://127.0.0.1:7680
```

Happy training on Linux!!!  

