FROM archlinux:base-devel-20260308.0.497099 AS fetch

ARG AUTHELIA_VERSION
ARG GOLANG_VERSION=1.26.4

ARG AUTHELIA_SOURCE=https://github.com/authelia/authelia.git
ARG GOLANG_RELEASE=https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz

RUN pacman -Sy --noconfirm git

WORKDIR /src/authelia
RUN git clone ${AUTHELIA_SOURCE} authelia \
  && cd authelia \
  && git checkout v${AUTHELIA_VERSION}

WORKDIR /fetch/golang
RUN curl --silent --show-error --location --output golang.tar.gz \
  "${GOLANG_RELEASE}" \
  && tar xzf golang.tar.gz --strip-components=1 \
  && rm golang.tar.gz

FROM ghcr.io/simons-containers/distroless-nodejs:26.4.0 as frontend-builder

COPY --from=fetch /src/authelia /src/authelia
WORKDIR /src/authelia/web

RUN ["node", "npm", "install", "-g", "pnpm"]
RUN ["node", "pnpm", "build"]

FROM scratch as app-builder

COPY --from=fetch /fetch/golang /
COPY --from=fetch /src/authelia /src/authelia
COPY --from=frontend-builder /src/authelia/internal/server/public_html/api /src/authelia/api

WORKDIR /src/authelia
RUN /bin/go build -o authelia ./cmd/authelia

FROM ghcr.io/simons-containers/distroless-musl:1.2.6

ARG AUTHELIA_VERSION

COPY --from=app-builder /src/authelia/authelia /usr/bin/authelia

ENTRYPOINT ["/usr/bin/authelia"]
CMD ["--config", "/etc/authelia.d"]

LABEL org.opencontainers.image.title="distroless authelia"
LABEL org.opencontainers.image.description="distroless authelia"
LABEL org.opencontainers.image.version="${AUTHELIA_VERSION}"
LABEL org.opencontainers.image.source="https://github.com/simons-containers/distroless-authelia"
LABEL org.opencontainers.image.volumes.config="/etc/authelia.d"

