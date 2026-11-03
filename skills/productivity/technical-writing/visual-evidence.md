# Visual evidence

Choose media by the question it answers. Omit a visual that adds no information beyond the adjacent text.

## Diagrams

Use Mermaid when the destination supports it. Otherwise use a supported diagram format and retain editable source where the project expects it.

Trace every node, relationship, and transition to the investigated system. Show only the detail needed for the reader's question. Label arrows and distinguish proposed behavior from current behavior.

Validate syntax and inspect the rendered result with available tooling. If rendering is unavailable, disclose that it was not checked. Supply a short text explanation so the diagram is not the only source of essential information.

## Screenshots and recordings

For web-app documentation, use browser automation to capture the actual task in an authorized environment. Discover available tools and load the applicable browser skill before interacting with the app.

- Use the app's supported authentication or test-session setup. Do not bypass access controls or change shared data to stage a screenshot.
- Use realistic, non-sensitive test data. Check the target version, role, viewport, and UI state against the instructions.
- Capture the useful state, not the whole desktop. For recordings, show the shortest complete interaction with a visible outcome.
- Inspect each capture for readability and accidental disclosure, including names, tokens, notifications, and unrelated browser content. Crop, redact, or recapture before saving it as a deliverable.
- Store assets in the destination's normal asset location with stable relative links. Add descriptive alt text and a caption explaining what readers should notice. Give recordings a text summary of the actions and result.
- State a version or capture context when readers could otherwise mistake a version-specific UI for universal behavior.

Never pass off a mockup, generated image, or unrelated capture as the real application. Label illustrative material explicitly.

## When capture is blocked

If the app, permissions, browser tooling, or recording support is unavailable, explain the specific blocker. Request the exact missing screenshot or clip from the user, including the screen, role, state, and detail it must show.

Continue with accurate text or a supported diagram where it answers the same question. Do not substitute a screenshot for an interaction that needs motion to be understood. Leave no broken asset links, and identify any unavailable media at delivery.
