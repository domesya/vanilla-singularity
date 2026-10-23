#!/bin/bash
set -euo pipefail

case "$(uname -m)" in
  x86_64)        arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) echo "unsupported architecture: $(uname -m)"; exit 1 ;;
esac
curl -L -o vetro \
  "https://github.com/singularityos-lab/vetro/releases/latest/download/vetro-linux-$arch"
chmod +x vetro
sudo install -Dm755 vetro /usr/local/bin/vetro
