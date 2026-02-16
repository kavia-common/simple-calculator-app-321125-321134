#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-321125-321134/calculator_frontend"
PKGS=(libicu-dev libxml2-dev libsqlite3-dev zlib1g-dev libcurl4-openssl-dev libssl-dev ca-certificates gnupg)
MISSING=()
for p in "${PKGS[@]}"; do dpkg -s "${p}" >/dev/null 2>&1 || MISSING+=("${p}"); done
if [ ${#MISSING[@]} -ne 0 ]; then
  sudo apt-get update -q && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends "${MISSING[@]}" || { echo "ERROR: apt-get install failed" >&2; exit 2; }
  sudo apt-get clean -y >/dev/null || true
fi
# Validate all requested packages are installed
for p in "${PKGS[@]}"; do dpkg -s "${p}" >/dev/null 2>&1 || { echo "ERROR: package ${p} missing after install" >&2; exit 3; }; done
exit 0
