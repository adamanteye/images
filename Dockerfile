# syntax=docker/dockerfile:1.7

ARG COLLABST_REF=815ffd3534f71e31d7d33f1092b7b57eb83c0e6c

FROM node:20-slim AS source
ARG COLLABST_REF
ADD https://github.com/collabst/collabst/archive/${COLLABST_REF}.tar.gz /tmp/collabst.tar.gz
RUN mkdir /src \
  && tar -xzf /tmp/collabst.tar.gz -C /src --strip-components=1

FROM node:20-slim AS frontend-builder
WORKDIR /frontend
COPY --from=source /src/frontend/package.json /src/frontend/package-lock.json ./
RUN npm ci
COPY --from=source /src/frontend/ ./
ENV VITE_API_URL=/api/v1
RUN npm run build

FROM python:3.12-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app
COPY --from=source /src/backend/ /app/
RUN uv sync --frozen

COPY --from=frontend-builder /frontend/build /app/frontend-dist
RUN chmod +x /app/scripts/entrypoint.prod.sh

EXPOSE 8000
ENTRYPOINT ["/app/scripts/entrypoint.prod.sh"]
