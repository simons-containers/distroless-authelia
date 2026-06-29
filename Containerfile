FROM archlinux:base-devel-20260621.0.546891 AS builder

ARG AUTHELIA_VERSION
ARG GOLANG_VERSION

ARG AUTHELIA_SOURCE
ARG GOLANG_RELEASE

RUN pacman -Sy --noconfirm git pnpm wget

WORKDIR /opt/go
RUN curl --silent --show-error --location \
  "${GOLANG_RELEASE}" \
  | tar xzf - --strip-components=1
ENV PATH=$PATH:/opt/go/bin

WORKDIR /src/authelia
RUN git clone --branch v${AUTHELIA_VERSION} --depth 1 --single-branch \
  ${AUTHELIA_SOURCE} .

RUN go run ./cmd/authelia-scripts xflags > /tmp/xflags
RUN cd web && pnpm build
RUN cp -r api internal/server/public_html/api
RUN git update-index --assume-unchanged \
    internal/server/public_html/api/index.html \
    internal/server/public_html/api/openapi.yml \
    internal/server/public_html/index.html
RUN go build \
    -trimpath \
    -buildmode=pie \
    -ldflags="-s -w $(< /tmp/xflags)" \
    -o authelia \
    ./cmd/authelia

FROM ghcr.io/simons-containers/distroless-glibc:2.43

ARG AUTHELIA_VERSION

COPY --from=builder /src/authelia/authelia /usr/bin/authelia

ENTRYPOINT ["/usr/bin/authelia"]
CMD ["--config", "/etc/authelia.d"]

LABEL org.opencontainers.image.title="distroless authelia"
LABEL org.opencontainers.image.description="distroless authelia"
LABEL org.opencontainers.image.version="${AUTHELIA_VERSION}"
LABEL org.opencontainers.image.source="https://github.com/simons-containers/distroless-authelia"
LABEL org.opencontainers.image.volumes.config="/etc/authelia.d"
