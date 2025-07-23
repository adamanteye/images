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
  LIBARROW_MINIMAL='false' Rscript -e 'install.packages("arrow")'
RUN pip install --no-cache-dir --root-user-action ignore \
  'numpy==2.3.1' \
  'lightgbm==4.6.0' \
  'h5py==3.14.0' \
  'rpy2==3.6.1' \
  'rpy2-arrow==0.1.2' \
  'pyarrow==21.0.0' \
  'tqdm==4.67.1'
ENTRYPOINT [ "/bin/bash" ]
