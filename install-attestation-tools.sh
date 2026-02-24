#! /bin/bash -l

echo "************************************************"
echo "* Building Attestation tools                   *"
echo "************************************************"

opam init --bare --disable-sandboxing -y
opam switch create . ocaml-system
eval $(opam env)

opam install -y dune coq logs fmt conf-zmq

export AM_REPOS_ROOT=${PROVERS_DIR}/am
mkdir -p ${AM_REPOS_ROOT}/cvm_deps

pushd ${AM_REPOS_ROOT}/
pushd cvm_deps

git clone --branch v0.3.2 --depth=1 https://github.com/ku-sldg/rocq-candy.git \
    && pushd rocq-candy/ \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/ku-sldg/rocq-json.git \
    && pushd rocq-json/ \
    && git checkout 9776532929f528ca8b070bfcb9e519ac40b8be4d \
    && dune build \
    && dune install \
    && popd

git clone --branch v0.3.2 --depth=1 https://github.com/ku-sldg/copland-spec.git \
    && pushd copland-spec/ \
    && dune build \
    && dune install \
    && popd

git clone --branch v0.2.0 --depth=1 https://github.com/ku-sldg/rocq-cli-tools.git \
    && pushd rocq-cli-tools/ \
    && dune build \
    && dune install \
    && popd

git clone --branch v0.5.0 --depth=1 https://github.com/Durbatuluk1701/EasyBakeCakeML.git \
    && pushd EasyBakeCakeML \
    && dune build \
    && dune install \
    && popd

git clone --branch v1.4.0 --depth=1 https://github.com/Durbatuluk1701/bake.git \
    && pushd bake/ \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/ku-sldg/copland-manifest-tools.git \
    && pushd copland-manifest-tools \
    && git checkout 985a840f8819f5465505bb36b00d2d8e0423eb47 \
    && dune build \
    && dune install \
    && popd

popd # back to $AM_REPOS_ROOT

git clone https://github.com/ku-sldg/cvm.git \
    && pushd cvm \
    && git checkout 06af67a54e20d1cb1beeeb88873ed60ce1c7557a \
    && dune build \
    && dune install \
    && popd

git clone https://github.com/ku-sldg/rust-am-clients.git \
    && pushd rust-am-clients \
    && git checkout a5493a0a759d296e0a7bc40d6f601fcbec5da104 \
    && make \
    && popd

git clone https://github.com/ku-sldg/asp-libs \
    && pushd asp-libs \
    && git checkout df2baab5b1ad0a0aee337417d0af47d0723a4b39 \
    && make \
    && popd

git clone --branch v0.2.0 --depth=1 https://github.com/ku-sldg/copland-evidence-tools.git \
    && pushd copland-evidence-tools \
    && dune build && dune install \
    && popd

opam clean -a \
    && opam uninstall -y dune conf-zmq \

rm -rf cvm_deps

popd
popd