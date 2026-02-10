FROM ubuntu:24.04
LABEL org.opencontainers.image.source="https://github.com/loonwerks/INSPECTA-Verus-CI-Action-Container"

ARG RUST_VERSION=1.93.0
ARG VERUS_VERSION=0.2026.01.30.44ebdee
#ARG RUST_VERSION=1.88.0
#ARG VERUS_VERSION=0.2025.09.25.04e8687
ARG MICROKIT_VERSION=1.4.1
ARG MICROKIT_INSPECTA_VERSION=v1.0

# Fetch some basics
RUN apt-get update -q \
    && apt install -y software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends \
        ca-certificates \
        clang \
        curl \
        default-jre \
        git \
        jq \
        libgmp-dev \
        libssl-dev build-essential \
        libzmq3-dev \
        lld \
        opam \
        pkg-config \
        tar \
        unzip \
        vim \
        wget \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN rm -rf /bin/sh && ln -s /bin/bash /bin/sh

ENV PROVERS_DIR=/usr/local/provers
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN mkdir -p ${PROVERS_DIR}

# Installing Rust
RUN wget -O rustup-init.sh https://sh.rustup.rs \
    && sh rustup-init.sh -y --no-modify-path \
        --default-toolchain=${RUST_VERSION}-x86_64-unknown-linux-gnu \
        --component "rust-src,llvm-tools,rust-analyzer,rustc-dev,rustfmt" \
    && rm rustup-init.sh \
    && rustup target add x86_64-unknown-linux-musl \
    && rustup target add aarch64-unknown-linux-musl \
    && rustup component add rust-src --toolchain ${RUST_VERSION}-x86_64-unknown-linux-gnu

# Installing Verus
RUN wget -O ${PROVERS_DIR}/verus.zip "https://github.com/verus-lang/verus/releases/download/release%2F${VERUS_VERSION}/verus-${VERUS_VERSION}-x86-linux.zip" \
    && unzip ${PROVERS_DIR}/verus.zip -d ${PROVERS_DIR} \
    && rm ${PROVERS_DIR}/verus.zip
ENV PATH=${PROVERS_DIR}/verus-x86-linux:${PATH}

# Building Attestation tools
COPY install-attestation-tools.sh .
RUN chmod +x install-attestation-tools.sh && ./install-attestation-tools.sh

# Build Microkit SDK
COPY install-microkit-sdk.sh .
RUN chmod +x install-microkit-sdk.sh && ./install-microkit-sdk.sh
ENV MICROKIT_SDK=${PROVERS_DIR}/microkit-sdk
ENV MICROKIT_BOARD=qemu_virt_aarch64

# Install a very minimal Sireum dist (e.g. uses container's jre rather than
# downloading a JDK) so that Slash scripts can be run
ENV SIREUM_HOME=${PROVERS_DIR}/Sireum
ENV PATH=${SIREUM_HOME}/bin:${PATH}

RUN mkdir -p ${SIREUM_HOME}/bin/linux/java

RUN ln -s /usr/lib/jvm/java-21-openjdk-amd64/* ${SIREUM_HOME}/bin/linux/java/
RUN wget https://raw.githubusercontent.com/sireum/kekinian/refs/heads/master/versions.properties -O ${SIREUM_HOME}/versions.properties
RUN echo "$(grep "^org.sireum.version.java=" ${SIREUM_HOME}/versions.properties | cut -d'=' -f2)" > ${SIREUM_HOME}/bin/linux/java/VER
RUN wget https://raw.githubusercontent.com/sireum/kekinian/refs/heads/master/bin/init.sh -O ${PROVERS_DIR}/Sireum/bin/init.sh
RUN chmod 700 ${SIREUM_HOME}/bin/init.sh && SIREUM_NO_SETUP=true ${SIREUM_HOME}/bin/init.sh
RUN ${SIREUM_HOME}/bin/sireum --init
RUN rm -rf ${SIREUM_HOME}/bin/linux/cs ${SIREUM_HOME}/bin/linux/cvc* ${SIREUM_HOME}/bin/linux/z3 ${SIREUM_HOME}/lib/jacoco* ${SIREUM_HOME}/lib/marytts_text2wav.jar
RUN rm -rf ${HOME}/Downloads/sireum
RUN echo "eval $(opam env)" >> ${HOME}/.bash_aliases
RUN echo "alias env='env | sort'" >> ${HOME}/.bash_aliases
RUN echo "alias dir='ls -lFGa'" >> ${HOME}/.bash_aliases
RUN echo "alias ..='cd ..'" >> ${HOME}/.bash_aliases

###########################################################

RUN cd ~ && wget https://github.com/dornerworks/microkit/releases/download/inspecta-${MICROKIT_INSPECTA_VERSION}/microkit-sdk-${MICROKIT_VERSION}-inspecta-${MICROKIT_INSPECTA_VERSION}.tar.gz && \
  tar -xzf microkit-sdk-${MICROKIT_VERSION}-inspecta-${MICROKIT_INSPECTA_VERSION}.tar.gz && \
  rm -rf microkit-sdk-${MICROKIT_VERSION}-inspecta-${MICROKIT_INSPECTA_VERSION}.tar.gz microkit && \
  mv microkit-sdk-${MICROKIT_VERSION} microkit

RUN cd ~ && wget https://github.com/mozilla/grcov/releases/download/v0.8.19/grcov-x86_64-unknown-linux-gnu.tar.bz2 && \
  tar -xvf grcov-x86_64-unknown-linux-gnu.tar.bz2 && \
  mv grcov /usr/bin/

ENV PATH=${PATH}:~/verus-x86-linux/
ENV MICROKIT_BOARD=zcu102
ENV MICROKIT_SDK=/root/microkit/
ENV MICROKIT_CONFIG=debug

