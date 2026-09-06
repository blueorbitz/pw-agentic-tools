#!/usr/bin/env bash
# Blocks agent reads of .env and its variants (view tool + shell commands),
# while allowing anything containing ".example" (.env.example, ...).
#
# Supports: GitHub Copilot, Claude Code, Command Code, OpenCode hook payloads.
# Dependency-free: uses only tr/sed/grep, which ship with every Unix host.
set -euo pipefail

payload="$(cat)"
[ -n "$payload" ] || exit 0

# Flatten to one line; remove only actual CR/LF characters.
text="$(printf '%s' "$payload" | tr -d '\r\n')"
[ -n "$text" ] || exit 0

# ── Tool name ──────────────────────────────────────────────────────────
# Accept camelCase (Copilot: toolName), snake_case (Claude Code / Command
# Code: tool_name), and display-name (Command Code: tool_display_name).
tool="$(printf '%s' "$text" | sed -n 's/.*"toolName"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
[ -n "$tool" ] || tool="$(printf '%s' "$text" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
[ -n "$tool" ] || tool="$(printf '%s' "$text" | sed -n 's/.*"tool_display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
tool="$(printf '%s' "$tool" | tr '[:upper:]' '[:lower:]')"

# Only direct file reads, shell commands, and grep can pull .env contents.
case "$tool" in
  view|read|read_file|bash|powershell|shell|shell_command|grep) ;;
  *) exit 0 ;;
esac

# ── Tool arguments ─────────────────────────────────────────────────────
# Scan only the tool-argument region so unrelated fields (cwd, session
# paths) cannot trigger a false denial.  toolArgs (Copilot camelCase) may
# be a JSON string; tool_input (Claude Code / Command Code) is an object.
# Either way, grepping the raw text for ".env" patterns works.
args="$(printf '%s' "$text" | sed -n 's/.*"toolArgs"[[:space:]]*://p' | head -n 1)"
[ -n "$args" ] || args="$(printf '%s' "$text" | sed -n 's/.*"tool_input"[[:space:]]*://p' | head -n 1)"
[ -n "$args" ] || exit 0

# ── Allowlist ──────────────────────────────────────────────────────────
# ".example" anywhere in the arguments marks a safe template
# (.env.example, .env.production.example).
if printf '%s' "$args" | grep -qi '\.example'; then
  exit 0
fi

# ── Deny ───────────────────────────────────────────────────────────────
# Match a ".env" token or variant (.env.local, .env.production, .env-backup)
# inside the tool arguments.  Boundary is any non-alphanumeric (or end) on
# each side, which keeps non-secret names like .envrc, .environment, foo.env
# unblocked.
args_plain="$(printf '%s' "$args" | sed 's/\\//g')"
if printf '%s' "$args_plain" | grep -qiE '(^|[^a-zA-Z0-9])\.env([^a-zA-Z0-9]|$)'; then
  reason="${ENV_BLOCK_REASON:-Reading .env files is blocked by policy. Read .env.example for the variable names, or ask the user for the values.}"
  # Escape backslashes and quotes so the reason stays valid JSON on stdout.
  reason="$(printf '%s' "$reason" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
  # Emit combined output:
  #   - flat keys for GitHub Copilot
  #   - hookSpecificOutput for Claude Code & Command Code
  printf '{"permissionDecision":"deny","permissionDecisionReason":"%s","hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason" "$reason"
fi

exit 0
