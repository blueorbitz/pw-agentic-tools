#!/usr/bin/env bash
set -euo pipefail

hook="$(cd "$(dirname "$0")/../.." && pwd)/hooks/scripts/block-env.sh"

assert_allowed() {
  local name="$1"
  local payload="$2"
  local output
  output="$(printf '%s' "$payload" | bash "$hook")"
  if [ -n "$output" ]; then
    printf 'FAIL: %s was denied: %s\n' "$name" "$output" >&2
    exit 1
  fi
}

assert_denied() {
  local name="$1"
  local payload="$2"
  local output
  output="$(printf '%s' "$payload" | bash "$hook")"
  if ! printf '%s' "$output" | grep -q '"permissionDecision":"deny"'; then
    printf 'FAIL: %s was not denied (output: %s)\n' "$name" "$output" >&2
    exit 1
  fi
}

assert_allowed 'repository inspection with unrelated prompt fields' \
  '{"toolName":"bash","toolArgs":"{\"command\":\"pwd; git status --short; git remote -v; ls -la; find . -maxdepth 2 -type f -not -path \\u0027./.git/*\\u0027 -print | sort | head -150\"}","prompt":"Block reading .env files"}'
assert_allowed 'listing a secret filename' \
  '{"toolName":"bash","toolArgs":"{\"command\":\"find . -name .env -print\"}"}'
assert_allowed 'searching for the filename in another file' \
  '{"toolName":"grep","toolArgs":"{\"pattern\":\".env\",\"path\":\"/repo/README.md\"}"}'
assert_allowed 'reading an example file' \
  '{"toolName":"bash","toolArgs":"{\"command\":\"cat .env.example\"}"}'
assert_denied 'example directory does not make a secret file safe' \
  '{"toolName":"bash","toolArgs":"{\"command\":\"cat example/.env\"}"}'
assert_denied 'reading a variant' \
  '{"toolName":"bash","toolArgs":"{\"command\":\"cat .env.local\"}"}'
assert_denied 'reading a secret alongside an example' \
  '{"toolName":"bash","toolArgs":"{\"command\":\"cat .env; cat .env.example\"}"}'
assert_denied 'reading through grep' \
  '{"toolName":"grep","toolArgs":"{\"pattern\":\"TOKEN\",\"path\":\"/repo/.env.production\"}"}'
assert_denied 'sourcing a secret file' \
  '{"toolName":"bash","toolArgs":"{\"command\":\". .env\"}"}'

printf 'All block-env tests passed.\n'
