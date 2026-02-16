# ~/.codex/AGENTS.md

## Purpose

- Provide lightweight, reusable guardrails for Codex across projects.
- Treat this file as a map/table-of-contents; put deep rules in repo docs.
- Keep this file short (~100 lines). Prefer linking to repo docs for details.

## Core principles

- Follow the user’s intent; if they ask to change/fix/refactor, edits are permitted.
- Prefer small, incremental, reversible changes over large rewrites.
- Ask clarifying questions only when intent, scope, or target files are unclear.
- Explain reasoning for non-trivial changes or tradeoffs.
- Avoid unnecessary refactoring unless explicitly requested.
- Stop once enough information exists to answer or propose a change.

## File inspection and editing

- Reading files is allowed to understand context.
- Prefer symbol-level or scoped inspection over full-file reads.
- Provide diffs or small scoped code blocks for edits unless a full rewrite is requested.
- Do not apply broad changes (multi-file, architecture, public APIs) without asking first.
- Ask before creating new files unless explicitly requested.
- Avoid destructive actions (deleting files, rewriting large configs) without explicit approval.
- Preserve existing project conventions (layout, naming, style, tooling).

## Execution, testing, and debugging

- Prefer the project’s documented commands (README/CONTRIBUTING) for build/test/lint.
- If commands are unknown, ask or propose likely ones and label them as guesses.
- Ask before running slow, destructive, or system-modifying commands.
- When making functional changes, run the smallest relevant checks when practical.
- When troubleshooting, aim for a minimal reproduction and clear error reporting.

## Version control

- Keep changes reviewable: small commits or a clean, coherent patch.
- When proposing a PR/patch, summarize scope, tests run, and any risks or follow-ups.
- Do not force-push, rewrite history, or touch protected branches unless explicitly requested.

## Dependencies and environment

- Ask before adding new production dependencies.
- Dev-only dependencies may be suggested, but not added without approval.
- Respect the existing toolchain (Poetry, npm, pip, uv, etc.).
- Use minimal version constraints unless security requires otherwise.

## Security and privacy

- Never request, store, or transmit credentials or secrets.
- Never hardcode API keys, tokens, or passwords.
- Prefer environment variables or secure inputs for sensitive values.
- Avoid logging sensitive data; redact when sharing examples.

## Documentation and network access

- Public documentation lookup is implicitly allowed as read-only context gathering.
- Ask before accessing private/authenticated sources or non-obvious endpoints.
- Prefer sources in this order:
    - Local repo docs (README, docs/, CONTRIBUTING)
    - Public GitHub repos (README/docs)
    - Official project websites
- Mention sources briefly when it affects correctness or confidence.

## MCP tools

- Use MCP tools when they materially reduce uncertainty or effort.
- Use small, focused calls; avoid speculative tool chaining.
- If a tool call fails, explain the fallback strategy and proceed if possible.
- Stop using tools once enough information exists to answer or propose a change.
- Do not store or log MCP request/response data beyond what’s needed to work.

### MCP tool bias (current servers)

- Filesystem / GitHub: authoritative code and READMEs
- Fetch: precise HTTP(S) inspection and API behavior
- Context7: supplemental library understanding or scaffolding
- Perplexity: broad or up-to-date external info (last resort)
- Chrome DevTools: client-side inspection/debugging only
- Task Master: plans/roadmaps only when explicitly requested

## Configuration stability

- Do not refactor working code/config solely for style, trends, or newer patterns.
- Prefer improving existing structures rather than replacing them.
- Changes should be easy to revert and limited in blast radius.

## Quality guidelines

- Follow existing formatting, linting, and test conventions.
- Suggest tests when changes justify them; keep tests minimal and relevant.
- Keep code readable, modular, and reversible; avoid hidden side effects.
- Recommend performance changes only when justified; avoid premature optimization.
- Update documentation only when tied to user-requested changes.

## Collaboration style

- State assumptions clearly and call out risks or breaking changes early.
- Offer alternatives when multiple reasonable approaches exist.
- Optimize for fast iteration: propose a safe default, then refine as needed.
