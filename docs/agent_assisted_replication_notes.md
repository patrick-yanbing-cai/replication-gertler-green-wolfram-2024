# Notes on Agent-Assisted Replication

## Purpose

This note records collaboration lessons from using coding agents to complete
the maintained replication layer for Gertler, Green, and Wolfram (2024),
"Digital Collateral."

It is not a replication runbook. Replication instructions for researchers are
in `replication_notes.md`. This note is for future maintainers who want to use
agents on similar empirical replication projects without losing control of
scope, validation, or publication boundaries.

## Use Issues To Define The Unit Of Agent Work

Agent work was most reliable when each issue had a narrow, testable boundary:
one pipeline foundation task, one support-data construction step, one
final-output module family, one rerun, or one documentation pass. The issue
description should name the files or outputs in scope and should also name the
non-goals.

For Stata replication work, this matters because many scripts share globals,
intermediate files, and source-package assumptions. Without a narrow boundary,
an agent can make a plausible refactor that changes more of the replication
surface than the issue asked for.

Useful prompts should therefore ask the agent to:

1. inspect the relevant issue and current repository state;
2. state the intended files and outputs in scope;
3. identify any required human validation step before implementation is treated
   as complete; and
4. avoid changing adjacent replication behavior unless the issue explicitly
   requires it.

When the task is broad, split it before asking for implementation. In this
project, milestone work became manageable after source audits, support-data
construction, Stata final-output modules, Python replacements, reruns, and
handoff documentation were tracked as separate issues with separate acceptance
evidence.

## Treat Agents As Static Analysts Until Runtime Evidence Exists

Agents are good at reading scripts, mapping dependencies, checking paths,
comparing text outputs, and auditing documentation consistency. They are not a
substitute for the runtime environment when the issue depends on local Stata
behavior.

For this project, Stata validation remained a local user responsibility. The
agent could prepare the entrypoint, inspect the log format, and compare
generated files after a run, but the user's local Stata run was the source of
truth for whether the maintained Stata workflow executed correctly.

A good agent handoff for Stata work should include the exact file to open in
Stata, the expected log path, and the evidence the user should report back. It
should not claim final Stata success from shell-side inspection alone.

## Preserve The Researcher Workflow

The project worked best when the user-facing Stata workflow was kept simple:
open the maintained do-file in Stata and click Run. Agent suggestions that
required long command-window invocations, custom selectors, or manual working
directory setup were less useful for a public replication package.

When asking an agent to maintain Stata code, specify the intended researcher
workflow. In this repository, that meant preserving one top-level Stata
entrypoint at:

```text
code/replication/run_replication.do
```

and keeping setup actions, dependency installation, and replication execution
separate.

Prompts should also state the path assumptions that must survive the change.
For this project, Stata do-file editor runs could start outside the repository
root, so the maintained entrypoint had to resolve repo-relative paths itself.
Directory checks also had to use Stata/Mata `direxists()` rather than relying
on `confirm dir`, which did not give reliable validation behavior in the local
workflow.

The same principle applied across languages. Python replacements were exposed
through a dedicated Python entrypoint rather than being hidden behind Stata,
because Stata GUI sessions and shell sessions can have different PATH and
quoting behavior.

## Separate Source Inputs From Maintained Outputs

Agents need explicit data-boundary language in empirical replication projects.
In this repository, `data/raw` is not automatically suspicious: it is the
staged source-input boundary created from the Dataverse package. The risky
operation is writing maintained generated intermediates back into that source
boundary.

Future prompts should state the distinction directly:

- staged source inputs live under `data/raw`;
- maintained Stata intermediates live under `data/processed/stata`;
- final reproduced outputs live under `output/results`; and
- original Dataverse files are provenance material unless an issue explicitly
  stages or ports them.

This framing helped agents avoid overcorrecting valid reads from `data/raw`
while still preventing generated outputs from leaking into staged source input
directories.

## Ask For Evidence Artifacts, Not General Reassurance

Agent status is most useful when it points to durable evidence: a Stata log, a
Python command result, a verification checklist row, a source-to-output map, or
a git diff limited to the issue scope.

For this replication project, durable evidence included:

- Stata logs under `output/logs/stata`;
- generated outputs under `output/results`;
- reference comparisons recorded in `docs/verification_checklist.md`;
- source provenance in `docs/output_map.md`; and
- explicit git staging limited to the issue's public files.

Prompts should ask the agent to report these artifacts directly. Avoid asking
only whether the project "works"; ask what evidence was checked and what still
depends on the user's local Stata run or human review.

For inventory and checklist work, ask for structured checks before prose edits.
Useful checks include row counts, path existence, whether reproduced outputs
are tracked, and whether public status values match the accepted verification
boundary.

## Keep Verification Claims Narrow

Different evidence supports different claims. A successful Stata rerun proves
that the maintained Stata workflow executed in the local environment. It does
not automatically prove every final output still matches the reference output.
A file-existence audit proves tracked artifacts are present. It does not prove
semantic equivalence. A checklist audit can verify consistency of recorded
status, but it should not invent new runtime evidence.

Agents should be asked to distinguish:

- runtime evidence from Stata or Python execution;
- output comparison evidence against staged references;
- documentation consistency evidence; and
- release-readiness or handoff decisions that require human acceptance.

This separation prevented one successful check from being overstated as a
broader replication claim.

The same caution applies to deterministic replacements for legacy R, Matlab, or
notebook outputs. If an issue accepts deterministic maintained output rather
than byte-for-byte equivalence with renderer-dependent or stochastic originals,
later agents should preserve that documented caveat instead of reopening it as
a new mismatch.

## Treat Release Readiness As A Human Decision

Agents can aggregate evidence, check public documentation, and update status
files. They should not independently decide that a replication package is ready
for public handoff when the project requires human acceptance.

For final handoff work, ask the agent to distinguish the evidence record from
the release-readiness decision. The agent can verify that prerequisite issues
are closed, that documentation no longer contradicts the current state, and
that hygiene checks passed. The final readiness statement should be backed by
explicit human acceptance in the issue history or current review.

## Use Private Reports As Memory, Not As Public Drafts

Private issue reports were useful because they captured reusable lessons while
the details were still fresh. They were not useful as public text without
rewriting. The right workflow was to preserve private lessons locally, then
later synthesize repeated themes into public documentation.

Future private reports should stay short and conclusion-oriented. They should
record principles that change how future agents should work: validation
caveats, source-boundary rules, workflow constraints, and issue-scope hazards.
They should not record search trails, tentative hypotheses, or routine command
transcripts.

When publishing lessons, rewrite them for the audience. Researcher-facing
replication notes should explain how to reproduce the project. Agent-facing
collaboration notes, like this file, should explain how to keep future
agent-assisted work scoped, verifiable, and aligned with the public replication
workflow.

## Review The Diff Like A Scope Check

Mixed worktrees are common during replication work because generated files,
logs, raw data, and private notes coexist with tracked source files. Agents
should therefore treat `git status` and `git diff` as part of validation, not
as an afterthought.

Before publishing agent-assisted work, check that the public diff contains only
the files required by the issue. Private reports, local data, generated logs,
and unrelated work should remain unstaged or ignored unless the issue
explicitly calls for them.

Ignore rules also need the right publication boundary. A local
`.git/info/exclude` rule can keep one worktree clean, but it does not protect
future clones. If a privacy or hygiene rule should apply to the public project,
check it with `git check-ignore -v` and put the rule in tracked ignore
configuration.
