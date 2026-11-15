---
name: advisor
description: Advisor second opinion when stuck, committing to an approach, or declaring done.
---

# Advisor

Separate execution from judgment. The executor keeps running the task end-to-end with a fast model. At key decision points, hand the full conversation to a stronger reviewer model and take back a **plan / correction / stop signal**, then continue.

This fixes a structural problem: **the same model writing code and verifying code tends to prove itself right**. Three recurring failures in long coding-agent runs:

- **Self-verification blind spot** — same model, same context, approves instead of challenges.
- **Long-range drift** — early constraints get buried under tool output; wrong files edited, invalid searches repeated.
- **Premature completion** — declares "done" with nothing saved, no tests run, no boundaries checked.

An independent second opinion mitigates all three.

## Choosing the reviewer model

No single id works everywhere, so pick at run time — strongest judgment available here, never the executor itself. If unclear which reviewer model to use, ask the user which model to use as reviewer. Never guess.

## Two channels

1. **Explicit consultation** — executor asks for review at a decision point, forwarding full context.
2. **Auto patrol** — every N steps, snapshot the session and check for drift. Intervene only on drift or stop.

## When to consult

Call the reviewer:

1. BEFORE substantive work — before writing, before committing to an interpretation, before building on an assumption. Orientation (finding files, fetching a source, seeing what is there) is not substantive work; writing, editing, and declaring an answer are.
2. BEFORE declaring done — and make the deliverable durable first: write the file, save the result, commit the change. Review takes time; if the session ends mid-review, a durable result persists and an unwritten one does not.
3. When stuck — recurring errors, approach not converging, results that do not fit.
4. When evidence contradicts previous advice — reconcile in one more review call instead of silently switching.

On tasks longer than a few steps, consult at least once before committing to an approach and once before declaring done. On short reactive tasks where the next action is dictated by tool output just read, repeated consultation is unnecessary.

## Reviewer contract

Spin up a reviewer (background subagent with a stronger model where available) with the full task, every tool call, and every result. The reviewer returns ONE of:

- a **plan** (concrete next steps the executor should take),
- a **correction** (executor is on the wrong path — redirect it),
- a **stop signal** (executor should halt and escalate to the user).

Reviewer rules:

- NEVER edits code. NEVER changes state. Judgment only, no execution.
- NEVER produces user-facing output. Be concise, directive, grounded in shared context.
- Name files, functions, and line numbers where possible.
- No preamble, no apologies, no meta-commentary — just the guidance the executor needs.
- May read files read-only to verify facts before concluding. Do not write, run destructive commands, or leave the workspace.

Patrol verdict format (first line is machine-readable):

- `ON-TRACK` — progressing correctly; this line only.
- `CORRECTION: <one-paragraph redirect>` — drifted; state what is wrong and the concrete next step.
- `STOP: <reason>` — halt and report to the user.

Flag only substantive drift: wrong files or approach, hallucinated progress, destructive operations, violated user constraints, or task already satisfied while work continues. Do not nitpick style.

## Executor rules

- Give the advice serious weight. If a step fails empirically, or primary-source evidence contradicts a specific claim, adapt — a passing self-test is not evidence the advice is wrong.
- If retrieved data points one way and the reviewer points another, do not silently switch — surface the conflict in one more review call. A reconcile call is cheaper than committing to the wrong branch.
- After each review result, restate its key guidance (plan / correction / stop) in the next visible reply before continuing. Tool results are often collapsed; the user cannot see them.
- A review failure (timeout, auth error, empty response, context overflow) never kills the turn. Note the failure, continue with best judgment, and retry once later if the decision still matters.

## Patrol mode

For long tasks, run a patrol check every 6 model-request steps (tune 2–500 by task length; use a large interval as a safety net only):

1. Snapshot: tool inventory + full conversation so far + the question "is the executor still on track?"
2. Get a patrol verdict per the reviewer contract.
3. `ON-TRACK` — continue silently. Unparseable verdict — log and ignore, do not disturb.
4. `CORRECTION` — adjust approach now, acknowledge briefly in the next visible reply, then continue. Cool down: suppress further corrections for the next 3 steps to avoid nag loops. Deduplicate: drop corrections already applied.
5. `STOP` — halt immediately and report to the user. Stop bypasses cooldown and dedup.

Patrol never interrupts an in-flight turn; the intervention lands on the next request.

## Cost control

- Each review costs one full-context call to the reviewer model. Strong reviewer on key nodes only; fast cheap model runs the main line.
- If no reviewer model is configured, skip registration entirely: no tool, no prompt section, zero cost.
- Skip review for routes that do not benefit (already-strong executor model). Match by `model`, `provider/model`, or `provider/model@minEffort`.
- On context overflow, truncate symmetrically from the middle (keep head constraints + tail evidence), then retry once.
- On unsupported reasoning effort, retry once at the model default.

## Why not just a subagent code review?

A subagent is another executor: fresh context, tools, produces a report. The advisor is a judgment layer: inherits the full session, outputs only plan / correction / stop, costs one side call. Use subagents for independent verification and parallel exploration; use advisor for low-cost, high-frequency direction checks close to the main loop.

Inspired by: [Anthropic: The advisor strategy](https://claude.com/blog/the-advisor-strategy), [oh-my-pi advisor/watchdog](https://github.com/can1357/oh-my-pi/blob/main/docs/advisor-watchdog.md), [rpiv-advisor](https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-advisor).
