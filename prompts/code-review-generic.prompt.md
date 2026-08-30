---
name: "pw-code-review-generic"
description: "Review code for correctness, security, compatibility, tests, performance, architecture, and documentation."
argument-hint: "[selection, files, branch, commit, or pull request]"
agent: "pakwai-generic"
---

# Review code

Review the supplied code or changes. If no target is supplied, review the current uncommitted changes. Respond in English.

Inspect enough surrounding code, tests, configuration, and documentation to verify each finding. Follow the repository's established patterns and instructions. Infer its language, framework, architecture, build tool, test framework, and code style instead of assuming generic defaults.

Prioritize verified defects and regressions. Do not report speculative problems as findings. Group related issues, distinguish required fixes from optional improvements, and keep the review practical.

## Priorities

### 🔴 CRITICAL (Block merge)

- **Security**: Vulnerabilities, exposed secrets or personal data, and authentication or authorization failures.
- **Correctness**: Logic errors, data corruption risks, and race conditions.
- **Breaking Changes**: API or contract changes without versioning or migration support.
- **Data Loss**: Risk of data loss or corruption.

### 🟡 IMPORTANT (Requires discussion)

- **Code Quality**: Severe violations of established design principles, excessive duplication, or unclear ownership.
- **Test Coverage**: Missing tests for critical paths or new behavior.
- **Performance**: Clear defects such as N+1 queries, unbounded work, or memory leaks.
- **Architecture**: Significant departures from the repository's architecture or conventions.

### 🟢 SUGGESTION (Non-blocking improvements)

- **Readability**: Unclear names, difficult control flow, or logic that can be simplified.
- **Optimization**: Performance improvements that do not affect correctness.
- **Best Practices**: Minor convention or best-practice gaps.
- **Documentation**: Missing or incomplete documentation.

## Review checks

### Correctness and code quality

- Check behavior against callers, contracts, tests, and documented requirements.
- Look for invalid assumptions, boundary errors, null or empty input failures, partial updates, concurrency bugs, and incompatible changes.
- Require descriptive names and focused responsibilities. Flag excessive duplication, functions that are difficult to follow, nesting deeper than three or four levels, and unexplained magic values.
- Treat 20 to 30 lines as a readability signal for a function, not a hard limit.
- Prefer self-explanatory code. Require comments only for non-obvious decisions or constraints.
- Check that inputs fail early with useful messages, errors are handled at the right layer, exceptions use specific types, and failures are neither swallowed nor silently ignored.

### Security

- Check source, configuration, and logs for passwords, API keys, tokens, personal data, and other secrets.
- Verify validation and sanitization at each user-controlled input boundary.
- Require parameterized database queries. Flag query construction that concatenates untrusted input.
- Verify authentication before protected access and authorization for the specific resource and action.
- Require established cryptography libraries and safe algorithms. Flag custom cryptography.
- Check changed dependencies for known vulnerabilities and unsafe or unsupported versions.

### Tests

- Require coverage for new behavior, critical paths, boundary values, null values, empty collections, failures, and error handling.
- Check that test names state the expected behavior and that assertions verify specific results rather than general truthiness.
- Prefer a clear Arrange-Act-Assert or Given-When-Then structure where it helps readability.
- Verify tests are deterministic, independent, and isolated from external state.
- Mock external dependencies, not domain logic.
- Flag disabled tests, tests that always pass, and critical scenarios without coverage.

### Performance and resources

- Look for N+1 database access, missing indexes implied by new query patterns, unsuitable algorithmic complexity, repeated expensive work, and avoidable eager loading.
- Check whether expensive repeated operations need caching and whether large result sets need pagination or streaming.
- Verify cleanup of files, streams, connections, subscriptions, timers, and other resources on success and failure.
- Flag memory leaks and unbounded memory, CPU, network, queue, or database work.

### Architecture and project rules

- Verify separation of concerns, cohesive modules, clear ownership, and independently testable components.
- Check dependency direction, interface size, coupling, and consistency with established repository patterns.
- Apply repository-specific framework rules, business constraints, data-consent requirements, build and deployment checks, CI/CD conventions, and commit or branch conventions when evidence for them exists.
- Check database migrations for compatibility, safe rollout, and reversibility where the project requires it.

### Documentation

- Verify public APIs document their purpose, parameters, return values, errors, and compatibility constraints.
- Require short explanations for non-obvious logic.
- Check that setup, usage, README, deployment, and migration documentation matches changed behavior.
- Require explicit documentation for breaking changes and examples for complex public features.

## Output

List findings first, ordered by priority and then by impact. Group them under the matching priority heading above and start each finding with a bold category label. Omit empty priority groups.

Use this format for each finding:

```markdown
### 🔴 CRITICAL (Block merge)

- **Security**: Concise title

	`path/to/file.ext:line` identifies the smallest relevant location.

	Explain the verified issue and the conditions that trigger it.

	**Why it matters:** State the concrete user, security, data, compatibility, performance, or maintenance impact.

	**Suggested fix:** Give a specific correction. Include a small code example when it makes the fix clearer.

	**Reference:** Link to relevant project or external documentation only when it adds useful evidence.
```

Use the corresponding yellow or green heading for Important and Suggestion findings.

Do not create separate findings for the same root cause. Do not bury blocking findings under style comments. After the findings, include open questions or assumptions, then a brief change summary and any good practices worth preserving.

If there are no findings, say so directly. State which checks or tests were not run and any remaining coverage gaps or risks.