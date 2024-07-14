ARG yara_version="v4.5.1"
ARG install_dir="/opt/tools"
ARG username="user"
ARG run_jupyter="true"

FROM alpine:latest
ARG yara_version
ARG install_dir
ARG username
ARG run_jupyter

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

# Add a user
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

# Set up a virtual environment and install jupyter
USER ${username}
WORKDIR /home/${username}/
ENV VIRTUAL_ENV=/home/${username}/venv
RUN python3 -m venv venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
RUN . venv/bin/activate && pip install ${install_dir}/yara-python/ && pip install jupyter

# Copy the YARA rules and the notebooks
USER root
COPY --chown=${username} rules/ /home/${username}/rules/
COPY --chown=${username} notebooks/ /home/${username}/notebooks/

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
    git
RUN rm -rf /var/cache/apk/*
RUN rm -rf ${install_dir}

# Switch to ${username} and create startup scripts
USER ${username}
WORKDIR /home/${username}/
RUN mkdir scripts/
ENV PATH="$PATH:/home/${username}/scripts"
RUN echo -e "#!/bin/sh\nexec jupyter notebook --ip=0.0.0.0 --port=8080 --no-browser" > scripts/start-notebook.sh
RUN chmod +x scripts/start-notebook.sh
RUN if test "${run_jupyter}" = "true"; then echo -e "#!/bin/sh\nstart-notebook.sh" > scripts/start.sh; else echo -e "#!/bin/sh\n/bin/sh" > scripts/start.sh; fi
RUN chmod +x scripts/start.sh
CMD [ "start.sh" ]

