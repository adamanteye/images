FROM python:alpine
RUN apk --upgrade --no-cache add nvchecker py3-lxml
ENTRYPOINT ["/bin/sh"]
