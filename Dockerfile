# syntax=docker/dockerfile:1.7

ARG ALPINE_VERSION=3.22

FROM alpine:${ALPINE_VERSION} AS downloader

ARG ETCD_VERSION=3.6.8
ARG ETCD_DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download
RUN set -eux; \
    apk add --no-cache ca-certificates curl tar; \
    arch="$(uname -m)"; \
    case "${arch}" in \
      x86_64) arch=amd64 ;; \
      aarch64) arch=arm64 ;; \
      *) echo "unsupported architecture: ${arch}" >&2; exit 1 ;; \
    esac; \
    version="v${ETCD_VERSION}"; \
    tarball="etcd-${version}-linux-${arch}.tar.gz"; \
    url="${ETCD_DOWNLOAD_URL%/}/${version}"; \
    work="$(mktemp -d)"; \
    mkdir -p /out; \
    curl -fsSL "${url}/${tarball}" -o "${work}/${tarball}"; \
    curl -fsSL "${url}/SHA256SUMS" -o "${work}/SHA256SUMS"; \
    grep " ${tarball}$" "${work}/SHA256SUMS" > "${work}/SHA256SUMS.check"; \
    (cd "${work}" && sha256sum -c SHA256SUMS.check); \
    tar -xzf "${work}/${tarball}" -C "${work}"; \
    install -m 0755 "${work}/etcd-${version}-linux-${arch}/etcdctl" /out/etcdctl; \
    install -m 0755 "${work}/etcd-${version}-linux-${arch}/etcdutl" /out/etcdutl

FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache ca-certificates

COPY --from=downloader /out/etcdctl /usr/local/bin/etcdctl
COPY --from=downloader /out/etcdutl /usr/local/bin/etcdutl
COPY backup.sh /usr/local/bin/etcd-backup

RUN chmod 0755 /usr/local/bin/etcd-backup

ENTRYPOINT ["/usr/local/bin/etcd-backup"]
