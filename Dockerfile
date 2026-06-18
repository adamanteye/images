FROM debian:bookworm-slim AS john-builder
ARG JTR_REPO=https://github.com/openwall/john.git
ARG JTR_BRANCH=bleeding-jumbo
ARG JTR_SIMD_VARIANTS="generic sse2 avx avx2 avx512"

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  git \
  build-essential \
  libssl-dev \
  zlib1g-dev \
  pkg-config \
  libgmp-dev \
  libpcap-dev \
  libbz2-dev \
  && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  git clone --depth 1 --branch "${JTR_BRANCH}" "${JTR_REPO}" /usr/src/john; \
  mkdir -p /opt/john; \
  for variant in ${JTR_SIMD_VARIANTS}; do \
    cp -a /usr/src/john "/tmp/john-${variant}"; \
    cd "/tmp/john-${variant}/src"; \
    if [ "${variant}" = generic ]; then \
      simd_flag=--disable-simd; \
    else \
      simd_flag="--enable-simd=${variant}"; \
    fi; \
    ./configure --disable-native-tests "${simd_flag}"; \
    make -s clean; \
    make -sj"$(nproc)"; \
    mkdir -p "/opt/john/${variant}"; \
    cp -a ../run/. "/opt/john/${variant}/"; \
    cd /; \
    rm -rf "/tmp/john-${variant}"; \
  done; \
  printf '%s\n' \
    '#!/bin/sh' \
    'set -eu' \
    'flags=" $(sed -n "s/^flags[[:space:]]*: //p" /proc/cpuinfo 2>/dev/null | head -n 1) "' \
    'has_flag() { printf "%s\n" "$flags" | grep -qw "$1"; }' \
    'if has_flag avx512bw && has_flag avx512vl && has_flag avx512dq && [ -x /opt/john/avx512/john ]; then' \
    '  exec /opt/john/avx512/john "$@"' \
    'fi' \
    'if has_flag avx2 && [ -x /opt/john/avx2/john ]; then' \
    '  exec /opt/john/avx2/john "$@"' \
    'fi' \
    'if has_flag avx && [ -x /opt/john/avx/john ]; then' \
    '  exec /opt/john/avx/john "$@"' \
    'fi' \
    'if has_flag sse2 && [ -x /opt/john/sse2/john ]; then' \
    '  exec /opt/john/sse2/john "$@"' \
    'fi' \
    'exec /opt/john/generic/john "$@"' \
    > /usr/local/bin/john; \
  chmod +x /usr/local/bin/john

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  libssl3 \
  zlib1g \
  libgmp10 \
  libpcap0.8 \
  libbz2-1.0 \
  libgomp1 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=john-builder /opt/john /opt/john
COPY --from=john-builder /usr/local/bin/john /usr/local/bin/john
ENV JOHN_PATH=/usr/local/bin/john
WORKDIR /work
ENTRYPOINT ["john"]
CMD ["--help"]
