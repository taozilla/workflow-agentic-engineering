#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT_DIR"

if [[ ! -f "package.json" ]]; then
  echo "No package.json found."
  echo "Use the repository's native verification commands."
  exit 2
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required to inspect package.json scripts."
  exit 2
fi

detect_package_manager() {
  if [[ -f "pnpm-lock.yaml" ]]; then
    echo "pnpm"
  elif [[ -f "yarn.lock" ]]; then
    echo "yarn"
  elif [[ -f "bun.lock" || -f "bun.lockb" ]]; then
    echo "bun"
  else
    echo "npm"
  fi
}

has_script() {
  local script_name="$1"

  node -e "
    const pkg = require('./package.json');
    process.exit(pkg.scripts && pkg.scripts['${script_name}'] ? 0 : 1);
  "
}

run_script() {
  local script_name="$1"

  echo
  echo "==> Running: ${script_name}"

  case "$PACKAGE_MANAGER" in
    pnpm)
      pnpm run "$script_name"
      ;;
    yarn)
      yarn "$script_name"
      ;;
    bun)
      bun run "$script_name"
      ;;
    npm)
      npm run "$script_name"
      ;;
    *)
      echo "Unsupported package manager: $PACKAGE_MANAGER"
      return 1
      ;;
  esac
}

run_first_available() {
  local group_name="$1"
  shift

  local candidate

  for candidate in "$@"; do
    if has_script "$candidate"; then
      run_script "$candidate"
      return $?
    fi
  done

  echo "SKIP: ${group_name} — no matching script found."
  return 0
}

PACKAGE_MANAGER="$(detect_package_manager)"
FULL_VERIFY="${FULL_VERIFY:-0}"
FAILURES=0

echo "Repository: $ROOT_DIR"
echo "Package manager: $PACKAGE_MANAGER"
echo "Full verification: $FULL_VERIFY"

run_first_available \
  "format check" \
  "format:check" \
  "check:format" \
  "prettier:check" || FAILURES=$((FAILURES + 1))

run_first_available \
  "lint" \
  "lint" \
  "check:lint" || FAILURES=$((FAILURES + 1))

run_first_available \
  "type check" \
  "typecheck" \
  "type-check" \
  "check:types" \
  "types" || FAILURES=$((FAILURES + 1))

run_first_available \
  "tests" \
  "test:ci" \
  "test" \
  "check:test" || FAILURES=$((FAILURES + 1))

if [[ "$FULL_VERIFY" == "1" ]]; then
  run_first_available \
    "build" \
    "build" \
    "check:build" || FAILURES=$((FAILURES + 1))

  run_first_available \
    "end-to-end tests" \
    "test:e2e" \
    "e2e" \
    "playwright:test" || FAILURES=$((FAILURES + 1))
else
  echo "SKIP: build and end-to-end checks require FULL_VERIFY=1."
fi

echo

if [[ "$FAILURES" -gt 0 ]]; then
  echo "Verification failed in $FAILURES check group(s)."
  exit 1
fi

echo "All discovered verification checks passed."