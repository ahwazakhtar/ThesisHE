# Project Workflow

Workflow for an R-based econometrics research project. There is no frontend, server,
deployment, or mobile surface: the "product" is a reproducible pipeline (data → panels →
estimates) and the documents built on it.

## Guiding Principles

1. **The plan is the source of truth.** All work is tracked in the active track's
   `plan.md` (`[ ]` → `[~]` → `[x]` + 7-char commit SHA).
2. **Reproducibility over everything.** Every number in a write-up must be regenerable by
   running a script. Never hand-edit build outputs (master CSVs, intermediates,
   `Analysis/` results); fix the generating script and re-run.
3. **Test-first for data code; expectation-first for estimation.** Data-processing code
   gets failing `testthat` tests before implementation. Estimation code gets a written
   expectation (sign, rough magnitude, precision) before the run — a surprise is a
   debugging trigger first and a finding second.
4. **Methods changes are deliberate.** A change to the identification strategy, sample
   window, clustering, or a data source is documented in the track's `spec.md` (or
   `tech-stack.md` for toolchain) *before* implementation, with a dated note.
5. **Non-interactive always.** Scripts run via `Rscript` (correct R version — see
   `conductor/knowledge/environment.md`), never interactive sessions or inline `Rscript -e`.

## Task Lifecycle

1. **Select** the next available task from `plan.md` in order.
2. **Mark in progress:** `[ ]` → `[~]` in `plan.md`.
3. **Red phase (data-processing code):** write `Code/tests/test_<script>.R` asserting the
   behavior — panel uniqueness on unit×time, join match-rate thresholds, no-NA-leakage,
   baseline-window anchoring, value ranges. Run it; confirm it fails before implementing.
   For estimation scripts, instead record the expected result in the plan/spec first.
4. **Implement** the minimum to satisfy the tests/expectation. Every process/estimation
   script self-logs via `sink()` to `Analysis/<family>/build_logs/`, and its header states
   purpose, inputs, outputs, data provenance, and required R version.
5. **Verify:**
   - Tests pass (`Rscript Code/tests/test_*.R`).
   - Outputs landed in `Analysis/<family>/` (never the `Analysis/` root); INDEX row added
     or updated.
   - If an existing specification was touched: compare key coefficients against the prior
     run and investigate any unexplained change before proceeding.
6. **Document deviations:** if implementation departed from `spec.md`, STOP, update the
   spec with a dated note, then resume.
7. **Commit code changes** with a conventional message
   (e.g. `feat(mechanism): C1 SAHIE working-age-uninsured bridge`).
8. **Attach a git note** to the commit: task name, summary of changes, files touched, and
   the core "why" (`git notes add -m "<content>" <hash>`).
9. **Record completion:** mark the task `[x]` + first 7 chars of the commit SHA in
   `plan.md`; commit the plan update
   (`conductor(plan): Mark task '<name>' as complete`).

## Phase Completion: Verification & Checkpointing

Runs immediately after a task that concludes a phase in `plan.md`.

1. **Announce** that the phase is complete and this protocol has begun.
2. **Coverage check:** `git diff --name-only <previous_checkpoint_sha> HEAD` → for each
   changed `.R` file (excluding non-code), confirm a test file exists; create missing ones
   following the existing `Code/tests/` style, validating this phase's tasks.
3. **Run the automated tests.** Announce the exact command first
   (e.g. `Rscript Code/tests/test_did_robustness.R`). If tests fail: max two fix
   attempts, then stop and ask the user.
4. **Propose a Manual Verification Plan** derived from the phase's goals in `spec.md` /
   `plan.md`. Research format:

   ```
   The automated tests have passed. For manual verification:

   **Manual Verification Steps:**
   1. Open `Analysis/<family>/synthesis.md` and confirm the headline result:
      <effect, SE/p-value, expected sign and rough magnitude>.
   2. Spot-check `Analysis/plots/<family>/<figure>.png` — <what it should show>.
   3. Confirm the build log `Analysis/<family>/build_logs/<script>.log` shows
      <N obs / N clusters / no warnings>.
   ```

5. **Await explicit user confirmation.** Ask: "Does this meet your expectations? Confirm
   with yes or say what needs to change." PAUSE — this is the user-owned verification
   gate; it cannot be closed autonomously.
6. **Checkpoint commit** (empty if nothing changed):
   `conductor(checkpoint): Checkpoint end of Phase X`.
7. **Attach the verification report as a git note** on the checkpoint commit: test
   command, manual steps, user's confirmation.
8. **Record the checkpoint SHA** next to the phase heading in `plan.md`
   (`[checkpoint: <sha>]`) and commit the plan update
   (`conductor(plan): Mark phase '<name>' as complete`).

## Quality Gates (before marking any task `[x]`)

- [ ] Tests pass; new data-processing code is covered (target >80%)
- [ ] Script self-logs to `build_logs/` and has a provenance header
- [ ] Outputs in `Analysis/<family>/`; `Analysis/INDEX.md` row current
- [ ] Key coefficients stable vs the prior run, or the change is explained in the plan
- [ ] Durable lessons merged into `conductor/knowledge/*.md`
- [ ] `plan.md` updated

## Commit Guidelines

`<type>(<scope>): <description>` — types: `feat`, `fix`, `docs`, `refactor`, `test`,
`chore`, `conductor` (plan/checkpoint/session bookkeeping). Real examples from this repo:

```
feat(mechanism): B2 Conley SEs + state x year FE on heat headlines (3.2)
fix(county): correct FIPS zero-padding in socioeconomic merge
conductor(plan): Phase 3 complete — mechanisms revision substantively done
conductor(session): Log session changes and update project docs
```

## Definition of Done

A task is done when: implemented to spec; tests written and passing; build log and
provenance header present; outputs filed and indexed; results compared against
expectations with surprises resolved or documented; `plan.md` updated with the commit
SHA; git note attached.
