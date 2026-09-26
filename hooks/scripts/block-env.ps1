# Blocks agent reads of .env and its variants (view tool + shell commands),
# while allowing anything containing ".example" (.env.example, ...).
#
# Supports: GitHub Copilot, Claude Code, Command Code, OpenCode hook payloads.
# Dependency-free: built into Windows PowerShell 5.1+. No modules required.
Set-StrictMode -Version Latest

$payload = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($payload)) { exit 0 }

$event = $payload | ConvertFrom-Json

function Get-EventProp($name) {
  if ($event.PSObject.Properties.Name -contains $name) { return $event.$name }
  return $null
}

# ── Tool name ──────────────────────────────────────────────────────────
# Accept camelCase (Copilot: toolName), snake_case (Claude Code / Command
# Code: tool_name), and display-name (Command Code: tool_display_name).
$toolName = [string](Get-EventProp 'toolName')
if (-not $toolName) { $toolName = [string](Get-EventProp 'tool_name') }
if (-not $toolName) { $toolName = [string](Get-EventProp 'tool_display_name') }
$toolName = $toolName.ToLowerInvariant()

# Only direct file reads, shell commands, and grep can pull .env contents.
if ($toolName -notmatch '^(view|read|read_file|bash|powershell|shell|shell_command|grep)$') { exit 0 }

# ── Tool arguments ─────────────────────────────────────────────────────
# toolArgs (Copilot camelCase) may be a string; tool_input (Claude Code /
# Command Code) is an object.  Normalize to a flat lookup.
$toolArgsRaw = Get-EventProp 'toolArgs'
if ($null -eq $toolArgsRaw) { $toolArgsRaw = Get-EventProp 'tool_input' }

$argsObj = @{}
if ($toolArgsRaw) {
  if ($toolArgsRaw -is [string]) {
    $parsed = $toolArgsRaw | ConvertFrom-Json
    $parsed.PSObject.Properties | ForEach-Object { $argsObj[$_.Name] = $_.Value }
  } else {
    $toolArgsRaw.PSObject.Properties | ForEach-Object { $argsObj[$_.Name] = $_.Value }
  }
}

$target = ''
switch -Regex ($toolName) {
  '^(view|read|read_file|grep)$' {
    foreach ($key in @('path', 'file_path', 'absolute_path', 'filePath', 'pattern', 'query')) {
      if ($argsObj.ContainsKey($key) -and $argsObj[$key]) { $target = [string]$argsObj[$key]; break }
    }
    # Also scan command for grep tool (grep can be called via shell)
    if ($toolName -eq 'grep' -and -not $target) {
      foreach ($key in @('command', 'args')) {
        if ($argsObj.ContainsKey($key) -and $argsObj[$key]) { $target = [string]$argsObj[$key]; break }
      }
    }
  }
  '^(bash|powershell|shell|shell_command)$' {
    if ($argsObj.ContainsKey('command') -and $argsObj['command']) { $target = [string]$argsObj['command'] }
  }
}
if (-not $target) { exit 0 }

# ── Allowlist ──────────────────────────────────────────────────────────
# ".example" anywhere marks a safe template (PS -match is case-insensitive).
if ($target -match '\.example') { exit 0 }

# ── Deny ───────────────────────────────────────────────────────────────
# Match a ".env" token or variant (.env.local, .env.production, .env-backup).
# Boundary is any non-alphanumeric (or end) on each side.
if ($target -match '(^|[^a-z0-9])\.env([/._-]|$)') {
  $reason = $env:ENV_BLOCK_REASON
  if (-not $reason) { $reason = 'Reading .env files is blocked by policy. Read .env.example for the variable names, or ask the user for the values.' }
  $reason = $reason.Replace('\', '\\').Replace('"', '\"')
  # Emit combined output:
  #   - flat keys for GitHub Copilot
  #   - hookSpecificOutput for Claude Code & Command Code
  @{
    permissionDecision = 'deny'
    permissionDecisionReason = $reason
    hookSpecificOutput = @{
      hookEventName = 'PreToolUse'
      permissionDecision = 'deny'
      permissionDecisionReason = $reason
    }
  } | ConvertTo-Json -Compress -Depth 5
}
exit 0
