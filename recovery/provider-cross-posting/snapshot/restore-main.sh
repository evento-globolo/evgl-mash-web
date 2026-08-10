#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p src
cat src/main.rs.b64.part-* | base64 --decode > src/main.rs
sha256sum --check src/main.rs.sha256
