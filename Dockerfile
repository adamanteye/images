FROM ghcr.io/typst/typst:0.15.1
RUN cd /root && apk upgrade --no-cache \
  && apk add --no-cache bash make git file fontconfig minify lilypond perl \
    bzip2 curl tar unzip py3-fonttools py3-brotli
RUN set -eux; \
  font_tmp="$(mktemp -d)"; \
  source_han_dir=/usr/share/fonts/adobe-source-han-serif; \
  source_han_archive="$font_tmp/SourceHanSerifOTC.zip"; \
  mkdir -p "$source_han_dir" /usr/share/fonts/OTF /usr/share/fonts/TTF \
    /usr/share/licenses/source-han-serif /usr/share/licenses/ttf-arphic-ukai; \
  curl -fL --retry 3 \
    https://github.com/adobe-fonts/source-han-serif/releases/download/2.003R/03_SourceHanSerifOTC.zip \
    -o "$source_han_archive"; \
  printf '%s  %s\n' \
    b3586f26d8a4c05ee9e956739e68d6cbd33f7378dc87a1e20eab5358ce22402a \
    "$source_han_archive" | sha256sum -c -; \
  unzip -j "$source_han_archive" '*.ttc' -d "$source_han_dir"; \
  unzip -j "$source_han_archive" LICENSE.txt \
    -d /usr/share/licenses/source-han-serif; \
  test "$(find "$source_han_dir" -type f -name '*.ttc' | wc -l)" -eq 7; \
  curl -fL --retry 3 \
    https://mirrors.ctan.org/fonts/tex-gyre-math/opentype/texgyrepagella-math.otf \
    -o /usr/share/fonts/OTF/texgyrepagella-math.otf; \
  echo '1f9e010f60e947d0e925910009b2ea85ad54edc7cefb106f8cdefb9ffd1d5f2f  /usr/share/fonts/OTF/texgyrepagella-math.otf' \
    | sha256sum -c -; \
  ukai_archive="$font_tmp/fonts-arphic-ukai.tar.bz2"; \
  curl -fL --retry 3 \
    https://deb.debian.org/debian/pool/main/f/fonts-arphic-ukai/fonts-arphic-ukai_0.2.20080216.2.orig.tar.bz2 \
    -o "$ukai_archive"; \
  printf '%s  %s\n' \
    b4968d73519f4f8747e85548fb85d21b665da1bf1ba900a7c499976e6a8ae3d2 \
    "$ukai_archive" | sha256sum -c -; \
  tar -xjf "$ukai_archive" -C "$font_tmp" \
    fonts-arphic-ukai-0.2.20080216.2/ukai.ttc \
    fonts-arphic-ukai-0.2.20080216.2/license/english/ARPHICPL.TXT; \
  mv "$font_tmp/fonts-arphic-ukai-0.2.20080216.2/ukai.ttc" \
    /usr/share/fonts/TTF/ukai.ttc; \
  mv "$font_tmp/fonts-arphic-ukai-0.2.20080216.2/license/english/ARPHICPL.TXT" \
    /usr/share/licenses/ttf-arphic-ukai/COPYING; \
  rm -rf "$font_tmp"; \
  fc-cache -f
ENTRYPOINT ["/bin/bash"]
