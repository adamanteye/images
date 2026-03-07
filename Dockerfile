FROM pgvector/pgvector:pg16 AS builder
FROM docker.io/bitnamilegacy/postgresql:16.6.0

COPY --from=builder /usr/lib/postgresql/16/lib/vector.so /opt/bitnami/postgresql/lib/
COPY --from=builder /usr/share/postgresql/16/extension/vector* /opt/bitnami/postgresql/share/extension/
