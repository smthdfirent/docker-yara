ARG yara_version="v4.5.1"
ARG install_dir="/opt/tools"
ARG username="user"

FROM alpine:latest
ARG yara_version
ARG install_dir
ARG username

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
    py3-pip \
    py3-setuptools \
    py3-virtualenv \
    vim

# Add a user and switch to user
RUN adduser --disabled-password ${username}

# Create the installation directory and switch to ${username}
RUN mkdir ${install_dir}
RUN chown ${username}:${username} ${install_dir}
USER ${username}
WORKDIR ${install_dir}

# Clone the YARA repository, and switch to the appropriate version
RUN git clone https://github.com/VirusTotal/yara.git
WORKDIR ${install_dir}/yara
RUN git checkout tags/${yara_version}

# Build and install YARA
RUN ./bootstrap.sh && \
    ./configure --with-crypto --enable-dex --enable-dotnet --enable-macho && \
    make
USER root
RUN make install

# Clone the yara-python repository, and switch to the appropriate version
USER ${username}
WORKDIR ${install_dir}
RUN git clone --recursive https://github.com/VirusTotal/yara-python.git
WORKDIR ${install_dir}/yara-python
RUN git checkout tags/${yara_version} && git submodule update --init --recursive
RUN python setup.py build --dynamic-linking

# Build and install yara-python
USER root
RUN python setup.py install

# Copy the YARA rules that may be in the rules directory
COPY rules/ /home/${username}/rules/
RUN chown -R ${username}:${username} /home/${username}/rules/

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

# Switch to ${username}
USER ${username}
WORKDIR /home/${username}/

