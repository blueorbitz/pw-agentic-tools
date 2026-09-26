---
name: deep-research
description: Conduct iterative deep research on complex questions by decomposing into sub-questions, searching multiple free sources via sub-agents, triangulating evidence with credibility-weighted conflict resolution, and synthesizing a cited report with clear conclusions and open questions. Use when the user asks for deep research, comprehensive analysis, literature review, or "research this thoroughly" — adaptive depth, free search APIs, login-wall access, sub-agent parallelism.
---

# deep-research

**Leading words:** *iterative deepening*, *source triangulation*, *evidence synthesis*, *citation trail*, *research loop*, *adaptive depth*, *credibility-weighted*, *sub-agent parallelism*, *open questions*

This skill runs a **research loop**: decompose → search → extract → triangulate → synthesize → (repeat until convergence). Each loop tightens the answer. The loop goes *red* when a claim lacks a primary source; it goes *green* when every load-bearing claim has a citation trail to a primary source. **Adaptive depth** means the loop budget scales with convergence scores — low scores trigger more loops automatically, or the user can set a depth profile per task. **Sub-agent parallelism** delegates search and extraction to cheaper-model sub-agents running in parallel; the main agent only does decomposition, synthesis, and convergence checking.

## Invocation contract

- **Model-invoked** — the agent fires this skill when the user's request maps to deep research triggers.
- **User-invoked** — type `/deep-research` to force it. Optionally append a depth profile: `/deep-research --fast`, `/deep-research --standard`, `/deep-research --exhaustive`, or `/deep-research --adaptive` (default).
- **Stays on** until the research question is answered to convergence or the user says "stop deep research".
- **Current mode**: Agent skill with file output. Sub-agents used for search/extraction. Background job mode planned for future.

## Triggers (branches)

| Branch | User language that fires it |
|--------|----------------------------|
| Comprehensive analysis | "deep research", "comprehensive analysis", "thorough investigation", "literature review" |
| Multi-source synthesis | "compare sources", "triangulate", "what do experts say", "consensus on" |
| Evidence-based answer | "find evidence for", "primary sources on", "cite your sources", "verify this claim" |
| Iterative refinement | "dig deeper", "go further", "more detail on", "expand on" |
| Adaptive depth control | "quick research", "fast answer", "exhaustive research", "maximum depth" |

## Research loop (steps)

Each step ends on a **completion criterion** — a checkable condition that tells the agent the step is done.

### 1. Decompose the question

Break the user's question into 3–7 **sub-questions** that are:
- **Atomic** — each answers one specific thing
- **Answerable** — can be resolved with search + extraction
- **Non-overlapping** — no two sub-questions ask the same thing
- **Ordered** — dependency order where later questions depend on earlier answers

**Infer the user's decision context** — what decision or outcome are they trying to achieve?
- **Selection/ranking** → Need ranked options with scores, trade-offs, recommendation
- **Strategy/planning** → Need step-by-step approach, dependencies, risks, milestones
- **Risk assessment** → Need downside scenarios, probabilities, mitigations, contingencies
- **Deep understanding** → Need framework, mental models, worked examples, "how to fish"
- **Validation/verification** → Need evidence for/against, confidence intervals, red flags
- **Optimization** → Need Pareto frontier, constraint analysis, sensitivity analysis

**Embed decision context into sub-question ordering:** Later sub-questions should directly feed the decision output format.

**Completion criterion:** Sub-question list written to scratchpad; every sub-question is atomic, answerable, non-overlapping, ordered, and aligned with inferred decision context.

### 1.5. Calibrate user intent (NEW STEP)

Before finalizing sub-questions, run an **intent calibration check**:

**Heuristic:** Does the user's phrasing contain colloquial/imprecise language that maps to a legitimate analytical framework?

| User phrasing | Likely intent | Analytical reframe |
|---------------|---------------|-------------------|
| "guarantee X" / "ensure X" | Highest probability of X | Probabilistic assessment: factors driving X, confidence intervals |
| "best X to choose" | Highest utility given constraints | Multi-criteria decision analysis (weighted factors, trade-offs) |
| "safe X" / "risk-free X" | Minimal downside / robust option | Stress-testing, worst-case analysis, margin of safety |
| "X will happen by Y date" | Probability of X by Y with catalysts | Scenario analysis: base/bull/bear cases, key drivers |
| "no downside" / "can't lose" | Asymmetric upside / optionality | Optionality analysis: limited loss, uncapped gain scenarios |
| "sure thing" / "no-brainer" | High conviction with evidence | Evidence-weighted conviction scoring, red team critique |
| "perfect X" / "ideal X" | Optimal on key dimensions | Pareto frontier analysis: define dimensions, find efficient set |

**Action:** If calibration detects a reframe, **rewrite sub-questions to match the analytical reframe**, not the literal phrasing. Document both the original phrasing and the calibrated intent in the report.

**No-lecture rule:** Never explain why the user's phrasing was imprecise — just deliver the calibrated answer. Zero paragraphs lecturing about "guarantees don't exist."

**Completion criterion:** Sub-questions reflect the *decision-relevant analytical framework*, not just the literal question words. Calibrated intent documented in report.

### 2. Search & extract (parallel via sub-agents)

For each sub-question, spawn a **sub-agent** (cheaper model) to run a **search-extract cycle** in parallel:

1. **Search** — query multiple free source types via available APIs:
   - **Web search**: DuckDuckGo HTML scrape, Brave Search API (free tier), Bing Web Search (free tier)
   - **Academic**: arXiv API, Semantic Scholar API, Crossref API, PubMed API
   - **Technical**: GitHub API (code search), npm/PyPI/crates.io registries, Stack Exchange API
   - **News/Finance**: Yahoo Finance, Alpha Vantage (free tier), SEC EDGAR
   - **Social/Community**: Reddit API (public), Hacker News API, Lobste.rs
   - **Login-wall sources**: Use public archive views (Reddit old.reddit.com/.json, Quora public answers, Rednote public posts), textise dot iitty for paywalled articles, Wayback Machine — no authentication required
   Prioritize primary sources (official docs, specs, source code, peer-reviewed papers, first-party API docs, government data).
2. **Extract** — pull verbatim quotes with source URLs, DOIs, file paths, or line numbers. Tag each extract with: source type, credibility tier (primary/secondary/tertiary), relevance to sub-question, publication date.
3. **Triangulate** — if multiple sources agree, mark *corroborated*; if they conflict, flag *conflict* and note the divergence with credibility-weighted evidence.

Sub-agents return structured extract bundles (JSON) to the main agent. Main agent only does synthesis and convergence.

**Completion criterion:** Every sub-question has ≥2 extracts from ≥2 independent sources, or a single primary source with high credibility. All extracts tagged with source type, credibility tier, relevance, and date.

### 3. Synthesize & cite (main agent)

For each sub-question, write a **synthesis paragraph** that:
- States the answer directly
- Cites every load-bearing claim with a **citation trail** (source → extract → claim)
- Notes conflicts explicitly with both sides' evidence, **resolved by credibility-weighted heuristic**: primary > secondary > tertiary; newer > older (for fast-moving fields); official > unofficial; multiple independent corroboration > single source
- Uses *hedge words* only where evidence genuinely supports uncertainty

**Completion criterion:** Every sub-question has a synthesis paragraph; every load-bearing claim has a citation trail; conflicts are noted with resolution rationale; no unsourced assertions.

### 4. Convergence check & open questions (main agent)

Review the full answer against the original question:
- **Coverage** — does the synthesis address every dimension of the original question?
- **Coherence** — do sub-question answers fit together without contradiction?
- **Citation density** — ≥1 citation per 2–3 sentences in synthesis paragraphs
- **Primary source ratio** — ≥60% of citations point to primary sources
- **Recency score** — ≥70% of citations from sources <2 years old (for fast-moving fields)

**Intent Satisfaction Score** (NEW):
- **Decision utility:** Does the output format match the inferred decision context? (e.g., ranked table for selection, roadmap for planning, scenario matrix for risk)
- **Actionability:** Can the user act on this *today*? (specific options, criteria, next steps, risks)
- **Calibration transparency:** Does the report explicitly state: "You asked X; I interpreted as Y because Z"?
- **No-lecture rule:** Zero paragraphs explaining why the user's phrasing was imprecise — just deliver the calibrated answer.

**Open questions generation:** Identify 3–5 **open questions** that emerged during research — gaps, contradictions, or new angles worth exploring. Surface these explicitly in the output.

**Adaptive loop budget:**
- **Fast** (--fast): 1 loop max, stop after first convergence check
- **Standard** (--standard): 2 loops max
- **Exhaustive** (--exhaustive): 3 loops max
- **Adaptive** (--adaptive, default): Start with 1 loop; if any convergence check scores <80%, auto-continue up to 3 loops; stop early if all checks ≥90%

If any check fails and loops remain, **loop back to step 1** with refined sub-questions targeting the gaps.

**Completion criterion:** All four checks pass, **Intent Satisfaction Score ≥ 80% (self-assessed) OR user confirms "this answers my question,"** or loop budget exhausted. Final report written to output with conclusions and open questions.

## Output format

Write findings to a Markdown file at `docs/research/<NNNN>-<topic-slug>.md`.

**The output format adapts to the inferred decision context:**

| Decision context | Primary output format |
|------------------|----------------------|
| Selection/ranking | Ranked options table with scores, trade-offs, top recommendation |
| Strategy/planning | Phased roadmap with dependencies, risks, milestones, decision points |
| Risk assessment | Scenario matrix (base/bull/bear) with probabilities, mitigations |
| Deep understanding | Framework + mental models + worked examples + methodology |
| Validation/verification | Evidence table (for/against) with confidence, red flags, verdict |
| Optimization | Pareto frontier visualization, constraint sensitivity, optimal set |

**Default (if ambiguous):** Provide both the calibrated analytical answer AND a brief "How to use this" guide.

```markdown
# Research: <Original Question>

## Question
<User's original question>

## Calibrated Intent
<Original phrasing → Analytical reframe → Decision context inferred>

## Sub-questions
1. <Sub-question 1>
2. <Sub-question 2>
...

## Conclusions

### Executive Summary
<2–3 paragraph high-level answer with key findings, bottom-line up front>

### Detailed Findings (format adapts to decision context)

#### <Sub-question 1>
<Answer with inline citations like [¹][²]>

#### <Sub-question 2>
<Answer with inline citations>

...

## Conflicts
| Sub-question | Source A | Source B | Resolution | Rationale |
|--------------|----------|----------|------------|-----------|
| ... | ... | ... | ... | ... |

## Open Questions
1. <Question that emerged — gap, contradiction, or new angle>
2. <Question that emerged>
3. <Question that emerged>
4. <Question that emerged>
5. <Question that emerged>

## Sources
[¹] <Full citation with URL/DOI/path> — <Credibility tier> — <Relevance> — <Date>
[²] <Full citation with URL/DOI/path> — <Credibility tier> — <Relevance> — <Date>
...

## Loop log
- Loop 1: <what was searched, what gaps found>
- Loop 2: <what was searched, what gaps found>
- Loop 3: <what was searched, what gaps found> (if applicable)

## Convergence
- Coverage: ✅/❌
- Coherence: ✅/❌
- Citation density: ✅/❌
- Primary source ratio: ✅/❌
- Recency score: ✅/❌
- Intent Satisfaction: ✅/❌ (≥80% or user confirmed)

## Metadata
- Depth profile: fast/standard/exhaustive/adaptive
- Loops run: N
- Sub-agents spawned: N
- Search APIs used: <list with any rate-limit hits>
- Total sources: N (Primary: N, Secondary: N, Tertiary: N)
```

## Source credibility tiers

| Tier | Examples | Weight |
|------|----------|--------|
| **Primary** | Official specs, RFCs, source code, peer-reviewed papers, first-party API docs, government data | 1.0 |
| **Secondary** | Reputable tech blogs (engineering blogs of major companies), well-known expert newsletters, curated awesome-lists | 0.7 |
| **Tertiary** | Stack Overflow, Reddit, generic tutorials, aggregator sites | 0.3 |

**Rule:** A claim supported only by tertiary sources is *unsourced* — flag it and loop.

## Search strategy

- **Official first** — always check the official source (docs, repo, spec) before secondary commentary
- **Version-aware** — include version numbers in queries; note version in citations
- **Date-aware** — prefer sources <2 years old for fast-moving fields; note publication date
- **Diverse query formulation** — use 3+ query variations per sub-question (technical terms, natural language, error messages, file names)
- **Free API portfolio** — rotate across free tiers: DuckDuckGo (HTML), Brave Search (1k/mo), arXiv, Semantic Scholar (100/day), Crossref, GitHub (30/min), Stack Exchange (300/day), Yahoo Finance, Alpha Vantage (25/day), Reddit public JSON, HN/Algolia
- **Login-wall bypass** — use public endpoints: `old.reddit.com/r/.../.json`, `quora.com/.../answer/...` (public answers), `rednote.com/...` (public posts), textise dot iitty for paywalled articles, Wayback Machine for archived versions
- **Rate-limit respect** — exponential backoff, request pooling, cache responses for 24h

## Failure modes & defenses

| Failure mode | Symptom | Defense |
|--------------|---------|---------|
| **Premature convergence** | Loop stops at 1 iteration with thin citations | Enforce minimum 2 loops for adaptive/standard/exhaustive; require ≥2 sources per sub-question |
| **Source monoculture** | All citations from one domain/type | Require ≥2 independent domains per sub-question; track domain diversity in convergence check |
| **Citation theater** | Citations exist but don't support the claim | Verify each citation trail on synthesis; drop unsupported claims |
| **Scope creep** | Sub-questions multiply beyond 7 | Hard cap at 7; merge or defer extras to "future work" |
| **Hallucinated consensus** | "Experts agree" without naming experts | Replace with "Source X states Y; Source Z states W" |
| **Login-wall blindness** | Missing community knowledge (Reddit, Quora, Rednote) | Use public JSON endpoints and archive views; flag when login-wall sources unavailable |
| **Stale citations** | Old sources cited for fast-moving topics | Recency score in convergence check; auto-flag citations >2 years for tech/finance |
| **Credibility inversion** | Tertiary source weighted over primary | Credibility-weighted conflict resolution: primary (1.0) > secondary (0.7) > tertiary (0.3); never cite tertiary-only as fact |
| **Literalism trap** (NEW) | Answers "guaranteed X" with "impossible" lecture | Intent calibration step (1.5); pragmatic reframe heuristics; no-lecture rule |
| **Decision context blindness** (NEW) | Produces technically correct but decision-useless output | Decision context inference in Step 1; output format tied to decision type |
| **Colloquial language mismatch** (NEW) | User says "safe", skill hears "risk-free" | Mapping table in 1.5; clarify if ambiguity remains |

## Pre-send check

Before delivering the final research file, verify:

1. Every load-bearing claim has a citation trail to a primary or secondary source
2. No tertiary-only claims remain unflagged
3. Conflicts table is complete (empty if no conflicts) with resolution rationale
4. Loop log shows genuine iteration, not performative looping
5. Convergence checks are honestly scored (coverage, coherence, citation density, primary source ratio, recency score)
6. File path follows `docs/research/<NNNN>-<topic-slug>.md` convention
7. Depth profile used is noted in the output (fast/standard/exhaustive/adaptive)
8. Search APIs used are listed with any rate-limit hits noted
9. Executive summary presents bottom-line conclusions up front
10. Open questions section has 3–5 genuine follow-up questions
11. Metadata section includes sub-agent count, loop count, source breakdown
12. **Calibrated Intent section documents original phrasing → analytical reframe → decision context**
13. **Intent Satisfaction Score ≥ 80% or user confirmed "this answers my question"**
14. **No-lecture rule: zero paragraphs explaining why user's phrasing was imprecise**
15. **Output format matches inferred decision context (ranked table, roadmap, scenario matrix, framework, evidence table, or Pareto frontier)**