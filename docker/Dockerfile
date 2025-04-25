FROM busybox:1.36.1 AS wasi-sdk

ARG WASI_SDK_MAJOR_VERSION=22
ARG WASI_SDK_MINOR_VERSION=0

WORKDIR /workspace

RUN wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-$WASI_SDK_MAJOR_VERSION/wasi-sdk-$WASI_SDK_MAJOR_VERSION.$WASI_SDK_MINOR_VERSION-linux.tar.gz

RUN tar xvf wasi-sdk-$WASI_SDK_MAJOR_VERSION.$WASI_SDK_MINOR_VERSION-linux.tar.gz

RUN mv wasi-sdk-$WASI_SDK_MAJOR_VERSION.$WASI_SDK_MINOR_VERSION /output


FROM busybox:1.36.1 AS wasmtime

ARG WASMTIME_VERSION=22.0.0

ENV REPO_URL=https://github.com/bytecodealliance/wasmtime/releases/download/v$WASMTIME_VERSION

RUN wget $REPO_URL/wasmtime-v$WASMTIME_VERSION-x86_64-linux.tar.xz

RUN mkdir -p /output && tar -C /output --strip-components 1 -Jxvf wasmtime-v$WASMTIME_VERSION-x86_64-linux.tar.xz

WORKDIR /output/adapter-modules

RUN wget $REPO_URL/wasi_snapshot_preview1.command.wasm  &&\
  wget $REPO_URL/wasi_snapshot_preview1.proxy.wasm      &&\
  wget $REPO_URL/wasi_snapshot_preview1.reactor.wasm


FROM busybox:1.36.1 AS rc

WORKDIR /output

COPY --from=wasi-sdk /output wasi-sdk

COPY --from=wasmtime /output wasmtime


FROM rust:1.85.0-bookworm

RUN rustup target add wasm32-wasip1

RUN sed -i 's/deb.debian.org/mirrors.tencent.com/g' /etc/apt/sources.list.d/debian.sources &&\
  sed -i 's|security.debian.org/debian-security|mirrors.tencent.com/debian-security|g' /etc/apt/sources.list.d/debian.sources

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg &&\
  echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-18 main" | tee /etc/apt/sources.list.d/llvm.list

RUN apt update && apt install -y gdb lldb-18 tar && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH=/opt/wasi-sdk/bin:/opt/wasmtime:$PATH

COPY --from=rc /output /opt
