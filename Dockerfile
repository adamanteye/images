FROM debian:bookworm-slim
SHELL ["/bin/bash", "-c"]
RUN sed -i \
  's|http://deb.debian.org/debian-security|http://snapshot.debian.org/archive/debian-security/20250717T060459Z|g' \
  /etc/apt/sources.list.d/debian.sources && \
  sed -i \
  's|http://deb.debian.org/debian|http://snapshot.debian.org/archive/debian/20250718T082802Z|g' \
  /etc/apt/sources.list.d/debian.sources && \
  apt-get update && apt-get install -y --no-install-recommends \
  r-base r-base-dev \
  r-cran-mgcv r-cran-proto r-cran-argparser \
  cmake gcc make wget \
  python3-{numpy,matplotlib,scipy} \
  && \
  Rscript -e 'install.packages("arrow")' && \
  wget https://hep.tsinghua.edu.cn/~wuyy/debian/pool/main/p/python3-pyarrow/python3-pyarrow_20.0.0-1~w2d0_amd64.deb \
  -O python3-pyarrow.deb && apt-get install -y --no-install-recommends \
  ./python3-pyarrow.deb && rm ./python3-pyarrow.deb && \
  apt-get install -y --no-install-recommends \
  python3-rpy2 \
  && \
  rm -rf /var/lib/apt/lists/*
