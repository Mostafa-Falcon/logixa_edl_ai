#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_URL="${LOGIXA_ENGINE_URL:-http://127.0.0.1:8787}"
FLUTTER_DEVICE="${LOGIXA_FLUTTER_DEVICE:-linux}"

ENGINE_PID=""
ENGINE_STARTED_BY_SCRIPT="false"

engine_alive() {
  curl -fsS "$ENGINE_URL/health" >/dev/null 2>&1
}

cleanup() {
  if [[ "$ENGINE_STARTED_BY_SCRIPT" == "true" && -n "${ENGINE_PID}" ]]; then
    echo
    echo "Stopping Logixa Rust Engine..."
    kill "$ENGINE_PID" >/dev/null 2>&1 || true
    wait "$ENGINE_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT INT TERM

cd "$ROOT_DIR"

echo "Logixa EDL AI Dev Runner"
echo "Project: $ROOT_DIR"
echo "Engine:  $ENGINE_URL"
echo "Device:  $FLUTTER_DEVICE"
echo

if engine_alive; then
  echo "Rust Engine is already running. Using existing engine."
else
  echo "Starting Rust Engine..."
  (
    cd "$ROOT_DIR/logixa_engine"
    cargo run
  ) &
  ENGINE_PID="$!"
  ENGINE_STARTED_BY_SCRIPT="true"

  echo "Waiting for Rust Engine..."
  for _ in {1..30}; do
    if engine_alive; then
      echo "Rust Engine is online."
      break
    fi
    sleep 1
  done

  if ! engine_alive; then
    echo "Rust Engine failed to start on $ENGINE_URL"
    exit 1
  fi
fi

echo
echo "Starting Flutter..."
flutter run -d "$FLUTTER_DEVICE"
