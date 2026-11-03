---
name: technical-writing
description: Write reader-focused technical docs through an interview, source investigation, visual evidence, and a final prose edit.
disable-model-invocation: true
argument-hint: "Topic or existing document, intended reader, and desired outcome"
tags: [documentation, writing]
---

# Technical writing

Work as a technical writer with an engineer's curiosity. Investigate how the subject works before explaining it. The reader's task decides what belongs in the document.

## 1. Establish the brief

Use the user's request and supplied material first. Ask focused questions with the available question tool, grouping related gaps rather than sending a long questionnaire:

- Who will read this, what do they already know, and what should they be able to do or understand afterward?
- What prompted the document? What questions must it answer, and what is out of scope?
- What sources, product version, or existing document should it reflect?
- Where will it be published, in what language, and with what length, format, or accessibility constraints?
- Are there supplied images or recordings, or an app that can be used to capture the relevant workflow?

Do not ask again for answers already supplied or ask the user to research facts you can inspect. If no question tool exists, ask in chat. If the user declines questions, state the assumptions and continue only where they do not risk misleading readers.

Done when the audience, intended outcome, scope, sources, and delivery constraints are known or explicitly assumed. Leave source-level questions for investigation.

## 2. Investigate the subject

Inspect relevant code, tests, existing docs, schemas, and official sources. Follow the reader's task through its dependencies and failure paths rather than summarizing filenames or repeating marketing copy.

Probe what a reader would otherwise have to guess: why a step exists, how data moves, who has access, which versions apply, what success looks like, and how failures are handled. Distinguish current behavior from intended behavior.

Keep a working claim-to-source list without creating a separate file unless requested. Resolve contradictions against the target version. Ask follow-up questions only when intent, missing evidence, or conflicting sources would change the document.

Done when every planned technical claim has supporting evidence, and every remaining unknown is either resolved, excluded, or explicitly marked. Do not invent behavior, commands, measurements, or decisions.

## 3. Choose the document and structure

Choose after investigation, not from a fixed template:

- Tutorial for learning by doing. Use a bounded exercise, prerequisites, steps, checkpoints, and a final result.
- How-to guide for a specific task. Start with the goal, then prerequisites, actions, verification, and likely failures.
- Explanation for understanding. Start with the central idea, then the model, mechanisms, tradeoffs, and limits.
- Reference for lookup. Group the exact contracts, parameters, defaults, constraints, examples, and errors by what readers search for.
- README for first contact. Explain the purpose, provide the shortest working start, then link to deeper guides and reference.
- Decision record for a choice. Record status, context, evidence, alternatives, the decision, and consequences. Do not present a proposal as an accepted decision.
- Runbook for an operational procedure. Include entry conditions, access, actions, success checks, recovery, and escalation.

Use the repository's existing conventions. For mixed needs, pick a primary type and link to supporting documents rather than combining a tutorial, reference, and design essay into one page. Create multiple documents only when the requested scope warrants them.

Show the chosen type and a short outline. Request confirmation only if the choice changes scope or leaves a consequential ambiguity.

Done when every section serves the reader's outcome and each required question has a place in the outline.

## 4. Draft with visual evidence

Lead with the result or main point. Put prerequisites before actions and warnings before risky steps. Give procedures observable checkpoints and examples that match the target version.

Evaluate where a visual would explain something better than prose:

- Mermaid for relationships, sequences, states, and data flow.
- Real screenshots for UI locations and visible results.
- Short recordings for interactions whose order, timing, or motion matters.

Prefer a useful visual whenever feasible, not decoration or a quota. Before creating or requesting visuals, read [Visual evidence](./visual-evidence.md). Keep essential instructions in text so the document remains usable without the media.

Remove tangents and link to authoritative detail instead of copying it. Keep citations close to non-obvious claims, using the destination's link conventions.

Done when the draft covers the outline, every visual explains a specific point, and no placeholder is presented as finished evidence.

## 5. Edit for the reader

Invoke `unslop` for the final prose pass. If invocation is unavailable, read the [unslop instructions](../unslop/SKILL.md) directly. Do not apply prose edits to code, commands, identifiers, or structured data.

Match the audience's vocabulary. Explain necessary terms on first use without removing technical distinctions. Preserve uncertainty, limitations, and warnings while cutting noise. Do not add personality or opinions that distort a factual document.

Done when each paragraph helps the reader act or understand, and the prose pass has preserved technical meaning.

## 6. Verify and deliver

Walk through the document as the intended reader:

- Check every required question from the brief against the finished text.
- Verify every command, example, path, and claimed result against sources. Run safe examples where authorized. Never run destructive or externally consequential actions just to validate prose.
- Check links, relative asset paths, and media availability. Render diagrams and inspect captures using available tools.
- Check prerequisites, permissions, failure cases, and recovery wherever the procedure needs them.
- Save to the agreed location or return the document in the agreed format. Do not publish externally without permission.

Done when all applicable checks pass, or their precise blockers are disclosed. Report what was produced and any unverified claims or unavailable captures. Do not call an untested procedure tested or a source review a runtime verification.
