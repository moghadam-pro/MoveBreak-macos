#!/bin/bash
# Maintainer/CI test; not an end-user installation step.
set -euo pipefail
cd "$(dirname "$0")/.."
app="$PWD/artifacts/MoveBreak.app"
codesign --verify --deep --strict "$app"
"$app/Contents/MacOS/MoveBreak" > artifacts/startup-smoke.log 2>&1 &
app_pid=$!
cleanup() { kill "$app_pid" 2>/dev/null || true; }
trap cleanup EXIT
sleep 6
if ! kill -0 "$app_pid" 2>/dev/null; then
  cat artifacts/startup-smoke.log >&2
  echo 'Packaged app terminated unexpectedly during startup.' >&2
  exit 1
fi
echo 'Packaged application remained running through startup and permission-status callbacks.'
