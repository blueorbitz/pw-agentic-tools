---
name: "pw-pull-request-message"
description: "Generate an evidence-based pull request title and description from the current branch diff."
argument-hint: "[base branch or pull request context]"
agent: "pakwai-generic"
---

# Write a pull request message

Act as a senior developer writing a pull request for the team. Inspect the current branch diff and generate a title and description that match the verified changes.

## Requirements

- Use Conventional Commits format, `<type>(<scope>): <summary>`, and keep the title to 72 characters or fewer.
- Use `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, or `ci`. Set the scope to the primary module or file area. Write an imperative summary of what the change does, not what was done. Keep it outcome-focused and omit file names.
- Order the description as `What changed`, `Why`, `How to test`, then `Breaking changes`.
- Give `What changed` two to four bullets covering every meaningful change. Make `Why` one sentence about the motivation or problem solved. Give specific test steps a reviewer can follow. List each breaking change or write `None`.
- Base every claim on the diff. Do not invent changes or add features or modifications beyond it. If it is ambiguous, state only what you can verify and note the uncertainty.

## Output

Return exactly one Markdown code block and no text outside it:

````markdown
```markdown
### Title
<type>(<scope>): <summary>

### Description

#### What changed
- <meaningful change>

#### Why
<one-sentence motivation>

#### How to test
1. <verification step>

#### Breaking changes
None
```
````