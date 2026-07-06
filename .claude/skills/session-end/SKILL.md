---
name: session-end
description: Execute the end-of-session protocol for this thesis project — changelog entry, knowledge-file merge, CLAUDE.md/INDEX refresh, session-log commit, edit-log cleanup. Invoke when the user signals wrap-up ("wrap up", "we're done", "end session") or when the detect_wrapup hook injects a session-end instruction.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, PowerShell
---

Execute these steps **in order**. The `detect_wrapup` hook usually injects the session
edit log and a `git diff --stat` alongside this instruction — use them as the inventory
of what changed. If they're missing (e.g., the hook was bypassed), reconstruct the
inventory from `.claude/session_edits.log` and `git status`/`git log` yourself. Note the
edit log only captures Edit/Write tool calls — changes made via scripts or shell won't be
in it; cross-check against `git status`.

## 1. Append a `changelog.md` entry

Format: `## YYYY-MM-DD (Session N)` — find N by incrementing the last session number in
the file. Open with a 1–3 sentence summary of what the session was about, then one
`### <path>` block per file or coherent file-group, recording: what changed and why, bugs
found or fixed, and any data/methodological decisions. Style template (match this
register — substantive, decision-focused, bold on the load-bearing terms):

```markdown
## 2026-07-02 (Session 9)

Writing-only session: built a reusable **NBER economist writing-style skill** and used it
to produce mechanism-focused write-ups for the external-reader exchange. No R code or
conductor tracks touched.

### `.claude/skills/nber-economist-writing-style/` (new)
- `SKILL.md` + `reference/exemplars.md` — a writing skill reverse-engineered from
  `Text/w33491.pdf`. Encodes six non-negotiables: … (what + why, not a diff dump)
```

## 2. Merge lessons into the knowledge base

For each non-obvious thing learned this session (a trap, a settled decision with its
reason, an endpoint/format gotcha, a convention), merge it into the matching topic file:

- `conductor/knowledge/data-pipeline.md` — data sources, merges, formats, pipeline deps
- `conductor/knowledge/econometrics.md` — specification decisions, interpretation rules
- `conductor/knowledge/environment.md` — toolchain, packages, run conventions, `.claude/`
- `conductor/knowledge/writing-and-latex.md` — prose, thesis architecture, presentations

**Merge, don't append**: if the topic file already covers the subject, update that entry
in place; delete anything the session proved wrong. Do NOT add session-numbered lesson
lists anywhere. A lesson that changes results silently (corruption-class) also gets a
one-line entry under Cross-Cutting Rules in `CLAUDE.md`.

## 3. Update `CLAUDE.md` (only if warranted)

Only for: a material change to the project snapshot (a track completed/opened), a
directory-structure or pipeline change, or a new cross-cutting rule. Keep it lean — task
state lives in `plan.md` files, knowledge lives in `conductor/knowledge/`.

## 4. Refresh `Analysis/INDEX.md`

If the session produced new analysis outputs: file them under `Analysis/<family>/`
(never the root) and add/update the family's INDEX row (question, headline, read-first).

## 5. Commit the session logs

Stage `changelog.md`, any modified `conductor/knowledge/*.md`, `CLAUDE.md`, and
`Analysis/INDEX.md` (only those actually modified) and commit:

```
conductor(session): Log session changes and update project docs
```

Do not sweep unrelated working-tree changes into this commit.

## 6. Clear the session edit log

```bash
rm -f .claude/session_edits.log
```
