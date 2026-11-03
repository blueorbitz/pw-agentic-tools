---
description: 'Generate docs/CODEBASE_101.md, an evidence-based onboarding guide for a developer new to this repository.'
---

# Codebase 101

Inspect this repository and write `docs/CODEBASE_101.md`: a guide that lets a competent engineer who is new to this codebase, and possibly its stack, understand it, navigate it, run it, and change it safely. It is not a README. Add synthesis; do not copy existing docs.

## Rules

- Create only `docs/CODEBASE_101.md`. If it exists, stop and ask. Change no source, tests, config, schemas, dependencies, or infrastructure. Fix no defects.
- Never open `.env` files, keys, credential or token files, production data, or personal data. Use variable names, schemas, and examples. Never write a secret value.
- Base every claim on files you read. Cite `path` and symbol. Tag deductions `Inferred` and gaps `Unknown`. Never invent components, flows, or behavior.
- Describe what the code does, never why it was built that way, unless a repo doc, comment, or commit message says so. Cite it.
- Run only safe, local, read-only checks (for example `--help` or listing tests). No installs, builds, test runs, deploys, or anything needing credentials. Read a script before running it.

## Investigate

1. Classify the repo: service, web app, library or SDK, CLI, data pipeline, infrastructure, mobile app, monorepo, or other. Include only the sections below that fit. Omit the rest; no "N/A" filler.
2. Read the README and docs, manifests, config, entry points, core modules, tests, and CI. Whatever you do not read is `Unknown`.
3. Identify the 3-5 major capabilities (fewer if the repo has fewer). Trace each from trigger to result across modules.
4. Look again for traps: hooks, middleware, decorators, code generation, feature flags, migrations, startup registration, misleading names, generated files, hard-to-reverse operations, and docs that contradict the code.

## Output

Use these sections in order. Sections tagged (if applicable) apply only when the repo type calls for them.

1. **What this is**: purpose, users or callers, inputs, outputs, repo type, and stack in one table.
2. **Mental model**: a context `flowchart`, plus 5-8 core concepts in plain language. This is also the glossary.
3. **Repo map**: an annotated directory tree with generated and vendored paths flagged. Start with a "Read these 5 files first" list, in order.
4. **Runtime and lifecycle** (if applicable): startup, processes, background work, shutdown.
5. **Key flows**: one `sequenceDiagram` per capability. Under each, list the trigger, entry point, validation, state changes, external calls, result, failure behavior, and the test that proves it (or `No test found`).
6. **Data model** (if applicable): only when there is persistent storage. An `erDiagram` of key entities and relationships, who writes each, invariants, migrations, and caches. Source from migrations or models. Never connect to a live database.
7. **Public API and usage** (if applicable): for libraries, SDKs, and CLIs. The surface area and the typical usage path.
8. **UI map** (if applicable): for frontends. A screen-navigation `flowchart`, a route-to-component table, and each screen's key elements and actions.
9. **Config and external systems**: environment variable names (no values), services, and integrations.
10. **Develop locally**: prerequisites, setup, run, test, lint, build. Label each command `Verified` (you ran it), `Documented` (a manifest, script, CI job, or doc states it), or `Unverified`.
11. **Change guide**: a "Where do I change...?" table, files that change together, generated files not to edit by hand, and one safe first change.
12. **Pitfalls and unknowns**: the traps found, doc-versus-code conflicts, and questions only maintainers can answer.
13. **Key files read**: a table of what each file proves. Not an exhaustive list.

## Style

- Reference style: lead with a diagram or table. Use prose only to explain. Paragraphs are at most 4 sentences.
- Diagrams are Mermaid, use names from the repo, and have at most about 15 nodes. Add `stateDiagram-v2` for entity lifecycles, `classDiagram` for core types in OO-heavy code, and a DFD-style `flowchart` for pipelines.
- Screenshots are optional. If the user gave image paths or a folder, reference each in place by relative path with a one-line caption under its screen. Do not copy files. Never ask for screenshots; the doc must stand without them.

## Verify

Before finishing, confirm that every cited path exists and every Mermaid block parses (use a validator if one is available; otherwise mark the check `Unverified`). End with the file created and the major unknowns.

