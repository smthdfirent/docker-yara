ARG yara_version="v4.4.0"

FROM alpine:latest
ARG yara_version

# Install required packages
RUN apk add --no-cache \
    git \
    autoconf \
    automake \
    libtool \
    make \
    build-base \
    pkgconfig \
    openssl-dev \
    linux-headers \
    python3 \
    python3-dev \
    py3-setuptools

# Clone the YARA repository, and switch to the appropriate version
WORKDIR /opt
RUN git clone --recursive https://github.com/VirusTotal/yara.git
WORKDIR /opt/yara
RUN git checkout tags/${yara_version}

# Build and install YARA
RUN ./bootstrap.sh && \
    ./configure --with-crypto --enable-dex --enable-dotnet --enable-macho && \
    make && \
    make install

# Clone the yara-python repository, and switch to the appropriate version
WORKDIR /opt
RUN git clone --recursive https://github.com/VirusTotal/yara-python
WORKDIR /opt/yara-python
RUN git checkout tags/${yara_version}

# Build and install yara-python
RUN python setup.py build --dynamic-linking
RUN python setup.py install

# Clean up
RUN apk del \
    py3-setuptools \
    python3-dev \
    linux-headers \
    openssl-dev \
    pkgconfig \
    build-base \
    make \
    libtool \
    automake \
    autoconf \
    git \
    rm -rf /var/cache/apk/* /opt/yara /opt/yara-python

# Set the working directory to /root
WORKDIR /root

# Copy the YARA rules that may be in the rules directory
COPY rules/ /root/rules/

