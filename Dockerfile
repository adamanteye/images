FROM rust:alpine AS build
RUN apk upgrade --no-cache && apk --no-cache add musl-dev && \
  cd /root && \
  wget -q https://github.com/yeslogic/allsorts-tools/archive/refs/tags/0.12.0.tar.gz && \
  tar xaf 0.12.0.tar.gz && mv allsorts-tools-0.12.0/* . && \
  cargo build --release

FROM alpine AS runtime
COPY --from=build /root/target/release/allsorts /bin
RUN cd /root && apk upgrade --no-cache && \
  apk add --no-cache bash make git fontconfig woff2 && \
  # install typst
  wget -q https://github.com/typst/typst/releases/download/v0.13.1/typst-x86_64-unknown-linux-musl.tar.xz && \
  tar xaf typst-x86_64-unknown-linux-musl.tar.xz && \
  mv typst-x86_64-unknown-linux-musl/typst /bin && \
  # install mono font LxgwBrightCodeTC
  wget -q https://github.com/lxgw/LxgwBright-Code/archive/refs/tags/v2.720.tar.gz && \
  tar xaf v2.720.tar.gz && mkdir -p /usr/share/fonts && mv LxgwBright-Code-2.720/LxgwBrightCodeTC /usr/share/fonts && \
  # install serif font Source Han Serif
  wget -q https://github.com/adobe-fonts/source-han-serif/releases/download/2.003R/01_SourceHanSerif.ttc.zip && \
  unzip 01_SourceHanSerif.ttc.zip && mv SourceHanSerif.ttc /usr/share/fonts && \
  # install sans font Source Han Sans
  wget -q https://github.com/adobe-fonts/source-han-sans/releases/download/2.004R/SourceHanSans.ttc.zip && \
  unzip SourceHanSans.ttc.zip && mv SourceHanSans.ttc /usr/share/fonts && \
  # install maple font
  wget -q https://github.com/subframe7536/maple-font/releases/download/v7.5/MapleMono-NF-CN-unhinted.zip && \
  unzip MapleMono-NF-CN-unhinted.zip && \
  mv MapleMono-NF-CN-Regular.ttf /usr/share/fonts && \
  # index new fonts
  fc-cache && \
  # install minify
  wget -q https://github.com/tdewolff/minify/releases/download/v2.23.11/minify_linux_amd64.tar.gz && \
  tar xaf minify_linux_amd64.tar.gz && \
  mv minify /bin && rm minify_linux_amd64.tar.gz && \
  ## clean
  rm -rf /root/*
