#!/usr/bin/env bash
set -euo pipefail

ARCH="${ARCH:-$(uname -m)}"

tmp="$(mktemp -d)"

case "$ARCH" in 
    amd64) arch=amd64; SHA256_SUM="b653a4b1b75a31a8a00a5d12b11eaafa3f22d6cf2b3417efde68a113b4c60700"
        ;;
    aarch64) arch=arm64; SHA256_SUM="13f4e45e41aa589b21fcaed498c564586b7587617382c5635ecd7b214280a8e1"
        ;;
    *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

_cleanup() {
    rm -rf "$tmp"
}

trap _cleanup INT TERM EXIT

curl -fsSL -o "$tmp/vetro" "https://github.com/singularityos-lab/vetro/releases/download/v1.0.0/vetro-linux-$arch"
echo "${SHA256_SUM}  $tmp/vetro" | sha256sum --check --status -
install -Dm755 "$tmp/vetro" /usr/bin/vetro
