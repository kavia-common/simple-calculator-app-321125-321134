#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-321125-321134/calculator_frontend"
cd "$WORKSPACE"
# Start executable target if built binary exists. Prints PID on success.
EXE_FILE=$(find "$WORKSPACE/Sources" -maxdepth 2 -type f -name main.swift -print -quit || true)
if [ -z "$EXE_FILE" ]; then
  echo "No executable target detected; nothing to start"
  exit 0
fi
TARGET_DIR=$(dirname "$EXE_FILE")
TARGET_NAME=$(basename "$TARGET_DIR")
EXE_PATH="$WORKSPACE/.build/debug/$TARGET_NAME"
if [ ! -x "$EXE_PATH" ]; then
  echo "Executable binary not found at $EXE_PATH; ensure build ran successfully" >&2
  exit 4
fi
"$EXE_PATH" &
PID=$!
echo "$PID" > "$WORKSPACE/.init_${TARGET_NAME}.pid"
echo "Started $TARGET_NAME (pid $PID)"
