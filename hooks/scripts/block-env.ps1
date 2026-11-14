# Blocks agent reads of .env and its variants, while allowing .env filenames
# that contain "example" (such as .env.example).
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
  '^(view|read|read_file)$' {
    foreach ($key in @('path', 'file_path', 'absolute_path', 'filePath')) {
      if ($argsObj.ContainsKey($key) -and $argsObj[$key]) { $target = [string]$argsObj[$key]; break }
    }
  }
  '^grep$' {
    foreach ($key in @('path', 'paths', 'file_path', 'absolute_path', 'filePath')) {
      if ($argsObj.ContainsKey($key) -and $argsObj[$key]) { $target = [string]$argsObj[$key]; break }
    }
  }
  '^(bash|powershell|shell|shell_command)$' {
    if ($argsObj.ContainsKey('command') -and $argsObj['command']) { $target = [string]$argsObj['command'] }
    if ($target -and $target -notmatch '(?i)(^|[;&|()\s])(Get-Content|gc|cat|head|tail|less|more|sed|awk|grep|rg|Select-String|source|python|node|ruby|perl|php|jq|yq|dd|strings|wc|sha256sum|shasum|md5sum|base64|Format-Hex|od|cmp|diff|Copy-Item|cp|file)(\s|$)|(^|[;&|]\s*)git\s+(show|diff)(\s|$)|(^|[;&|()]\s*)\.\s') {
      exit 0
    }
  }
}
if (-not $target) { exit 0 }

function Test-BlockedEnvReference([string]$value) {
  foreach ($token in ($value -split '[\s;&|<>()]')) {
    $filename = ($token -split '[/\\]')[-1].ToLowerInvariant()
    if ($filename -match '(^|[^a-z0-9])\.env([^a-z0-9]|$)' -and $filename -notmatch 'example') {
      return $true
    }
  }
  return $false
}

if (Test-BlockedEnvReference $target) {
  # ── Deny ─────────────────────────────────────────────────────────────
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
