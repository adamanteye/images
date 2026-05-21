FROM ghcr.io/typst/typst:0.14.2
COPY source-han-serif/ /usr/share/fonts/adobe-source-han-serif/
COPY texgyrepagella-math.otf /usr/share/fonts/OTF/texgyrepagella-math.otf
RUN cd /root && apk upgrade --no-cache \
  && apk add --no-cache bash make git file fontconfig minify lilypond perl \
  && fc-cache -f
ENTRYPOINT ["/bin/bash"]
