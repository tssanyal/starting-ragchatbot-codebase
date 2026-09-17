# Starter kit

Copy the contents of this directory into the root of the Fias repository, fill in the
placeholders, and commit to the default branch before creating the Claude project.

| File | Goes to | Read by |
|---|---|---|
| `AGENTS.md` | repo root | Codex directly; Claude via the import in `CLAUDE.md` |
| `CLAUDE.md` | repo root | Claude Code only — one line, imports `AGENTS.md` |
| `scripts/check.sh` | repo root | every agent, every vendor — the quality gate |
| `.claude/settings.json` | repo root | Claude threads, **only in a single-repository project** |
| `PROJECT_INSTRUCTIONS.md` | *not* the repo | paste into Project settings → Memory |

On macOS/Linux you can replace `CLAUDE.md` with a symlink instead: `ln -s AGENTS.md CLAUDE.md`.
Use the `@AGENTS.md` import on Windows, where symlinks need Administrator or Developer Mode.

`.claude/settings.json` permission rules apply to threads **only when the project has one
repository**. With several repositories no repo's settings file is read for permissions, hooks,
or `env`. See `../README.md` §3.
