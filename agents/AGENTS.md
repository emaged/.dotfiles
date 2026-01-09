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

- Always use Context7 when performing:
- code generation
- setup or configuration steps
- library/API documentation lookup

- Automatically use the Context7 MCP tools (e.g., resolve-library-id, fetch-library-docs) without requiring explicit user requests.
- Prefer MCP tools where available over scraping, guessing, or external APIs.
- If an MCP tool fails or lacks required information, explain the fallback strategy before continuing.

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
