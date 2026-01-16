# ~/.codex/AGENTS.md

## Working agreements

- Prefer small, incremental changes over large rewrites.
- Ask clarifying questions when intent is uncertain.
- Explain reasoning for non-trivial suggestions.
- Avoid unnecessary refactoring unless explicitly requested.

## File edits

- **Don't edit existing files without permission.**
- Provide diffs or scoped code blocks when suggesting changes.
- Wait for confirmation before applying edits.
- Ask before creating new files unless explicitly requested.

## Dependencies & environment

- **Ask for confirmation before adding new production dependencies.**
- Suggest dev-only dependencies sparingly.
- Respect the existing toolchain (Poetry, npm, pip, uv, etc.).
- Use minimal version constraints unless security requires otherwise.

## Security & secrets

- Never request or store sensitive credentials.
- Use environment variables or secure inputs for secrets.
- Never hardcode API keys, tokens, or passwords.

## Tooling

- Use configured project tools when possible (linters, formatters, MCP servers).
- Ask before introducing new tools or automations.

## MCP Tools

### General MCP Principles

- Prefer MCP tools over external APIs, scraping, or assumptions.
- If an MCP call fails, explain the fallback strategy before proceeding.
- Use small, focused MCP calls rather than large or speculative ones.
- Respect user privacy — do not store or log MCP request data.

---

## Server-Specific Usage Rules

### Serena

**Primary functions:**

- Semantic codebase understanding
- Symbol-level navigation (definitions, references, relationships)
- Precise, structured code edits
- Reducing unnecessary full-file reads

**Rules:**

- When working in a codebase, activate the current directory as a Serena project before inspecting or modifying code.
- Prefer Serena’s semantic tools over raw filesystem reads when locating symbols, understanding relationships, or planning edits.
- Use Serena to identify the minimal scope of changes before proposing file edits.
- Do not perform blind or large-scale refactors without first consulting Serena’s project index.
- Fall back to Filesystem tools only when Serena is unavailable or insufficient, and explain why.

### Context7

**Primary functions:**

- Code generation and refactoring
- Setup, configuration, and scaffolding
- Library/API understanding using structured semantic lookup
- Supplementing or clarifying information from external documentation

**Rules:**

- Prefer GitHub (or Fetch) for authoritative project documentation, READMEs, examples, and real-world usage details.
- Use Context7 primarily for generating or reasoning about code, understanding libraries, and filling in gaps that external documentation does not cover.
- When both GitHub documentation and Context7 insights are relevant, prioritize GitHub for correctness and use Context7 to enhance or structure the answer.
- Automatically use Context7 MCP tools (e.g., resolve-library-id, fetch-library-docs) when they improve clarity or provide additional semantic information.
- If Context7 lacks required data or produces outdated information, explain the fallback strategy before proceeding.

---

### Perplexity

**Primary functions:**

- Web search
- High-level research summaries
- Broad information gathering

**Rules:**

- Use only when information must be external or up-to-date.
- Do not use when local MCP servers (Context7, filesystem, GitHub) are sufficient.
- Summarize findings cleanly and cite sources when relevant.

---

### Chrome DevTools

**Primary functions:**

- Inspect web pages
- Extract DOM, CSS, and network details
- Debug client-side behavior

**Rules:**

- Ask before visiting URLs or interacting with pages.
- Never submit credentials or access authenticated pages without explicit permission.
- Use for debugging reproducible front-end issues.

---

### Fetch

**Primary functions:**

- Raw HTTP(S) requests
- API endpoint testing
- Downloading machine-readable data

**Rules:**

- Ask before hitting non-public or rate-limited APIs.
- Prefer Perplexity for general browsing; prefer Fetch for precise endpoint testing.

---

### Playwright

**Primary functions:**

- Browser automation
- End-to-end testing
- Screenshot generation

**Rules:**

- Ask before performing state-changing operations (clicks, forms, navigation).
- Use Chrome DevTools for inspection; Playwright for automation.

---

### Filesystem

**Primary functions:**

- Reading and writing project files
- Directory inspection
- File creation/modification

**Rules:**

- Follow the File Edits rules in this document.
- Never modify files without explicit approval.
- Always provide diffs before applying changes.

---

### SequentialThinking

**Primary functions:**

- Multi-step reasoning
- Complex workflows
- Breaking tasks into structured steps

**Rules:**

- Use automatically for difficult or multi-stage reasoning tasks.
- Keep steps concise and directly relevant.
- Provide a clear summary at the end.

---

### Task Master

**Primary functions:**

- Task planning
- Project decomposition
- Managing multi-step coding or documentation workflows

**Rules:**

- Use when the user asks for plans, roadmaps, or multi-step task structures.
- Keep tasks small, scoped, and logically ordered.

---

### Time

**Primary functions:**

- Time/date retrieval
- Timezone conversion
- Scheduling logic

**Rules:**

- Use automatically for time-sensitive calculations.
- Ask before doing anything that could imply scheduling.

---

### GitHub

**Primary functions:**

- Repo browsing
- Reading files, issues, and PRs
- Fetching commit history or metadata

**Rules:**

- Ask before interacting with private repositories.
- Prefer GitHub for remote files that differ from the local filesystem state.
- Never create issues or PRs unless explicitly requested.

## Testing

- When backend changes require it, suggest updated or new tests.
- Follow existing test structure and conventions.

## Code style

- Follow project formatting and linting rules.
- Keep code readable, modular, and consistent.
- Avoid hidden side effects and magic values.

## Documentation

- Update documentation only when tied to user-requested changes.
- Provide docstring suggestions for new functions or modules.

## Performance

- Recommend performance improvements only when justified.
- Avoid premature optimization.

## Collaboration

- Keep changes reversible when possible.
- State assumptions clearly.
- Offer alternatives when appropriate.
