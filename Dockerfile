FROM alpine:latest
RUN cd /root && apk add --no-cache bash make git fontconfig rsync && \
  wget https://github.com/typst/typst/releases/download/v0.13.1/typst-x86_64-unknown-linux-musl.tar.xz && \
  tar xaf typst-x86_64-unknown-linux-musl.tar.xz && \
  mv typst-x86_64-unknown-linux-musl/typst /bin && \
  rm -rf typst* && \
  wget https://github.com/lxgw/LxgwBright-Code/archive/refs/tags/v2.711.tar.gz && \
  tar xaf v2.711.tar.gz && mkdir -p /usr/share/fonts && mv LxgwBright-Code-2.711/LxgwBrightCodeTC /usr/share/fonts && \
  rm -rf v2.711.tar.gz Lxgw* && fc-cache && \
  wget https://github.com/tdewolff/minify/releases/download/v2.23.6/minify_linux_amd64.tar.gz && \
  tar xaf minify_linux_amd64.tar.gz && \
  mv minify /bin && rm minify_linux_amd64.tar.gz
