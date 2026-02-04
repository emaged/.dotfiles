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

---

## MCP Tools

### General MCP Principles

- Prefer MCP tools when they provide clear advantages over reasoning directly from provided context.
- If an MCP call fails, explain the fallback strategy before proceeding.
- Use small, focused MCP calls rather than large or speculative ones.
- Respect user privacy — do not store or log MCP request data.
- Stop using MCP tools once sufficient information exists to propose a change.
- Do not chain MCP tools unless each step materially reduces uncertainty.

## MCP Tool Precedence (Very Important)

When multiple tools could apply, prefer them in this order and do not skip
higher-priority tools without a clear reason:

1. **Serena**
    - Semantic codebase understanding
    - Symbol navigation, relationships, minimal-scope analysis

2. **Filesystem / GitHub**
    - Authoritative source of local and remote code
    - READMEs, issues, examples, and exact file contents

3. **Context7**
    - External libraries and APIs
    - Code generation, scaffolding, and structured library understanding

4. **Task Master**
    - Explicit task planning, decomposition, and multi-step workflows

5. **Fetch**
    - Precise HTTP(S) requests
    - API inspection, schemas, and response validation

6. **Perplexity**
    - Broad or up-to-date external information
    - Use only when other MCP tools are insufficient

7. **Chrome DevTools**
    - Web inspection, DOM/CSS/network debugging

---

## Neovim Plugin Documentation

When a question involves **Neovim plugins** (configuration, behavior, options, or comparisons):

- Prefer authoritative plugin documentation over assumptions.
- Automatically:
    1. Fetch the plugin’s `README.md` via **GitHub MCP**.
    2. If GitHub lookup fails, fall back to **Fetch** (raw README URL).
    3. Use **Context7** only to supplement or structure understanding when relevant.
- Prefer README content over prior knowledge or intuition.
- Mention which MCP source was used (GitHub, Fetch, or Context7) if it affects reliability.

For comparisons, configuration guidance, troubleshooting, or behavioral questions:

- Consult plugin documentation (preferably via GitHub MCP) before answering.

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
- Do not read entire files via Filesystem when Serena symbol inspection is sufficient.

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

- Broad, external web research when other MCP tools are insufficient
- High-level landscape overviews

**Rules:**

- Use only when information cannot be obtained via GitHub, Fetch, or local context.
- Do not use for library APIs or project-specific documentation when authoritative sources exist.
- Clearly distinguish speculation from sourced facts.

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
- Inspecting response bodies, headers, or schemas

**Rules:**

- Ask before hitting non-public or rate-limited APIs.
- Prefer Perplexity for general browsing; prefer Fetch for precise endpoint testing.

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
- Avoid full-file reads unless symbol-level or scoped inspection is insufficient.

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

### GitHub

**Primary functions:**

- Repo browsing
- Reading files, issues, and PRs
- Fetching commit history or metadata

**Rules:**

- Ask before interacting with private repositories.
- Prefer GitHub for remote files that differ from the local filesystem state.
- Never create issues or PRs unless explicitly requested.
- Treat the local filesystem as authoritative over remote sources unless explicitly stated otherwise.

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
