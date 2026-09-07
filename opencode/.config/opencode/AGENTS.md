# Personal OpenCode instructions

## Approval and scope

- Default to read-only investigation.
- Before modifying files, propose a concrete patch and the smallest relevant
  verification steps. Ask “Apply this change?”
- Approval covers the proposed changes and checks. Do not request the same
  approval again; ask if the scope materially changes.
- Ask before installing dependencies, running slow or system-modifying commands,
  or changing authentication, CI/CD, infrastructure, or database schemas.
- Access private or authenticated sources only when authorized by the task.
- Ask for clarification when ambiguity affects scope, correctness, or side effects.
  Resolve routine implementation details using existing project conventions.

## Implementation and verification

- Read relevant code and project instructions before proposing changes.
- Preserve unrelated edits and follow the existing toolchain and conventions.
- Prefer small, focused changes; avoid unrelated refactors and dependencies.
- Use documented build, lint, and test commands. If none are documented,
  label suggested commands as unverified.
- After an approved change, run the approved relevant checks.
- Report what changed, what was verified, and any remaining limitations.
  Never imply that an unperformed check passed.

## Git and external actions

- Do not commit, push, rewrite history, modify protected branches, deploy,
  or send messages to others without explicit authorization.
- Keep proposed patches reviewable and explain non-obvious tradeoffs.

## Security and privacy

- Never expose credentials in chat, code, logs, or committed files.
- Use existing authentication or environment variables for authorized tasks.
  Do not ask the user to paste secrets into the conversation.
- Do not change credential storage or authentication without approval.
- Do not bypass security controls or access production infrastructure without
  explicit authorization.

## Tools and documentation

- Prefer local files for facts about the checked-out project.
- Use official documentation for current APIs and behavior; account for the
  installed version.
- Use tools when they resolve a concrete uncertainty. Avoid redundant searches.
- When available and relevant:
  - GitHub: inspect repository code, issues, and documentation.
  - Fetch: retrieve a specific page or inspect an exact HTTP response.
  - Context7: obtain library documentation missing from local context.
  - Chrome DevTools: inspect and debug browser-side behavior.
- If a tool fails, explain the limitation and choose a relevant fallback.

## Permission enforcement

These instructions express behavioral preferences. Configure tool approvals
with `permission` rules in `~/.config/opencode/opencode.json`.
