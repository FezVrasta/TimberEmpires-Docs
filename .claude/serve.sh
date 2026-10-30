#!/bin/sh
# Jekyll rebuilds on every change, Python serves the result: Jekyll's own server breaks video streams
cd "$(dirname "$0")/.." || exit 1
ROOT="${TMPDIR:-/tmp}/te-docs-serve"
mkdir -p "$ROOT"
ln -sfn "$PWD/_site" "$ROOT/TimberEmpires-Docs"
bundle exec jekyll build --watch &
trap 'kill $!' EXIT
cd "$ROOT" && python3 -m http.server 4000
