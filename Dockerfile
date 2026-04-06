FROM ghcr.io/typst/typst:0.14.2
RUN cd /root && apk upgrade --no-cache && \
  apk add --no-cache bash make git file minify lilypond
ENTRYPOINT [ "/bin/bash" ]
