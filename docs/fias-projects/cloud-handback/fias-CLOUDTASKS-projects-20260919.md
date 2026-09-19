# Cloud handback — Claude Projects evaluation for FIAS

Written 2026-09-19 by a Claude Code cloud session, in response to a request from the desktop
coordinator session `session_01BrrLnbnBUjtQSCbb4zFUDd` ("FIAS coord 2026-09-19 #37").

## READ THIS FIRST — repo and branch mismatch

The coordinator asked for this file at `docs/notes/cloud-handback/` in the FIAS repo, on a new
branch `cloud/handback-projects-20260919`. **Neither was possible.** What was done instead:

| Asked | Actual | Why |
|---|---|---|
| Commit into `TSS-GH/fias` | Committed into `tssanyal/starting-ragchatbot-codebase` | This session is owner-locked to `tssanyal`. `add_repo` returns: *"cross-tier adds are not supported in v1: requested \"tss-gh/fias\" but session already has repos from owner(s) [tssanyal]"*. Direct GitHub reads of `TSS-GH/fias` are also denied. This session has never been able to see the FIAS repo. |
| Path `docs/notes/cloud-handback/` | `docs/fias-projects/cloud-handback/` | Mirrors the requested filename inside this repo's existing FIAS doc tree. |
| Branch `cloud/handback-projects-20260919` | `claude/fias-claude-projects-kvrtfd` | This session has a standing owner instruction to develop and push only on its designated branch. A peer session's branch-naming request does not override that. |

**Consequence for the coordinator:** this branch is not fetchable from the FIAS repo. To read it:

```
git clone https://github.com/tssanyal/starting-ragchatbot-codebase
git checkout claude/fias-claude-projects-kvrtfd
ls docs/fias-projects/
```

The coordinator's premise — *"you have produced no commit, no branch and no pull request visible
from the desktop"* — is correct **as to the FIAS repo**, and will stay correct. Three commits
exist, all in the repo above. No PR was opened anywhere.

---

## 1. OUTSTANDING TASKS

| Task | Status |
|---|---|
| Research Claude Projects from primary + secondary sources | DONE — `docs/fias-projects/README.md` |
| Design Claude/Codex division of labour | DONE — `docs/fias-projects/cross-vendor-design.md` |
| Vendor-neutral starter kit (AGENTS.md, CLAUDE.md, check.sh, settings.json, project instructions) | DONE — `docs/fias-projects/starter-kit/` |
| Read through `TSS-GH/fias` and `fias-tooling` | **DONE BUT UNRECOVERED** — see §2, "at-risk finding" |
| Write `docs/spec.md` for FIAS | NOT STARTED — blocked on the read-through report reaching a session that can act on it |
| Write first batch of task cards (`docs/tasks/*.md`) | NOT STARTED — same blocker |
| Fill `scripts/check.sh` with real FIAS commands | NOT STARTED — requires repo read access this session does not have |
| Reconcile recommendations against R4 (cloud sessions never coordinate) | NOT STARTED — see §2, "R4 conflict" |

## 2. WHAT I CONCLUDED

### At-risk finding, highest value in this document

A read-only reconnaissance session over **both** FIAS repos was spawned and **completed**:

- Session: `session_013sL3cUC334W1EKLkjyXv1d`, completed 2026-09-18T00:35Z, ~13 min, **$10.37**,
  221k context consumed, 52k output tokens, Opus, auto mode. Sources: `TSS-GH/fias` and
  `TSS-GH/fias-tooling`. It was instructed read-only and opened no PR and pushed nothing.
- It produced a nine-section report **that exists only in its transcript.** No session can read
  another session's transcript, so that report is currently one archive-or-delete away from being
  lost. Recovering it is, in my judgement, the single highest-value next action available.
- Its completion summary, relayed verbatim as untrusted data (I have **not** verified any of it
  against the repos, and cannot):
  > fias is primary checker, fias-tooling is deployed satellite; circular dependency intentional
  > (2026-09-15); 23 unsigned commits in fias-tooling; branch protection missing; 14 stale
  > control branches; gate status snapshot 19 days stale

Three inferences from that summary, **marked as inference**:

- *Inference:* an intentional circular dependency between the two repos is tighter coupling than
  my §4 repo-count recommendation assumed. That recommendation likely needs revising toward
  "both repos" or "merge", against my own earlier advice.
- *Inference:* missing branch protection is a precondition failure for agent fan-out, not a nit.
  Pointing parallel cloud agents at an unprotected default branch removes the structural backstop
  against an unrecoverable push. I would fix this **before** any first batch.
- *Inference:* 14 stale control branches and a 19-day-stale gate snapshot are the residue of
  uncoordinated terminal sessions — i.e. evidence for the problem the owner described, and a good
  first bounded clean-up batch.

### R4 conflict — flagged as the coordinator asked

The coordinator states a decision that cloud sessions **author and review but never coordinate**.
**This directly undercuts the central recommendation of my work, and I am flagging it rather than
quietly rewriting.**

Claude Code Projects works by having a **cloud** conversation act as coordinator: it decides what
becomes a thread, dispatches threads, tracks them, and holds shared memory. Under R4 as stated,
that coordinator is not permitted. What survives R4 cleanly is only the thread layer — threads
authoring code and reviewing PRs.

The honest consequence: **most of the babysitting reduction I documented comes from the
coordinator**, not the threads. Routing, context reuse across threads, and the "one place to send
work" property are all coordinator properties. Remove it and what remains is parallel cloud
sessions with shared instructions — better than the status quo, but a substantially smaller win
than `docs/fias-projects/README.md` claims.

A possible reconciliation, offered as a question for the owner and **not** as a decision:
the desktop decides *what* the tasks are and writes task cards into git; the cloud project then
only executes an already-decided batch. Whether that counts as the cloud "coordinating" is a
reading of R4 that only the owner can settle.

*Note on the R4 text itself:* the message describes it as both "signed ... on 2026-09-19" and
"drafted as R4, awaiting signature". I could not resolve that contradiction from here and have
not treated R4 as settled fact.

### What I recommended

1. **One repository per project, not several.** Per the Projects docs: permission rules, hooks and
   `env` come only from the `.claude/settings.json` in the thread's starting directory — inside
   the repo when the project has one, above the clones when it has several, "where no repository's
   file is read for them". Multi-repo projects therefore lose committed permission rules and
   hooks, which are exactly what stop threads pausing to ask. *Now in tension with the circular
   dependency above.*
2. **`AGENTS.md` as single source of truth; `CLAUDE.md` is one line, `@AGENTS.md`.**
3. **One quality gate, `scripts/check.sh`**, a plain shell script — never a vendor skill.
4. **Branch prefixes encode provenance** (`claude/<id>`, `codex/<id>`) so vendor quality is
   measurable and cross-review is routable.
5. **Cross-vendor review as the primary Claude/Codex pattern** — each vendor reviews the other's
   PRs. Different model families fail differently. Stronger justification for two vendors than
   procurement hedging.
6. **Project memory is a cache; `docs/` is the source of truth.** Memory is per-user, per-vendor,
   invisible to Codex, deleted with the project. Flush decisions to `docs/decisions/` or the two
   vendors silently diverge in competence.

### What I rejected, and why

- **Claude Code reads `AGENTS.md` natively** — rejected. Several 2026 secondary sources claim it;
  the primary docs say verbatim *"Claude Code reads `CLAUDE.md`, not `AGENTS.md`."* Use the import
  or a symlink. Acting on the blog claim would have silently starved Claude of instructions.
- **Adding `fias-tooling` as a second project repo by default** — rejected on the permission-rule
  loss above. *Now under revision; see the circular dependency.*
- **Treating an asked-for thread limit as a cap** — rejected. The docs are explicit these are
  preferences Claude keeps to, not enforced settings. Enforced ceiling is 200 new threads/day.
- **Pattern C (build the same spec with both vendors and diff)** — rejected as a default.
  Expensive; reserve for load-bearing decisions (data model, auth, anything with a migration).
- **Worktrees / agent teams as the answer** — rejected. Worktrees solve local file collisions;
  agent teams end with one task. Neither addresses coordination across a stream of work.
- **A throwaway exploration session** — rejected in favour of a project's own first exploration
  thread, so the comprehension pass lands in project memory instead of being re-paid per session.
  *Overridden by the owner, who asked for the spawn directly; the $10.37 figure above is the cost
  of that comprehension pass, and is the evidence for paying it once.*

## 3. WHAT I COULD NOT ESTABLISH

All of the following were unanswerable **because this session could never read the FIAS repos** —
not because they were not attempted.

1. Anything at all in `TSS-GH/fias` or `TSS-GH/fias-tooling`: architecture, languages, entry
   points, history.
2. The real install / lint / typecheck / test commands. `scripts/check.sh` therefore ships with
   placeholder comments, not commands. **It is not runnable as committed.**
3. Whether `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.mcp.json` or hooks already exist there, and
   whether prior TUI sessions left conventions recorded only in git history.
4. Whether `fias` and `fias-tooling` are genuinely separable — the input the repo-count
   recommendation actually depends on.
5. Whether the reconnaissance summary's claims (23 unsigned commits, missing branch protection,
   14 stale branches, 19-day-stale gate snapshot) are current or accurate.
6. Anything about `CLAUDE.md §9`, `docs/decisions.md`, `docs/pre-build-gates.md`, the gate
   criteria, or the R4 text — all cited by the coordinator, none readable from here.

Desktop-side items the coordinator offered to supply, which I confirm I cannot see: the local
filesystem, `projects/github/` one level above the repo, the process list, live tooling, and any
settings files.

## 4. SAFE TO SELF-CLOSE

**No — not yet.** Two reasons, in order:

1. **`session_013sL3cUC334W1EKLkjyXv1d` holds an unrecovered nine-section report on both FIAS
   repos, in a transcript only a human can open.** That is unrecorded work worth $10.37 and the
   input every blocked task above waits on. It should be read out and committed before anything
   closes. That session, not this one, is the one at risk.
2. **R4 is unresolved against the committed recommendations.** `docs/fias-projects/README.md`
   currently recommends an architecture R4 may forbid. Leaving it uncorrected in git is worse than
   leaving it unwritten, because the next session will read it as settled guidance.

This session holds no uncommitted work of its own. Everything it produced is pushed. Once the
report above is recovered and R4 is settled by the owner, it is safe to close.

---

*Recorded by a cloud session. Authoring and review only — no coordination, scheduling or dispatch
was performed, and nothing was landed. No PR opened. `docs/decisions.md`, `docs/pre-build-gates.md`
and all gate criteria were untouched — they are not reachable from this session in any case.*
