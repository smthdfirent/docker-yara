# Docker containers for YARA

Dockerfile which allows to install [YARA](https://github.com/VirusTotal/yara) and [yara-python](https://github.com/VirusTotal/yara-python) in an Alpine Linux container.

By default, YARA v4.4.0 and yara-python v4.4.0 will be installed.

You may add YARA rules in the ```rules``` directory. These will be copied into the ```/root/rules``` directory of the container.


## Building a container for version v4.4.0

The following command will build a container for YARA v4.4.0:

```
docker build -t yara-v4.4.0:v4.4.0 .
```

The container can then be run using the following command:

```
docker run -v <path-to-samples>:/tmp/samples -it --rm yara-v4.4.0:v4.4.0
```


## Building a container for a specific version of YARA

A specific version of YARA can also be specified. For example, the following command allows to build a container for YARA v4.3.1:

```
docker build --build-arg yara_version=v4.3.1 -t yara-v4.3.1:v4.3.1 .
```

Then, the container can be run using the following command: 

```
docker run -v <path-to-samples>:/tmp/samples -it --rm yara-v4.3.1:v4.3.1
```


## Remarks

The versions of YARA and yara-python do not always match. For example, there is a tag for version v4.3.2 in the YARA repository, but no tag for the same version in the yara-python repository. **Make sure that the version provided as an argument exist for both repositories.**