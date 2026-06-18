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
    'check_variant_flags() {' \
    '  variant="$1"' \
    '  missing=0' \
    '  shift' \
    '  for flag in "$@"; do' \
    '    echo "john: checking CPU flag for $variant: $flag" >&2' \
    '    if has_flag "$flag"; then' \
    '      echo "john: detected CPU flag for $variant: $flag" >&2' \
    '    else' \
    '      echo "john: missing CPU flag for $variant: $flag" >&2' \
    '      missing=1' \
    '    fi' \
    '  done' \
    '  return "$missing"' \
    '}' \
    'if check_variant_flags avx512 avx512bw avx512vl avx512dq; then' \
    '  if [ -x /opt/john/avx512/john ]; then' \
    '    echo "john: selected SIMD variant: avx512 (flags: avx512bw avx512vl avx512dq)" >&2' \
    '    exec /opt/john/avx512/john "$@"' \
    '  fi' \
    '  echo "john: variant avx512 is unavailable" >&2' \
    'fi' \
    'if check_variant_flags avx2 avx2; then' \
    '  if [ -x /opt/john/avx2/john ]; then' \
    '    echo "john: selected SIMD variant: avx2 (flags: avx2)" >&2' \
    '    exec /opt/john/avx2/john "$@"' \
    '  fi' \
    '  echo "john: variant avx2 is unavailable" >&2' \
    'fi' \
    'if check_variant_flags avx avx; then' \
    '  if [ -x /opt/john/avx/john ]; then' \
    '    echo "john: selected SIMD variant: avx (flags: avx)" >&2' \
    '    exec /opt/john/avx/john "$@"' \
    '  fi' \
    '  echo "john: variant avx is unavailable" >&2' \
    'fi' \
    'if check_variant_flags sse2 sse2; then' \
    '  if [ -x /opt/john/sse2/john ]; then' \
    '    echo "john: selected SIMD variant: sse2 (flags: sse2)" >&2' \
    '    exec /opt/john/sse2/john "$@"' \
    '  fi' \
    '  echo "john: variant sse2 is unavailable" >&2' \
    'fi' \
    'echo "john: selected SIMD variant: generic (flags: none)" >&2' \
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
