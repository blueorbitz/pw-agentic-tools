---
name: "pw-code-tutorial-generic"
description: "Inspect a repository and build an evidence-based onboarding dossier and tutorial for a new developer. Requires the unlazy and teach skills."
agent: "pakwai-generic"
---

# Build a codebase onboarding tutorial

Inspect the current repository and teach it to an engineer who has never seen it. Assume they do not yet know which questions to ask.

The result must let them:

- Explain the product, its users, inputs, outputs, and verified capabilities.
- Run the verified local development loop.
- Trace startup and each major capability through real code.
- Find the files involved in a common change.
- Describe the data, trust, deployment, and failure boundaries.
- Separate evidence, inference, conflicts, and missing knowledge.

## Required skills

Load and follow [unlazy](../skills/engineering/unlazy/SKILL.md) and [teach](../skills/productivity/teach/SKILL.md) before investigating. Stop and name any unavailable skill.

## Safety and write boundary

- The skills may create their required artifacts. You may also create or update `docs/CODEBASE_101.md`.
- Create no other files. Do not change source code, tests, schemas, configuration, dependencies, generated files, infrastructure, or CI. Do not fix discovered defects.
- If `docs/CODEBASE_101.md` exists, stop and ask before changing it.
- Never open `.env` files, private keys, credential stores, token files, production data, files that appear to contain personal data, or other secret-bearing files. Use examples, schemas, variable names, and code references. Record each exclusion without quoting its contents.
- Read a script before running it. Run only local, reversible checks that do not install packages, deploy, change data, start paid services, or require credentials. Mark checks that cannot run safely as `Unverified`.

## Investigation

### Repository inventory

Inventory tracked files and non-ignored untracked files in the current worktree. If this is not a Git repository, use the closest available listing and state the limitation.

Classify every file as:

1. Read in full.
2. Generated, vendored, minified, binary, dependency cache, or build output.
3. Secret-bearing or sensitive, excluded without opening.
4. Unavailable, unreadable, or outside the repository through a symbolic link.

Read every first-party text file in scope. Listings and search results do not count as reads. Inspect generated manifests and lockfiles with suitable tools, but do not claim a line-by-line read unless one occurred. Do not follow symbolic links outside the repository.

Record the total and each class count, plus the reason for every exclusion. The counts must balance. Use the mode required by `unlazy` for repositories too large for one context. Never sample or silently narrow scope.

### Questions to answer

Use repository evidence for every applicable area. Write `Unknown` when the evidence does not answer a question. Do not claim generic framework behavior unless this repository activates it in code or configuration.

| Area | Required evidence |
| --- | --- |
| Product | Problem, actors, inputs, outputs, and verified product capabilities. |
| Structure | Ownership and dependency boundaries; canonical, generated, and vendored directories. |
| Runtime | Startup order, persistent processes, background work, scheduling, and shutdown. |
| Interfaces | Request, command, event, job, file, and user-action entry points; parsing and validation. |
| Domain and data | Business terms; state ownership, mutation, storage, caching, migration, and deletion. |
| External systems | Services, libraries, protocols, queues, databases, and platform APIs that constrain behavior. |
| Failure behavior | Partial failure, retries, rollback, timeouts, manual recovery, and idempotency. |
| Security | Trust boundaries, identity, permissions, validation, secrets, logging, and data protection. |
| Delivery | Builds, tests, releases, migrations, deployment, monitoring, backup, and rollback. |
| Change mechanics | Files that change together, generated files, contract tests, and a safe first contribution. |
| Knowledge gaps | Conflicting claims, controls outside the repository, and questions only maintainers can answer. |

### Execution traces

Identify the verified major product capabilities. Three to five is a useful range, but use the number supported by the repository and do not pad it.

Trace startup and each capability across module boundaries. Every trace must identify:

1. Actor or trigger.
2. Concrete entry point.
3. Input parsing and validation.
4. Authentication and permission checks, when present.
5. Main control flow and domain state changes.
6. Persistence, queues, files, and external calls.
7. Returned result or produced effect.
8. Failure, retry, cleanup, and observability behavior.
9. Tests that prove the behavior.

Name exact workspace-relative paths and important symbols. If dynamic dispatch, generated code, runtime configuration, or an unavailable service breaks a trace, mark the break `Unknown` and state what would resolve it.

### Second pass

Look again for the mistakes a new engineer would make:

- Find hidden behavior in hooks, middleware, decorators, code generation, feature flags, migrations, startup registration, fixtures, and CI scripts.
- Find contracts enforced by tests but absent from prose documentation.
- Compare documented commands and architecture with current code.
- Check partial failure, concurrency, retries, idempotency, time zones, ordering, compatibility, and cleanup.
- Identify files that must not be edited by hand and operations that are hard to reverse.
- Record surprises, misleading directory names, and points only a maintainer can confirm.

Merge this evidence into the result. Never turn inference into fact.

## Evidence dossier

Create `docs/CODEBASE_101.md` as the factual source for the course. Cite workspace-relative paths and symbols. Make it useful to engineers, security reviewers, and product managers.

Use this structure:

1. Executive summary.
2. Product, users, and terminology.
3. Major capabilities.
4. Architecture and runtime processes.
5. Startup and capability traces.
6. Repository map and a "Where do I change...?" table.
7. Local setup, commands, tests, and troubleshooting.
8. Domain state, persistence, and external systems.
9. Security controls, trust boundaries, sensitive assets, and audit leads.
10. Delivery, deployment, observability, recovery, and operational gaps.
11. Extension points and safe contribution paths.
12. New contributor quick start.
13. Risks, conflicting evidence, unknowns, and maintainer questions.
14. Glossary.
15. Evidence and coverage index with inventory totals and exclusions.

Include a readable Mermaid architecture diagram and at least one Mermaid sequence or data-flow diagram. Use repository names. Validate Mermaid syntax when a validator is available; otherwise mark the check `Unverified`.

Separate verified security controls, missing evidence, and audit leads. Call an issue a vulnerability only when direct code evidence shows a reachable path. Never include a secret value.

Document commands only when supported by a manifest, script, CI job, container file, or maintained documentation. Include required environment variable names without values. Label conflicting and untested commands.

## Tutorial

After the dossier is complete, use `teach` with this mission:

> Become able to navigate, run, explain, debug, and make a small safe change to this repository without relying on tribal knowledge.

Ground the tutorial in the repository and `docs/CODEBASE_101.md`. Teach the verified product purpose, vocabulary, local workflow, runtime model, major capabilities, change locations, failure boundaries, and important unknowns. Turn the evidence into guided learning instead of repeating the dossier as prose.

## Completion

Use `unlazy` to verify repository coverage and completion. Report success only after the investigation, dossier, and tutorial are complete. Name the dossier and tutorial workspace, state all file coverage counts, and list unresolved knowledge gaps.