#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "Clearing cached package resolution..."
rm -rf obj bin

echo "Restoring latest 18.*-* nightly packages..."
dotnet restore

echo "Building..."
dotnet build
