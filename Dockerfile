FROM ubuntu:22.04
LABEL org.opencontainers.image.source="https://github.com/loonwerks/INSPECTA-Verus-CI-Action-Container"
ARG RUST_VERSION=1.93.0
ARG VERUS_VERSION=0.2026.01.30.44ebdee

# Fetch some basics
RUN apt-get update -q \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        tar \
        unzip \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}-x86_64-unknown-linux-gnu

ENV PATH="$PATH:/root/.cargo/bin"

RUN curl -JLso verus-install.zip https://github.com/verus-lang/verus/releases/download/release%2F${VERUS_VERSION}/verus-${VERUS_VERSION}-x86-linux.zip

RUN unzip verus-install.zip

RUN rm verus-install.zip
