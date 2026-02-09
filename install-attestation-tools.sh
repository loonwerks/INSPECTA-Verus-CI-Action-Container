#! /bin/bash -l

echo "************************************************"
echo "* Building Attestation tools                   *"
echo "************************************************"

pushd ${HOME}

opam init --bare --disable-sandboxing -y
opam switch create . ocaml-system
eval $(opam env)

opam install -y dune coq logs fmt conf-zmq

export AM_REPOS_ROOT=${PROVERS_DIR}/am
mkdir -p ${AM_REPOS_ROOT}/cvm_deps

pushd ${AM_REPOS_ROOT}/
pushd cvm_deps

echo "export AM_REPOS_ROOT=\${PROVERS_DIR}/am" >> ${HOME}/.bashrc

git clone https://github.com/ku-sldg/rocq-candy.git \
    && pushd rocq-candy/ \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/ku-sldg/rocq-json.git \
    && pushd rocq-json/ \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/ku-sldg/copland-spec.git \
    && pushd copland-spec/ \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/ku-sldg/rocq-cli-tools.git \
    && pushd rocq-cli-tools/ \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/Durbatuluk1701/EasyBakeCakeML.git \
    && pushd EasyBakeCakeML \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/Durbatuluk1701/bake.git \
    && pushd bake/ \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/ku-sldg/copland-manifest-tools.git \
    && pushd copland-manifest-tools \
    && dune build \
    && dune install \
    && popd

popd # back to $AM_REPOS_ROOT

git clone https://github.com/ku-sldg/cvm.git \
    && cd cvm \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/ku-sldg/rust-am-clients.git \
    && pushd rust-am-clients \
    && make \
    && popd

git clone https://github.com/ku-sldg/asp-libs \
    && pushd asp-libs \
    && make \
    && popd

git clone https://github.com/ku-sldg/copland-evidence-tools.git \
    && pushd copland-evidence-tools \
    && dune build && dune install \
    && popd

opam clean -a \
    && opam uninstall -y dune conf-zmq \

rm -rf cvm_deps

popd
popd
