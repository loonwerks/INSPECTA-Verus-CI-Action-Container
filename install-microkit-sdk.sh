#! /bin/bash -l

MICROKIT_DIR=${PROVERS_DIR}/microkit

mkdir -p ${MICROKIT_DIR}

cd ${MICROKIT_DIR}

apt-get update
apt install -y \
    gcc-riscv64-unknown-elf \
    cmake \
    pandoc \
    device-tree-compiler \
    ninja-build \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    libxml2-utils \
    python3.12 \
    python3-pip \
    python3.12-venv \
    qemu-system-arm \
    qemu-system-misc

wget -O aarch64-toolchain.tar.gz \
    https://sel4-toolchains.s3.us-east-2.amazonaws.com/arm-gnu-toolchain-12.2.rel1-x86_64-aarch64-none-elf.tar.xz%3Frev%3D28d5199f6db34e5980aae1062e5a6703%26hash%3DF6F5604BC1A2BBAAEAC4F6E98D8DC35B

tar xf aarch64-toolchain.tar.gz

rm ${MICROKIT_DIR}/aarch64-toolchain.tar.gz

PATH=${MICROKIT_DIR}/arm-gnu-toolchain-12.2.rel1-x86_64-aarch64-none-elf/bin:${PATH}:.

git clone https://github.com/Ivan-Velickovic/seL4 --branch microkit_domains

git clone https://github.com/JE-Archer/microkit --branch domains
cd microkit

python3.12 -m venv pyenv
./pyenv/bin/pip install --upgrade pip setuptools wheel
./pyenv/bin/pip install -r requirements.txt
./pyenv/bin/python build_sdk.py --experimental-domain-support --sel4=${MICROKIT_DIR}/seL4 --configs debug

microkit_sdk=$(find ${MICROKIT_DIR}/microkit/release/ -type d -name microkit-sdk*)
mv ${microkit_sdk} ${PROVERS_DIR}/microkit-sdk

cd ${HOME}
rm -rf ${MICROKIT_DIR}

# Remove apt packages no longer needed after sdk build
apt purge --auto-remove -y \
    pandoc texlive-latex-base texlive-latex-recommended texlive-fonts-recommended texlive-fonts-extra libxml2-utils \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/
