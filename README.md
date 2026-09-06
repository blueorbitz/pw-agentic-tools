# PW Agentic tools

versions: 0.1.0

Personal productivity tools to work with AI.

## Setup for VS Code

### CLI

1. Run `copilot plugin marketplace add ~/<path_to>/pw-agentic-tools`
2. Run `copilot plugin marketplace browse blueorbitz` to verify
3. Run `copilot plugin install pw-agentic-tools@blueorbitz`

### IDE

1. Go to "Extension"
2. Add agent plugins, and insert the path of the repo.
3. Go to settings, `chat.promptFilesLocations`
  - Add `~/<path_to>/pw-agentic-tools/prompts`
4. Go to settings, `chat.instructionsFilesLocations`
  - Add `~/<path_to>/pw-agentic-tools/instructions`
5. Go to settings, `chat.hookFilesLocations`
  - Add `~/<path_to>/pw-agentic-tools/hooks`

## Hooks

### Block reading of `.env` files

A `preToolUse` hook prevents agents from reading secret environment files.

- **Blocked**: `.env` and variants (`.env.local`, `.env.production`, `.env.test`, ...), plus shell commands that read them (e.g. `cat .env`).
- **Allowed**: anything containing `.example` (e.g. `.env.example`), plus non-secret files like `.envrc` and `foo.env`.

The agent is told to read `.env.example` for the variable names or ask you for the values.

To disable this hook, remove the `preToolUse` entry from `hooks/hooks.json` (or set `"disableAllHooks": true` at the top of the file).

See [docs/hooks-setup.md](docs/hooks-setup.md) for setup on Claude Code, Command Code, and OpenCode.
