# Fias: Claude threads and Codex cloud as complements

Companion to `README.md`. That note covers how Projects removes supervision overhead.
This one covers the division of labour between the two vendors, and the contract that lets a
task move between them.

Repos in scope: `TSS-GH/fias`, `TSS-GH/fias-tooling`.

> **Status.** Written without read access to either repo (this session was owner-locked to a
> different GitHub owner). The division of labour and the handoff contract below are
> structural and hold regardless of what is in the repos. The task inventory in §5 is the part
> that needs a read-through before it is real.

---

## 1. What each vendor is actually better at

Not marketing positioning — the operational differences that change how you should route work.

| | Claude Code Projects | Codex cloud |
|---|---|---|
| Unit of work | Thread in a coordinated conversation | Independent task in a fresh container |
| Carries context between tasks | Yes — project memory + instructions | No — "the next task starts from a fresh container" |
| Routing | Coordinator decides and tracks | You queue each task |
| After the PR opens | Watches it, fixes CI, answers review comments | Task run ends; the diff is the artifact |
| Instruction file | `CLAUDE.md` (import `AGENTS.md`) | `AGENTS.md` natively |
| Natural strength | Work where *why* matters and context accumulates | Bulk, bounded, spec-complete work |

The asymmetry that matters: **Claude accumulates, Codex parallelises.** Claude's project memory
means thread 12 knows what thread 3 decided. Codex's fresh container means task 12 knows only
what is written in the repo. That is a weakness for architecture and a strength for fan-out —
no context contamination between tasks, and no ceiling on how many you queue.

Route accordingly:

- **Claude threads** — anything needing accumulated context: architecture changes, refactors
  spanning modules, work where the spec is still moving, and anything whose PR will need
  several rounds of CI and review (the auto-fix loop is the differentiator).
- **Codex cloud tasks** — anything fully described by a task card and verified by
  `scripts/check.sh`: mechanical migrations, test backfill, config sweeps, porting one change
  across many modules, boilerplate.

## 2. The three symbiotic patterns

Ranked by value for effort.

### Pattern A — Cross-vendor review (highest value, lowest cost)

Have each vendor review the other's PRs. Claude threads review `codex/*` branches; a Codex task
reviews `claude/*` branches. Different model families fail differently, so one catches what the
other's blind spot produced. This is the strongest practical argument for running two vendors —
stronger than procurement hedging, which is the reason usually given.

Cheap to wire: a Claude **routine** with a GitHub trigger on `pull_request.opened` filtered to
head branch `codex/*`, and the mirror on the Codex side.

### Pattern B — Decompose centrally, fan out widely

The Claude project coordinator reads `docs/spec.md` and writes **task cards** into
`docs/tasks/*.md` — in the repo, vendor-neutral, one file per task. Then:

- Context-heavy cards → Claude threads (the coordinator starts them itself).
- Bounded cards → queue as Codex cloud tasks, many at once.

The coordinator is doing what it is best at (holding the whole picture and decomposing) and
Codex is doing what it is best at (volume). Neither is asked to do the other's job.

### Pattern C — Second opinion on load-bearing decisions

Give the same `docs/spec.md` section to a Claude thread and a Codex task. Diff the two PRs.
Keep the better one, or the union. Expensive — only worth it where being wrong is costly:
data model, auth, anything with a migration behind it.

## 3. The handoff contract

A task can move between vendors only if all five hold. These are the invariants; everything
else is negotiable.

1. **`AGENTS.md` is the source of truth.** `CLAUDE.md` is one line: `@AGENTS.md`. Claude Code
   does not read `AGENTS.md` natively — see `README.md` §4.
2. **A task is a file**, `docs/tasks/<id>.md`, with: goal, acceptance criteria, files likely
   touched, verification command. If it cannot be written as a card, it is not ready to hand to
   either vendor.
3. **One gate: `scripts/check.sh`.** Both vendors run it; CI runs it. No vendor-specific
   definition of "done".
4. **Branch prefix encodes provenance**: `claude/<task-id>`, `codex/<task-id>`. You can see at
   a glance in GitHub which vendor produced what, which makes Pattern A routable and makes
   quality differences measurable over time.
5. **Decisions land in `docs/decisions/`**, dated, in the repo.

### The rule that keeps Codex viable

**Project memory is a cache. `docs/` is the source of truth.**

Claude's project memory is per-user, per-vendor, invisible to Codex, and deleted with the
project. Anything Codex needs to know that lives only in memory is knowledge Codex does not
have. So periodically — end of a work batch is a natural point — tell the coordinator:

> "Write anything you've learned about Fias that isn't already in `docs/` into
> `docs/decisions/`, dated, one file per decision."

Skip this and the two vendors silently diverge in competence over weeks, which is exactly the
lock-in you said you wanted to avoid.

## 4. `fias-tooling`: the repo-count decision

This interacts with the single-repo finding in `README.md` §3, and it is the one structural
choice to get right before creating the project.

> "Permission rules, hooks, and `env` come only from the `.claude/settings.json` in the
> directory the thread starts in: inside the repository when the project has one, and above the
> clones when it has several, where no repository's file is read for them."

So adding `fias-tooling` as a second project repository costs you committed permission rules and
hooks in **both** repos. Those are what keep threads from stopping to ask. Three options:

| Option | When it fits | Cost |
|---|---|---|
| **Project = `fias` only**; threads add `fias-tooling` per task | Tooling changes are occasional | A thread that needs tooling clones it mid-task, so tooling's `CLAUDE.md` and skills are not loaded at thread start |
| **Project = both repos** | Most tasks genuinely span both | Lose permission rules, hooks, `env` from both `.claude/settings.json` — more approval prompts, more babysitting |
| **Merge into a monorepo** | Tooling exists only to serve `fias` | One-time migration; afterwards single-repo semantics hold and everything works |

Recommendation without having read the repos: **start with `fias` only**, name `fias-tooling`
in project instructions so the coordinator knows where tooling lives, and let threads pull it
in per task. Revisit after a week — if most threads are adding it anyway, that is the signal to
merge rather than to add it as a second project repo.

Codex is unaffected by this: its tasks clone what you point them at, per task.

## 5. What needs a read-through before this is actionable

Deliberately not guessed at:

- Whether `fias` and `fias-tooling` are genuinely separable, or tooling only serves fias.
- What `scripts/check.sh` should actually run — the real lint, type, and test commands.
- Whether `AGENTS.md` already exists in either repo, and whether prior TUI sessions left
  conventions in `CLAUDE.md` that need merging into it.
- The backlog: what is half-finished across weeks of TUI work, and which pieces are
  bounded enough to hand straight to Codex.

The cheapest way to get all four: create the project with `fias` attached. On a first project
Claude "start[s] one thread that explores the repository without changing anything and proposes
next steps" — the read-through happens inside the tool being set up, with the instructions
already in place, rather than as a throwaway session.

## 6. The surfaces you actually watch afterwards

The point of all of this.

| Before | After |
|---|---|
| N terminals, each holding context only you can carry between them | One Claude conversation — routing and memory |
| | Codex task queue — bulk execution |
| | GitHub PR list — the single review surface |

Only the third needs real attention. The first two are inboxes you clear.
