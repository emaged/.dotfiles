# ~/.codex/AGENTS.md

## Core Principles

- Follow the user’s intent: if they ask to change, improve, refactor, or fix code, edits are permitted.
- Prefer small, incremental, reversible changes over large rewrites.
- Ask clarifying questions only when intent, scope, or target files are unclear.
- Explain reasoning for non-trivial changes or tradeoffs.
- Avoid unnecessary refactoring unless requested.
- Stop once enough information exists to answer or propose a change.

---

## File Inspection & Editing

- Reading and inspecting files is allowed to understand context or answer questions.
- If the user explicitly asks for changes to a file or snippet, you may edit it directly.
- If a request would affect **additional files**, **broader scope**, or **architecture**, ask first.
- Provide diffs or scoped code blocks for edits unless the user asks for full rewrites.
- Avoid full-file rewrites unless requested.
- Prefer symbol-level or scoped inspection over full-file reads.

---

## Dependencies & Environment

- Ask before adding new production dependencies.
- Dev-only dependencies may be suggested, but not added without approval.
- Respect the existing toolchain (Poetry, npm, pip, uv, etc.).
- Use minimal version constraints unless security requires otherwise.

---

## Security & Privacy

- Never request, store, or transmit credentials.
- Use environment variables or secure inputs for secrets.
- Never hardcode API keys, tokens, or passwords.

---

## Tooling

- Prefer existing project tools (linters, formatters).
- Ask before introducing new tools or automations.

---

## Network Access

- **Read-only access to public documentation is implicitly allowed** when needed
  to answer questions accurately (e.g. GitHub READMEs, plugin docs, official docs).
- Do **not** ask for permission to consult public documentation unless the source
  is private, authenticated, or non-obvious.
- Treat documentation lookup as read-only context gathering, not exploration
  or general web browsing.

---

## Documentation Lookup Policy

- If a question depends on the behavior, configuration, or semantics of a
  library, plugin, or tool, consult its authoritative public documentation.
- Prefer documentation sources in this order:
    1. Local files or vendored docs
    2. Public GitHub repositories (`README.md`, `docs/`)
    3. Official project websites
- Mention the source briefly if it affects correctness or confidence.
- Do not delay answers by asking permission to look up public docs.

---

## MCP Tools (Lightweight Defaults)

- MCP tools may be used when they clearly reduce uncertainty or effort.
- Prefer local context and provided code first; consult public documentation
  when local context is insufficient to answer accurately.
- Stop using MCP tools once enough information exists to proceed.
- Do not chain tools speculatively or “just in case”.

### Tool Bias (Not Strict)

- **Filesystem / GitHub** → code, READMEs, authoritative documentation
- **Fetch** → precise HTTP or API behavior
- **Context7** → supplemental library understanding or scaffolding
- **Perplexity** → broad or up-to-date external information (last resort)
- **Chrome DevTools** → client-side debugging only
- **Task Master** → use only when the user explicitly asks for a plan, roadmap,
  or multi-step breakdown

---

## Quality Guidelines

- Follow existing formatting and linting rules.
- Suggest tests when changes justify them.
- Keep changes readable, modular, and reversible.
- State assumptions clearly and offer alternatives when appropriate.
