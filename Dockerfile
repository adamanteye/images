FROM ghcr.io/typst/typst:0.14.0
RUN cd /root && apk upgrade --no-cache && \
  apk add --no-cache bash make git file
ENTRYPOINT [ "/bin/bash" ]
