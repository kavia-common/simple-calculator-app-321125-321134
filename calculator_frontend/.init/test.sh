#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-321125-321134/calculator_frontend"
cd "$WORKSPACE"
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift CLI missing" >&2; exit 2; }
TS=$(date -u +%Y%m%dT%H%M%SZ)
LOGTMP="/tmp/validation_swift_test.log"
if [ "${SWIFT_DISABLE_SANDBOX:-0}" = "1" ]; then
  if ! swift test --disable-sandbox >"$LOGTMP" 2>&1; then
    cp "$LOGTMP" "$WORKSPACE/test-failure-validation-$TS.log" || true
    echo "TESTS FAILED. Log: $WORKSPACE/test-failure-validation-$TS.log" >&2
    tail -n 200 "$WORKSPACE"/test-failure-validation-*.log || true
    exit 3
  fi
else
  if ! swift test >"$LOGTMP" 2>&1; then
    cp "$LOGTMP" "$WORKSPACE/test-failure-validation-$TS.log" || true
    echo "TESTS FAILED. Log: $WORKSPACE/test-failure-validation-$TS.log" >&2
    tail -n 200 "$WORKSPACE"/test-failure-validation-*.log || true
    exit 3
  fi
fi
echo "VALIDATION: TESTS PASSED"
