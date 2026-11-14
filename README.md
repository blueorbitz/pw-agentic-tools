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

The agent plugin loads its hooks automatically. Do not also add its hooks to
`chat.hookFilesLocations`, as that can run the hook twice.

## Hooks

### Block reading of `.env` files

A `preToolUse` hook prevents agents from reading secret environment files.

- **Blocked**: direct reads of `.env` and variants (`.env.local`, `.env.production`, `.env.test`, ...) through file-read tools and common shell readers (e.g. `cat .env`).
- **Allowed**: `.env` filenames containing `example` (e.g. `.env.example`), non-secret files like `.envrc` and `foo.env`, and commands that only list filenames or metadata.

The agent is told to read `.env.example` for the variable names or ask you for the values.

The hook uses `COPILOT_PLUGIN_ROOT`, supplied by Copilot, to find its script
inside the plugin even when another project is open. After changing the hook,
start a new chat so Copilot loads the updated configuration.

To disable this hook, remove the `preToolUse` entry from `hooks/hooks.json` (or set `"disableAllHooks": true` at the top of the file).

See [docs/hooks-setup.md](docs/hooks-setup.md) for setup on Claude Code, Command Code, and OpenCode.
