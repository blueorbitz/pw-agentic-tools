# Hooks Setup

Setup instructions for using the `.env` blocking hook with Claude Code, Command Code, and OpenCode.

For GitHub Copilot, see the main [README](../README.md).

Copilot loads this hook through the installed agent plugin and supplies
`COPILOT_PLUGIN_ROOT` so the script path does not depend on the open project.
Do not also register `hooks/hooks.json` as a standalone hook. If you need a
standalone configuration instead, copy it and replace the `bash` and
`powershell` script paths with quoted absolute paths to your local scripts.
Start a new chat after changing hook configuration.

---

## Claude Code

Add the hook to your global settings (`~/.claude/settings.json`) or project settings (`.claude/settings.json`):

**macOS / Linux:**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Read|Grep",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.agents/hooks/scripts/block-env.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**Windows:**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Read|Grep",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -NoProfile -ExecutionPolicy Bypass -File $HOME/.agents/hooks/scripts/block-env.ps1",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

---

## Command Code

Add the hook to your global settings (`~/.commandcode/settings.json`) or project settings (`.commandcode/settings.json`):

**macOS / Linux:**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "shell|read",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.agents/hooks/scripts/block-env.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**Windows:**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "shell|read",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -NoProfile -ExecutionPolicy Bypass -File $HOME/.agents/hooks/scripts/block-env.ps1",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

---

## OpenCode

Copy or symlink the plugin file to your OpenCode plugins directory:

```bash
# Global (all projects) — from the repo root:
cp .opencode/plugins/block-env.mjs ~/.config/opencode/plugins/

# Or project-level
cp .opencode/plugins/block-env.mjs <your_project>/.opencode/plugins/
```

The plugin uses OpenCode's `tool.execute.before` hook to block `.env` reads. No additional config needed.

---

## Disabling the hook

- **GitHub Copilot**: set `"disableAllHooks": true` in `hooks/hooks.json` or your repository `settings.json`.
- **Claude Code / Command Code**: remove the `PreToolUse` entry from your `settings.json`.
- **OpenCode**: remove the `block-env.mjs` file from your plugins directory.
