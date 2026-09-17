# Running Fias on Claude Code Projects without losing Codex

Research note + build recipe. Written 2026-09-17.

Goal: cut the time the owner spends babysitting Claude Code TUI sessions, while keeping
OpenAI Codex usable as a second vendor on the same repository.

> **Open assumption.** No `Fias` repository was reachable from this session and the name does
> not appear in this codebase, so this note describes the mechanism and a repo-shaped recipe
> rather than Fias-specific tasks. Substitute the real repo name where it says `<fias-repo>`.
> The two things that change once Fias is defined: which repositories go in the project, and
> the contents of `docs/spec.md`.

---

## 1. What Projects actually is

A Claude Code **project** is *one* long-running conversation in which Claude acts as
coordinator, plus **threads** it starts to do the work. Each thread is a full cloud session
with its own context window, its own branch, and usually its own pull request.

From the official docs:

> "A project is one ongoing conversation where Claude coordinates a stream of related work for
> you. You tell it what needs doing and it starts a thread for each task."

> "Without a project, running several sessions means doing the coordinating yourself: you decide
> what each one works on, repeat the same background at the start of each, and check back to see
> which finished or needs an answer."

That second sentence is the babysitting problem, named by the vendor. The parts:

| Part | What it does |
|---|---|
| **Project conversation** | Coordinator. Routes what you paste into new threads or existing ones. Sees what threads report, not every step. |
| **Threads** | Workers. One cloud session each, own branch, own PR, report back on finish. |
| **Project instructions** | Up to **16,000 characters** of standing brief injected into *every* new thread. |
| **Project memory** | `MEMORY.md` index + topic files Claude writes itself. Every thread reads the index at start. |
| **Overview pane** | Threads grouped by state: `Ready for review`, `Waiting on you`, `Working`, `Landing`, `Idle`, `Resolved`. Plus `Library`, `Pull requests`, `Routines` tabs. |
| **Cloud environment** | Network allowlist, env vars, API credentials, setup script. |

Availability, verbatim: *"Projects are in public beta on Pro and Max plans and rolling out
gradually... They aren't available on Team or Enterprise plans yet."* And: *"Projects are
available at claude.ai/code, in the desktop app, and in the Claude mobile app, **not in the
terminal CLI**."* So this is a move *off* the TUI for the coordinated work, not an upgrade to it.

---

## 2. Where babysitting comes from, and what removes it

This is the core of the answer. Each row is a real reason the owner sits and watches a TUI
session, matched to the Projects mechanism that removes it.

| Babysitting cause | Mechanism that removes it | Where you configure it |
|---|---|---|
| Permission prompts interrupt every few minutes | Threads run in **auto mode**; most tool calls run unprompted | Automatic. Tighten with `permissions` in `.claude/settings.json` |
| Laptop must stay open / session dies on sleep | Threads are cloud sessions and "keep going after you close the laptop" | Automatic |
| Re-pasting the same background into each new session | **Project instructions** + **project memory** reach every new thread | Project settings → Memory |
| Deciding what each session works on | Coordinator splits a pasted batch into threads itself | Project conversation |
| Polling "is it done yet?" across N terminals | **Overview** groups threads by state; dot on the button when one needs you; desktop notifications in the desktop app | Project header → Overview |
| CI goes red after a push, you fix it by hand | Threads watch their PR with **auto-fix on by default** — "whether or not auto-fix is on for your other cloud sessions". They push fixes when CI fails and address review comments | Automatic |
| Same correction given twice | Say "remember this" → goes to project memory → later threads start with it | Conversation |
| Recurring chores (nightly checks, dep bumps) | **Routines**, which appear on the project's Routines tab | Ask in conversation, or `claude.ai/code/routines` |

**The single biggest lever is the PR auto-fix loop.** A thread does not stop at "opened a PR."
It watches the PR, pushes fixes when CI fails, replies to review comments, and only then tells
you it is ready. The thread card even shows a button for the next step — `Resolve conflicts`,
`Fix CI`, `Address comments`, `Merge it` — so a stuck PR is one click, not a new session.

**The second biggest lever is a written brief.** The docs are blunt about the failure mode:

> "When several threads come back having assumed something wrong, worked around missing access,
> or stopped with 'blocked', the cause is usually the same gap in the project's setup rather than
> a problem with each task."

Which is why the instructions block in `starter-kit/PROJECT_INSTRUCTIONS.md` carries an explicit
*"if you can't reach it, say what's missing and stop — don't substitute, mock, or guess"* rule.
Without that line, threads guess, and guessing is what generates review work.

### What Projects does *not* fix

- **Approvals still live inside the thread.** "Telling Claude in the project conversation to go
  ahead doesn't reach it." You must open the thread. Overview surfaces it under `Waiting on you`.
- **Thread limits are preferences, not caps.** "Run at most two threads at a time" is an
  instruction Claude keeps to, not an enforced setting. Hard ceiling: **200 new threads per day**.
- **No local access.** Threads cannot reach a local DB, a device emulator, or an API behind VPN.
  Fias work needing those stays in the TUI.
- **Single user.** "A project belongs to one user. You can't share a project or its threads."
  No org controls during beta.

---

## 3. The decision that matters most: one repo, not many

Buried in the docs, and it directly determines how much babysitting you get:

> "Permission rules, hooks, and `env` come only from the `.claude/settings.json` in the directory
> the thread starts in: inside the repository when the project has one, and **above the clones
> when it has several, where no repository's file is read for them**."

| | One repository | Several repositories |
|---|---|---|
| `CLAUDE.md` | loaded | loaded from every repo |
| Skills / agents / commands | loaded | loaded from every repo |
| **Permission rules, hooks, `env`** | **apply** | **do not apply** |
| `.mcp.json` from the repo | loaded | not loaded |

So: **make Fias a single-repo project** (a monorepo if it has several components). The moment you
add a second repository you lose committed permission rules and hooks — which are exactly the
things that stop threads from stopping to ask you. Multi-repo projects push you back toward
babysitting.

If Fias genuinely spans repos, the documented pattern is: add the one or two repos nearly every
task touches, **name the rest in project instructions**, and let a thread add a repo to itself
when a task needs it.

---

## 4. Keeping Codex as a cross-vendor option

The risk is not that Projects locks the code in — it doesn't, the output is ordinary git branches
and GitHub PRs. The risk is that the *operating knowledge* migrates into Anthropic-only stores
(project memory, project instructions, `.claude/skills/`) and Codex arrives blind.

Correcting a common claim: many 2026 blog posts say Claude Code now reads `AGENTS.md` natively.
The official memory docs say otherwise, verbatim:

> "Claude Code reads `CLAUDE.md`, not `AGENTS.md`. If your repository already uses `AGENTS.md` for
> other coding agents, create a `CLAUDE.md` that imports it so both tools read the same
> instructions without duplicating them."

So the portability contract is five rules:

1. **`AGENTS.md` is the single source of truth.** Codex reads it directly — *"If your repo includes
   AGENTS.md, the agent uses it to find project-specific lint and test commands."*
2. **`CLAUDE.md` is one line: `@AGENTS.md`**, plus anything genuinely Claude-only underneath
   (plan-mode rules, skill pointers). A symlink also works on macOS/Linux:
   `ln -s AGENTS.md CLAUDE.md`. On Windows use the `@AGENTS.md` import — symlinks need Admin.
3. **The quality gate is a shell script, not a skill.** `scripts/check.sh` runs lint + types +
   tests. `AGENTS.md` tells every agent to run it. Claude skills and Codex prompts both just call
   it. Nothing vendor-specific sits between an agent and "is this correct?".
4. **GitHub is the exchange format.** Branch + PR + CI. Both vendors produce the same artifact, and
   a human reviews in GitHub, not in a vendor UI. Codex cloud tasks and Claude threads are
   interchangeable at this boundary.
5. **The spec lives in the repo.** `docs/spec.md` and a task list in git — not only in project
   memory. Project memory is per-user, per-vendor, and deleted with the project. Periodically tell
   Claude "write what you've learned about X into `docs/decisions/`" so the durable part survives
   in a form Codex can read.

Both platforms converged on the same environment model, which makes the parallel easy to hold:
cloud sandbox per task, a cached setup script, secrets injected outside the agent's view,
network off/allowlisted by default. Claude's `Trusted` network level ≈ Codex's restricted agent
internet. Mirror the two setup scripts and either vendor can run the same task.

**Practical split that keeps both honest:** run the ongoing Fias stream in a Claude project;
when a change is architecturally contentious, hand the same `docs/spec.md` section to a Codex
cloud task and diff the two PRs. That is only possible if rules 1–5 hold.

---

## 5. The extremely easy build recipe

Under an hour, mostly copy-paste. Everything in `starter-kit/` is ready to drop into the Fias repo.

**Prerequisites** (check before you start, they are the usual cause of a dead first hour):
- Pro or Max plan, and **Projects** visible in the sidebar at `claude.ai/code`. Not there →
  join the waitlist at `claude.com/form/projects`.
- Code on **github.com** (not GHES/GitLab/Bitbucket), your GitHub account has push access.
- The **Claude GitHub App** installed on `<fias-repo>`. Note: `/web-setup` is *not* enough —
  "that token lets your other cloud sessions reach a repository but isn't enough for project
  threads, which need the Claude GitHub App."

**Steps**

1. **Seed the repo** (5 min). Copy `starter-kit/` contents into the root of `<fias-repo>`:
   `AGENTS.md`, `CLAUDE.md`, `scripts/check.sh`, `.claude/settings.json`. Fill in the real
   commands. Commit and push to the default branch — threads clone from there.

2. **Write `docs/spec.md`** (20 min, the only real work). One page: what Fias is, the components,
   what "done" means for each. This is the artifact the coordinator splits into threads, and the
   one Codex reads too. Spend the time here; it is repaid on every thread.

3. **Create the project** (2 min). `claude.ai/code` → **Projects** → **New project**.
   Name `Fias`. Goal: one line. Context: add `<fias-repo>` only.

4. **Paste the instructions** (2 min). Gear icon → **Memory → Project instructions** →
   paste `starter-kit/PROJECT_INSTRUCTIONS.md` with the placeholders filled. Under 16,000 chars.

5. **Turn the cost down before the first batch** (1 min). **Project settings → General**. A new
   project runs *every* thread on Opus at high effort. Set **Thread effort** to medium and
   **Coordinator model** to a smaller model. You can raise it for a hard task by asking in the task.

6. **Calibrate with one thread** (15 min). Send one small real task. Read how it reports back,
   what it did on the branch, whether it asked or guessed. Fix the gap in instructions, not in
   the task. This is the step people skip and then wonder why ten threads came back wrong.

7. **Go wide.** Paste the spec: *"Build what `docs/spec.md` describes. Propose threads and wait
   for my go-ahead. Run at most three at a time."* Drop the limits once a few land cleanly.

8. **Move recurring chores to routines.** "Every weekday morning, check for dependency updates and
   open a PR" → lands on the project's Routines tab.

**Then the daily loop is:** open Overview → clear `Waiting on you` → review what's under
`Ready for review` → paste today's new work into the conversation → close the laptop.

---

## 6. Cost and failure modes to know up front

- **A project burns plan limits faster than a single session.** Threads are full sessions and
  several run at once. On Pro expect to hit the limit sooner on project days.
- **A thread that hits the limit waits and resumes on its own** when the window resets — so work
  can start consuming your *next* usage window unannounced.
- **Reviving an idle thread is expensive.** Past the cache lifetime (~1h on Pro/Max) a follow-up
  re-reads that thread's whole conversation first. For new work, start a fresh thread.
- **Threads watching PRs wake up and spend** when CI fails or a comment lands. Ask a thread to
  stop watching once its PR is merged.
- **Sandboxes pause between turns** and may resume from a fresh clone — "uncommitted changes can
  be lost. On long tasks, ask Claude to commit and push work in progress." The starter
  instructions include this rule.
- **Threads are one-way.** A thread belongs to the project that started it; it can't be moved out
  or into another project.

---

## Sources

Primary (Anthropic / OpenAI documentation):
- [Let Claude coordinate ongoing work with Projects](https://code.claude.com/docs/en/claude-projects)
- [How Claude remembers your project (CLAUDE.md, AGENTS.md, auto memory)](https://code.claude.com/docs/en/memory)
- [Automate work with routines](https://code.claude.com/docs/en/routines)
- [Configure cloud environments](https://code.claude.com/docs/en/cloud-environments)
- [Claude Code on the web](https://anthropic.com/news/claude-code-on-the-web)
- [Codex cloud environments](https://developers.openai.com/codex/cloud/environments)
- [Introducing Codex](https://openai.com/index/introducing-codex/)
- [@claudeai announcement of Projects](https://x.com/claudeai/status/2100632677904744716)
- [@ClaudeDevs rollout note](https://x.com/ClaudeDevs/status/2100633571543367691)

Secondary:
- [Anthropic Launches Claude Code Projects in Beta (MarkTechPost)](https://www.marktechpost.com/2026/09/17/anthropic-launches-claude-code-projects-in-beta-parallel-cloud-sessions-that-keep-running-after-you-close-your-laptop/)
- [AGENTS.md Spec (2026): AGENTS.md vs CLAUDE.md vs .cursorrules](https://www.morphllm.com/agents-md-guide)
- [Agent Instruction Files: cross-tool portability with Codex CLI](https://codex.danielvaughan.com/2026/05/27/agent-instruction-files-agents-md-claude-md-cross-tool-portability-codex-cli/)
- [Codex Cloud Environments: setup scripts, caching, secrets](https://codex.danielvaughan.com/2026/05/31/codex-cloud-environments-setup-scripts-caching-secrets-codex-universal/)
- [Claude Code vs Codex App in 2026 (Developers Digest)](https://www.developersdigest.tech/blog/claude-code-vs-codex-app-2026)
- [Boris Cherny's Claude Code tips](https://howborisusesclaudecode.com/)

Note on secondary sources: several 2026 posts state that Claude Code reads `AGENTS.md` natively.
The primary docs contradict this. Use the `@AGENTS.md` import or symlink.
