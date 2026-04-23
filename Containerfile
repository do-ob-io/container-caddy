# hadolint global ignore=DL3007,DL3018
FROM cgr.dev/chainguard/wolfi-base:latest AS builder

# Install build dependencies (Go toolchain, git, CA certs)
RUN apk add --no-cache go git ca-certificates

WORKDIR /src

# Clone Caddy source from upstream repository
RUN git clone --depth 1 https://github.com/caddyserver/caddy.git

# Build the Caddy binary
WORKDIR /src/caddy/cmd/caddy
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath -o /out/caddy

FROM cgr.dev/chainguard/wolfi-base:latest

# Copy Caddy binary from builder stage
COPY --from=builder /out/caddy /usr/bin/caddy

EXPOSE 80 443 443/udp

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]