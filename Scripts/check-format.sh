#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

echo "Checking Swift formatting..."

swiftformat \
    Apps \
    Packages \
    --config "$ROOT_DIR/.swiftformat" \
    --lint

echo "SwiftFormat check completed."
