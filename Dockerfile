FROM golang:1.24-bookworm

ARG HUGO_VERSION=0.163.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git tar \
    && curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz" \
      | tar -xz -C /usr/local/bin hugo \
    && apt-get purge -y --auto-remove curl tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

EXPOSE 1313

CMD ["hugo", "server", "--bind", "0.0.0.0", "--baseURL", "http://localhost:1313/", "-D", "--disableFastRender"]
