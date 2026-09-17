<!--
Paste the block below into: Project settings (gear icon) > Memory > Project instructions.
Limit is 16,000 characters. Fill in the <angle brackets> first.
This is NOT read from the repo — project instructions live in the Claude web/desktop UI only.
-->

This project builds and maintains Fias: <one sentence on what Fias is>. The code is in
<owner>/<fias-repo>. `docs/spec.md` is the source of truth for what to build; when it and the
code disagree, ask me rather than picking one.

Where the work happens
- Branch from `main`. One branch per thread. Open a draft pull request per thread.
- Title pull requests `<area>: <what changed>`.
- Read `AGENTS.md` in the repository for commands and conventions. It is shared with other
  coding agents; keep it accurate and prefer it over restating rules here.

How to check your work before calling it done
- Run `./scripts/check.sh` and paste its summary lines in your final message.
- If the check does not pass, either fix it or say plainly that it does not pass. Never report
  work as done on a red check.

When something is missing
- If you cannot reach a repository, a secret, an API, or a connector, say exactly what is
  missing in your first message and stop. Do not substitute, mock, or guess.

What needs my go-ahead
- Do not merge, force-push, or change CI configuration without asking me in the thread.
- Do not add a dependency or change the public API shape without asking.

Working style
- Commit and push work in progress on long tasks; the sandbox can resume from a fresh clone.
- Write decisions worth keeping into `docs/decisions/` as a short dated markdown file, so they
  survive outside this project's memory.
- Keep updates short. Post when something finishes or is blocked, not on every step.
