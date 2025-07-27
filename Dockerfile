FROM python:3.11-bookworm
RUN sed -i \
  's|http://deb.debian.org/debian-security|http://snapshot.debian.org/archive/debian-security/20250717T060459Z|g' \
  /etc/apt/sources.list.d/debian.sources && \
  sed -i \
  's|http://deb.debian.org/debian|http://snapshot.debian.org/archive/debian/20250718T082802Z|g' \
  /etc/apt/sources.list.d/debian.sources && \
  echo "Acquire::Check-Valid-Until false;" | tee -a /etc/apt/apt.conf.d/no-check-valid-until && \
  apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  r-base r-base-dev r-cran-mgcv r-cran-proto r-cran-argparser \
  cmake gcc make wget curl ca-certificates autoconf ccache \
  clang g++ gdb git \
  libbenchmark-dev libboost-filesystem-dev libboost-system-dev libbrotli-dev \
  libbz2-dev libc-ares-dev libcurl4-openssl-dev libgflags-dev \
  libgmock-dev libgoogle-glog-dev libgrpc++-dev libidn2-dev libkrb5-dev \
  libldap-dev liblz4-dev libnghttp2-dev libprotobuf-dev libprotoc-dev \
  libpsl-dev libre2-dev librtmp-dev libsnappy-dev libsqlite3-dev \
  libssh-dev libssh2-1-dev libssl-dev libthrift-dev libutf8proc-dev \
  libxml2-dev libzstd-dev llvm-dev ninja-build nlohmann-json3-dev \
  npm pkg-config protobuf-compiler-grpc python3-dev python3-pip \
  python3-venv rapidjson-dev rsync tzdata zlib1g-dev \
  && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i 's/fpic/fPIC/g' /etc/R/Makeconf && \
  Rscript -e 'Sys.setenv("LIBARROW_BINARY" = FALSE, "LIBARROW_MINIMAL" = FALSE);install.packages("arrow")'
RUN pip install --no-cache-dir --root-user-action ignore \
  'numpy==2.3.1' \
  'lightgbm==4.6.0' \
  'h5py==3.14.0' \
  'rpy2==3.6.1' \
  'rpy2-arrow==0.1.2' \
  'pyarrow==21.0.0' \
  'tqdm==4.67.1'
ENTRYPOINT [ "/bin/bash", "-c" ]
