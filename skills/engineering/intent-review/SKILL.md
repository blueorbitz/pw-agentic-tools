---
name: intent-review
description: Compare a change with its intended outcome and report only necessary, evidence-backed fixes.
disable-model-invocation: true
tags: [review, intent]
---

# Intent review

Reduce the human review to decisions that matter. Review only; do not edit code, commit, or post to GitHub unless the user asks.

## 1. Establish the intent

Identify the review target and its boundary. For a PR, record the base and head revisions. For a branch, compare with the merge base of its intended target branch. For local work, distinguish staged, unstaged, and untracked changes. With no target, use all uncommitted changes; if there are none, ask rather than silently reviewing the last commit. For selected files or snippets, state that the review is partial.

Read user-provided requirements, any supplied Jira ticket including acceptance criteria, and the PR description. Use available authenticated tools, preferably `gh` for GitHub. If a source is inaccessible, say which one and ask for the relevant text. Do not require Jira when another source defines the outcome.

Extract the problem, observable outcomes, constraints, and explicit exclusions. Keep source links beside requirements. The diff is evidence of implementation, not evidence of intent. Tests and comments can explain behavior but cannot establish the requested outcome on their own.

If sources conflict or leave a decision that changes the verdict unresolved, ask the user to resolve that specific point. Do not silently rank Jira above the PR description or treat every extra change as unwanted. If the user declines clarification, review provable defects but mark intent unresolved.

Done when the target and revisions are explicit and each requirement is checkable, or the missing intent is identified without invented requirements.

## 2. Compare intent with implementation

Read the full in-scope diff and repository instructions. Build a private checklist of every requirement and changed behavior. Follow the affected flow through entry points, callers, persistence, outputs, tests, configuration, and rollout where relevant. When a contract changes, inspect all discoverable consumers, including unchanged files. Mark unavailable consumers as unchecked.

For each requirement, record `met`, `gap`, or `unverified`, with code or test evidence. A test passing is not enough if its assertions miss the required output, boundary, or measurable threshold. Treat omissions as gaps even when the implemented subset works.

Account for each changed behavior as required, supporting the intent, or unexplained. Report unexplained scope only when it creates a concrete regression, violates an exclusion, or adds a demonstrable maintenance burden. Ask about a consequential ambiguity instead of calling it a defect.

Check correctness, trust boundaries, data integrity, concurrency, realistic load, performance, accessibility, compatibility, and error handling where the changed flow reaches them. Derive expected load from project evidence; do not invent production scale. Check that risky new logic has a test that detects its failure, especially parsers, branches, writes, money, authorization, and bug fixes.

Done when every requirement has a status, every changed behavior is accounted for, and affected contracts have traced consumers or explicit coverage limits. Keep this checklist out of the response unless requested.

## 3. Apply the Ponytail test

This review adapts the [Ponytail philosophy](https://github.com/dietrichgebert/ponytail): understand the real flow before proposing a smaller solution.

For added complexity, ask in order:

1. Does the intended outcome need this behavior?
2. Can existing repository code provide it?
3. Can the standard library, platform, or an installed dependency provide it?
4. What is the simplest remaining implementation that preserves the contract?

Stop at the first option that satisfies the requirements. Name the existing helper or API and explain why it is equivalent before recommending reuse. A shorter expression is not a better fix if it obscures the logic.

Keep validation, error reporting, security, data-loss protection, and accessibility intact. Respect documented shortcuts within their stated limits; flag them only if the current requirements or expected load exceed those limits.

Report simplification only when it removes an identifiable cost, such as duplicated rules that must change together, an unnecessary dependency, or unsupported behavior someone must maintain. No line-count limits, speculative abstractions, cosmetic rewrites, or style preferences.

Done when each simplification has an equivalent replacement or justified deletion and a concrete benefit beyond fewer lines.

## 4. Verify and filter

For every candidate finding, trace a reachable condition to a violated requirement or concrete consequence. Re-read surrounding guards, callers, existing tests, and relevant library behavior. Compare with the base revision so unrelated pre-existing defects do not become findings.

Use the smallest existing test or safe reproduction that checks the claim when execution is available. Follow repository tooling and permission rules. Do not use shared production data or mutate external systems. Distinguish executed evidence from static reasoning; never imply tests ran when they did not.

A missing-test finding must name the risky scenario and the regression assertion that would catch it. Do not request coverage percentages or tests for trivial changes without a risk.

Discard disproved claims and speculative worries. Combine findings with the same root cause, rank by impact, and retain every independent actionable issue. Brevity is not a finding quota.

Done when every retained finding has a location, evidence, consequence, and smallest viable correction. Unresolved checks remain limitations, not confirmed defects.

## 5. Return the decision

Start with one sentence stating the intended outcome and its source. Then state whether the implementation matches, partly matches, or cannot yet be assessed. Mention the reviewed revisions or local scope briefly.

List numbered findings, most serious first. Label each `Must fix` for violated requirements, regressions, unsafe behavior, or failure at expected load; use `Should fix` for a demonstrated maintenance cost or a missing regression test. Omit empty groups and optional polish.

Each finding contains:

- A short title and a link to the smallest relevant code location. For a missing implementation, cite the unmet requirement and nearest responsible code.
- The triggering condition, actual behavior, and consequence. Reference the requirement when applicable.
- The smallest correction and a regression check when useful.

Use a few sentences per finding, not a repeated essay template. Do not add praise, a diff tour, cleared-risk lists, or a full requirements table.

End with `Decision: fix <finding numbers> before merging`, `Decision: no blocking findings`, or `Decision: incomplete review`. Use incomplete when missing intent or review coverage prevents a decision. If nothing is found, say so without claiming the change is proven safe.

Add one short `Verification:` line naming checks run, results, and material checks not run. Include unresolved intent or coverage limits that affect the decision.

Done when the reader can identify what needs action and why, and the decision does not overstate the evidence.
