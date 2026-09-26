#!/usr/bin/env bash
set -e

API_BASE_URL="${API_BASE_URL:-https://securebypay-api.onrender.com/api/v1}"

echo "Building Flutter web with API_BASE_URL=$API_BASE_URL"

flutter build web \
  --release \
  --no-tree-shake-icons \
  --dart-define="API_BASE_URL=$API_BASE_URL"

echo "Build complete → build/web"
