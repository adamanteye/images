FROM debian:trixie-slim AS build

ARG DEBIAN_FRONTEND=noninteractive
ARG GODOT_REF=4.6.2-stable
ARG EMSDK_VERSION=4.0.0
ARG SCONS_JOBS=4

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    libasound2-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libpulse-dev \
    libudev-dev \
    libwayland-dev \
    libx11-dev \
    libxcursor-dev \
    libxi-dev \
    libxinerama-dev \
    libxrandr-dev \
    pkg-config \
    python3 \
    scons \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN ASSET="godot-${GODOT_REF}.tar.xz" \
  && curl -fsSL -o "${ASSET}" \
    "https://github.com/godotengine/godot/releases/download/${GODOT_REF}/${ASSET}" \
  && curl -fsSL -o "${ASSET}.sha256" \
    "https://github.com/godotengine/godot/releases/download/${GODOT_REF}/${ASSET}.sha256" \
  && sha256sum -c "${ASSET}.sha256" \
  && mkdir -p /src/godot \
  && tar -xJf "${ASSET}" -C /src/godot --strip-components=1 \
  && rm -f "${ASSET}" "${ASSET}.sha256"

RUN git clone --depth 1 https://github.com/emscripten-core/emsdk.git /opt/emsdk \
  && cd /opt/emsdk \
  && ./emsdk install "${EMSDK_VERSION}" \
  && ./emsdk activate "${EMSDK_VERSION}"

COPY web_release.py version_dir.py /opt/godot-build/

WORKDIR /src/godot

RUN set -eux; \
  . /opt/emsdk/emsdk_env.sh; \
  scons -j"${SCONS_JOBS}" platform=linuxbsd target=editor; \
  scons -j"${SCONS_JOBS}" platform=web target=template_release \
    profile=/opt/godot-build/web_release.py; \
  VERSION_DIR="$(python3 /opt/godot-build/version_dir.py version.py)"; \
  EDITOR_BIN="$(find bin -maxdepth 1 -type f -name 'godot.linuxbsd.editor.*' | head -n 1)"; \
  mkdir -p /out/usr/local/bin "/out/root/.local/share/godot/export_templates/${VERSION_DIR}"; \
  install -m 0755 "${EDITOR_BIN}" /out/usr/local/bin/godot; \
  mv bin/godot.web.template_release.wasm32.zip \
    "/out/root/.local/share/godot/export_templates/${VERSION_DIR}/web_release.zip"; \
  printf '%s\n' "${VERSION_DIR}" > \
    "/out/root/.local/share/godot/export_templates/${VERSION_DIR}/version.txt"

FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    binaryen nodejs npm \
    brotli \
    ca-certificates \
    libasound2 \
    libfontconfig1 \
    libfreetype6 \
    libgl1 \
    libglu1-mesa \
    libpulse0 \
    libudev1 \
    libwayland-client0 \
    libx11-6 \
    libx11-xcb1 \
    libxcursor1 \
    libxext6 \
    libxi6 \
    libxinerama1 \
    libxkbcommon0 \
    libxrandr2 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /out/ /

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/godot", "--headless"]
CMD ["--help"]
