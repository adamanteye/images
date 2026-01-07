FROM python:3.13-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential \
  && rm -rf /var/lib/apt/lists/*
RUN python -m pip install -U pip setuptools wheel
RUN pip install \
  pymc==5.24.1 jupyterlab numpy
