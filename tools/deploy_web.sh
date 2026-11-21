#!/usr/bin/env bash
# Exports the Web build and publishes it to the gh-pages branch (GitHub Pages).
# Usage: tools/deploy_web.sh        (set GODOT=/path/to/Godot to override)
set -euo pipefail

GODOT="${GODOT:-$HOME/Desktop/Godot_v4.7.2.app/Contents/MacOS/Godot}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

rm -rf build/web
mkdir -p build/web
"$GODOT" --headless --export-release "Web" build/web/index.html
touch build/web/.nojekyll   # serve files as-is, skip Jekyll processing

REMOTE="$(git remote get-url origin)"
SOURCE_COMMIT="$(git rev-parse --short HEAD)"
NAME="$(git config user.name)"
EMAIL="$(git config user.email)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -R build/web/. "$TMP"
cd "$TMP"
git init -q -b gh-pages
git add -A
git -c user.name="$NAME" -c user.email="$EMAIL" commit -q -m "Deploy web build from $SOURCE_COMMIT"
git push -q -f "$REMOTE" gh-pages
echo "Deployed $SOURCE_COMMIT to gh-pages"
