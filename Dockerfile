FROM docker.io/library/python:3.12.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1

COPY requirements.txt /usr/local/share/market-data/requirements.txt
RUN python -m pip install --disable-pip-version-check --no-cache-dir \
  -r /usr/local/share/market-data/requirements.txt \
  && python -m pip check

WORKDIR /app
USER 65532:65532
CMD ["python"]
