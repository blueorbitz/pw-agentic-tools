#!/usr/bin/env bash
# Blocks agent reads of .env and its variants, while allowing .env filenames
# that contain "example" (such as .env.example).
#
# Supports: GitHub Copilot, Claude Code, Command Code, OpenCode hook payloads.
# Dependency-free: uses standard Unix text-processing tools.
set -euo pipefail

payload="$(cat)"
[ -n "$payload" ] || exit 0

# Flatten to one line; remove only actual CR/LF characters.
text="$(printf '%s' "$payload" | tr -d '\r\n')"
[ -n "$text" ] || exit 0

json_field() {
  printf '%s\n' "$2" | awk -v wanted="$1" '
    function skip_ws(pos,    c) {
      while (pos <= length(json)) {
        c = substr(json, pos, 1)
        if (c !~ /[[:space:]]/) break
        pos++
      }
      return pos
    }

    function read_string(pos,    i, c, escaped) {
      string_value = ""
      escaped = 0
      for (i = pos + 1; i <= length(json); i++) {
        c = substr(json, i, 1)
        if (escaped) {
          string_value = string_value "\\" c
          escaped = 0
        } else if (c == "\\") {
          escaped = 1
        } else if (c == "\"") {
          string_end = i
          return string_value
        } else {
          string_value = string_value c
        }
      }
      string_end = length(json)
      return string_value
    }

    function value_end(pos,    i, c, depth, quoted, escaped) {
      if (substr(json, pos, 1) == "\"") {
        read_string(pos)
        return string_end + 1
      }
      depth = 0
      quoted = 0
      escaped = 0
      for (i = pos; i <= length(json); i++) {
        c = substr(json, i, 1)
        if (quoted) {
          if (escaped) escaped = 0
          else if (c == "\\") escaped = 1
          else if (c == "\"") quoted = 0
        } else if (c == "\"") {
          quoted = 1
        } else if (c == "{" || c == "[") {
          depth++
        } else if (c == "}" || c == "]") {
          if (depth == 0) return i
          depth--
          if (depth == 0) return i + 1
        } else if (c == "," && depth == 0) {
          return i
        }
      }
      return length(json) + 1
    }

    {
      json = $0
      pos = skip_ws(1)
      if (substr(json, pos, 1) != "{") exit
      pos++
      while (pos <= length(json)) {
        pos = skip_ws(pos)
        if (substr(json, pos, 1) == ",") {
          pos++
          continue
        }
        if (substr(json, pos, 1) == "}" || substr(json, pos, 1) == "") exit
        if (substr(json, pos, 1) != "\"") exit

        key = read_string(pos)
        pos = skip_ws(string_end + 1)
        if (substr(json, pos, 1) != ":") exit
        start = skip_ws(pos + 1)
        end = value_end(start)

        if (key == wanted) {
          if (substr(json, start, 1) == "\"") {
            read_string(start)
            printf "%s", string_value
          } else {
            printf "%s", substr(json, start, end - start)
          }
          exit
        }
        pos = end
      }
    }
  '
}

# ── Tool name ──────────────────────────────────────────────────────────
# Accept camelCase (Copilot: toolName), snake_case (Claude Code / Command
# Code: tool_name), and display-name (Command Code: tool_display_name).
tool="$(json_field toolName "$text")"
[ -n "$tool" ] || tool="$(json_field tool_name "$text")"
[ -n "$tool" ] || tool="$(json_field tool_display_name "$text")"
tool="$(printf '%s' "$tool" | tr '[:upper:]' '[:lower:]')"

# Only direct file reads, shell commands, and grep can pull .env contents.
case "$tool" in
  view|read|read_file|bash|powershell|shell|shell_command|grep) ;;
  *) exit 0 ;;
esac

# ── Tool arguments ─────────────────────────────────────────────────────
# Read only the top-level arguments field; later event fields must not affect
# the decision. toolArgs may be a JSON string or object.
args="$(json_field toolArgs "$text")"
[ -n "$args" ] || args="$(json_field tool_input "$text")"
[ -n "$args" ] || exit 0

if [ "$tool" = grep ]; then
  grep_args="$(printf '%s' "$args" | sed 's/\\//g')"
  args="$(json_field path "$grep_args")"
  [ -n "$args" ] || args="$(json_field paths "$grep_args")"
  [ -n "$args" ] || args="$(json_field file_path "$grep_args")"
  [ -n "$args" ] || args="$(json_field absolute_path "$grep_args")"
  [ -n "$args" ] || args="$(json_field filePath "$grep_args")"
  [ -n "$args" ] || exit 0
fi

# Shell commands that only inspect names or metadata (for example pwd, ls,
# find, and git status) do not read file contents.
case "$tool" in
  bash|powershell|shell|shell_command)
    args_plain="$(printf '%s' "$args" | sed 's/\\//g')"
    if ! printf '%s' "$args_plain" | grep -qiE '(^|[^a-zA-Z0-9_])(cat|head|tail|less|more|sed|awk|grep|rg|source|python|python3|node|ruby|perl|php|jq|yq|dd|strings|wc|sha256sum|shasum|md5sum|base64|xxd|od|cmp|diff|cp|file)([[:space:]]|$)|(^|[^a-zA-Z0-9_])git[[:space:]]+(show|diff)([[:space:]]|$)|(^|[;&|][[:space:]]*|"[[:space:]]*)\.[[:space:]]+'; then
      exit 0
    fi
    ;;
esac

has_blocked_env_reference() {
  printf '%s' "$1" | awk -F '[[:space:];&|<>()]' '
    {
      for (i = 1; i <= NF; i++) {
        filename = tolower($i)
        sub(/^.*\//, "", filename)
        if (filename ~ /(^|[^[:alnum:]])\.env([^[:alnum:]]|$)/ &&
            filename !~ /example/) {
          found = 1
        }
      }
    }
    END { exit !found }
  '
}

args_plain="$(printf '%s' "$args" | sed 's/\\//g')"
if ! has_blocked_env_reference "$args_plain"; then
  exit 0
fi

# ── Deny ───────────────────────────────────────────────────────────────
reason="${ENV_BLOCK_REASON:-Reading .env files is blocked by policy. Read .env.example for the variable names, or ask the user for the values.}"
# Escape backslashes and quotes so the reason stays valid JSON on stdout.
reason="$(printf '%s' "$reason" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"
# Emit combined output:
#   - flat keys for GitHub Copilot
#   - hookSpecificOutput for Claude Code & Command Code
printf '{"permissionDecision":"deny","permissionDecisionReason":"%s","hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason" "$reason"

exit 0
