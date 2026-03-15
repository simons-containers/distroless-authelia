FROM archlinux:base-devel-20260308.0.497099 AS builder

ARG AUTHELIA_VERSION
ARG AUTHELIA_TARBALL=authelia-v${AUTHELIA_VERSION}-linux-amd64-musl.tar.gz
ARG GITHUB_URL=https://github.com/authelia/authelia/releases/download

WORKDIR /tmp
RUN curl --silent --show-error --location --output authelia.tar.gz \
  "${GITHUB_URL}/v${AUTHELIA_VERSION}/${AUTHELIA_TARBALL}" \
  && tar xzf authelia.tar.gz

FROM ghcr.io/simons-containers/distroless-musl:1.2.5

ARG AUTHELIA_VERSION

COPY --from=builder /tmp/authelia /usr/bin/authelia

ENTRYPOINT ["/usr/bin/authelia"]
CMD ["--config", "/etc/authelia.d"]

LABEL org.opencontainers.image.title="distroless authelia"
LABEL org.opencontainers.image.description="distroless authelia"
LABEL org.opencontainers.image.version="${AUTHELIA_VERSION}"
LABEL org.opencontainers.image.volumes.config="/etc/authelia.d"
