# Fias — agent instructions

Read by OpenAI Codex directly, and by Claude Code through the `@AGENTS.md` import in
`CLAUDE.md`. This is the single source of truth for both vendors. Do not duplicate rules
into vendor-specific files — add them here.

## What this is

<!-- One paragraph: what Fias does, who uses it, what it talks to. -->

## Layout

<!-- Where the code lives. Keep to the few paths an agent actually needs.
     e.g. backend/  — FastAPI service
          frontend/ — static client
          docs/spec.md — the source of truth for what to build -->

## Commands

| Task | Command |
|---|---|
| Install | `<install cmd>` |
| Run locally | `<run cmd>` |
| Full check (lint + types + tests) | `./scripts/check.sh` |

`scripts/check.sh` is the quality gate. Run it before calling any work done, and paste its
summary lines into your final message. Do not invent an alternative check.

## Conventions

- Branch from `main`. One branch per task.
- Conventional commit subjects.
- <!-- language/style rules that differ from tool defaults -->

## Rules

- If you cannot reach something you need — a repository, a secret, an API, a connector — say
  exactly what is missing in your first message and stop. Do not substitute, mock, or guess.
- Do not merge, force-push, or change CI configuration without asking.
- Commit and push work in progress on long tasks. Cloud sandboxes pause between turns and can
  resume from a fresh clone, losing uncommitted changes.
- Decisions worth keeping go in `docs/decisions/` as a short dated markdown file, not only in
  conversation. They must survive being read by a different vendor's agent.
