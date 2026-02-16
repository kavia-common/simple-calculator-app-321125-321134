#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-321125-321134/calculator_frontend"
cd "$WORKSPACE"
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift CLI missing" >&2; exit 2; }
echo "SWIFT VERSION: $(swift --version | head -n1)"
# Build
if [ "${SWIFT_DISABLE_SANDBOX:-0}" = "1" ]; then swift build --disable-sandbox; else swift build; fi
echo "Build completed. Artifacts: $WORKSPACE/.build"
# Tests
TS=$(date -u +%Y%m%dT%H%M%SZ)
LOGTMP="/tmp/validation_swift_test.log"
if [ "${SWIFT_DISABLE_SANDBOX:-0}" = "1" ]; then
  if ! swift test --disable-sandbox >"$LOGTMP" 2>&1; then
    cp "$LOGTMP" "$WORKSPACE/test-failure-validation-$TS.log" || true
    echo 'TESTS FAILED' >&2
    tail -n 200 "$WORKSPACE"/test-failure-validation-*.log || true
    exit 3
  fi
else
  if ! swift test >"$LOGTMP" 2>&1; then
    cp "$LOGTMP" "$WORKSPACE/test-failure-validation-$TS.log" || true
    echo 'TESTS FAILED' >&2
    tail -n 200 "$WORKSPACE"/test-failure-validation-*.log || true
    exit 3
  fi
fi
echo "VALIDATION: TESTS PASSED"
# Smoke-run executable if present
EXE_FILE=$(find "$WORKSPACE/Sources" -maxdepth 2 -type f -name main.swift -print -quit || true)
if [ -n "$EXE_FILE" ]; then
  target_dir=$(dirname "$EXE_FILE")
  target_name=$(basename "$target_dir")
  exe_path="$WORKSPACE/.build/debug/$target_name"
  if [ -x "$exe_path" ]; then
    "$exe_path" & pid=$!
    sleep 1
    kill "$pid" >/dev/null 2>&1 || true
    echo "Executable target '$target_name' smoke-run OK"
  else
    echo "Executable binary not found at $exe_path; skipping smoke run"
  fi
else
  echo "No executable target detected; START/STOP N/A"
fi
exit 0
