# Docker containers for YARA

Dockerfile which allows to install [YARA](https://github.com/VirusTotal/yara) and [yara-python](https://github.com/VirusTotal/yara-python) in an Alpine Linux container.

By default, YARA v4.5.1 and yara-python v4.5.1 will be installed.

You may add YARA rules in the ```rules``` directory. These will be copied into the ```${username}``` home directory of the container (default: ```/home/user/rules```).

You may also add Jupyter notebooks in the ```notebooks``` directory that will be copied into the ```/home/${username}/notebooks```. By default, the container will start a Jupyter notebook server (exposed on port 8080), allowing to use the Python library for YARA in Jupyter notebooks.


## Disclaimer

This Dockerfile is intended **to be used in an isolated analysis environment, for testing or development purpose only**.


## Building a container for version v4.5.1

The following command will build a container for YARA v4.5.1:

```
docker build -t yara:v4.5.1 .
```

The container can then be run using the following command:

```
docker run -v <path-to-samples>:/tmp/samples -it --rm yara:v4.5.1
```

Building the container without the ```run_jupyter``` parameter set to ```false``` will result in jupyter notebook being run at startup. The following command allows to build a container which will not run jupyter notebook:

```
docker build -t yara:v4.5.1 . --build-arg run_jupyter=false
```

One can still start a jupyter notebook server from the container which has been built and access it as long as the appropriate port has been "published" (for example, add ```-p 8080:8080``` to the ```docker run``` command line for port 8080).

```
$ start-notebook.sh
```


## Building a container for a specific version of YARA

A specific version of YARA can also be specified. For example, the following command allows to build a container for YARA v4.3.1:

```
docker build --build-arg yara_version=v4.3.1 -t yara:v4.3.1 .
```

Then, the container can be run using the following command: 

```
docker run -v <path-to-samples>:/tmp/samples -it --rm yara:v4.3.1
```


## Remarks

The versions of YARA and yara-python do not always match. For example, there is a tag for version v4.3.2 in the YARA repository, but no tag for the same version in the yara-python repository. **Make sure that the version provided as an argument exist for both repositories.**