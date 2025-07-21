FROM python:3.13.5-bookworm
RUN sed -i \
  's|http://deb.debian.org/debian-security|http://snapshot.debian.org/archive/debian-security/20250717T060459Z|g' \
  /etc/apt/sources.list.d/debian.sources && \
  sed -i \
  's|http://deb.debian.org/debian|http://snapshot.debian.org/archive/debian/20250718T082802Z|g' \
  /etc/apt/sources.list.d/debian.sources && \
  apt-get update && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
  r-base r-base-dev \
  r-cran-mgcv r-cran-proto r-cran-argparser \
  cmake gcc make wget curl ca-certificates \
  && \
  rm -rf /var/lib/apt/lists/* && \
  Rscript -e 'install.packages("arrow")' && \
  wget -q https://hep.tsinghua.edu.cn/~wuyy/debian/pool/main/p/python3-pyarrow/python3-pyarrow_20.0.0-1~w2d0_amd64.deb \
  -O python3-pyarrow.deb && apt-get install -y --no-install-recommends \
  ./python3-pyarrow.deb && rm ./python3-pyarrow.deb && \
  pip install --no-cache-dir \
  'numpy==2.3.1' \
  'lightgbm==4.6.0' \
  'h5py==3.14.0' \
  'rpy2==2.3.1' \
  'pyarrow==21.0.0' \
  'tqdm==4.67.1' \
  && \
  useradd -m -s /usr/bin/bash debian && \
  echo "root:debian" | chpasswd
USER debian
WORKDIR /home/debian
