# CHANGELOG

All notable changes to SDAIS are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
SDAIS uses semantic versioning in the v0.x.0 pre-release series. The major
version will advance to v1.0.0 on first stable release.

---

## [v0.8.0] — 2026-05-03

### Added
- **Agent Environment and Model Contract** section — new normative section
  between Reasoning and Directory Structure. Defines minimum agent capability
  requirements, a recommended model-tier table (with examples for each agent
  role), guidance on pinning model versions per round, and agent output storage
  rules (`sdais/` + git history as the authoritative audit trail; optional
  `sdais/logs/` for execution transcripts).

### Changed
- **SemanticAuditor** now stages version copies: after writing RAR finding
  files the agent copies each affected RSF item verbatim to
  `sdais/rsf/v<N+1>/` (creating the directory if absent). The human amends
  the pre-staged copies for Fix/Drop/Supersede/Split resolutions and deletes
  the copy for Waive resolutions. Step 0.3 updated accordingly.
- **Conflict resolution rule** added to Reasoning section: RSF is always
  authoritative over ADF and generated code; ADF is authoritative over
  generated code when there is no RSF conflict. No agent may silently reconcile
  a conflict — disagreements must be surfaced as `(FINDING:n)` or RAR findings.
- **Step 5 — Human Approval Gate** extended with three normative sub-sections:
  - Rollback procedure: how to recover from an irrecoverably diverged codebase
    using git without discarding the RSF.
  - Escalation: mandatory halt-and-document rule when Waive → RSF-amend cycles
    repeat more than twice without convergence.
  - Approval record: minimum commit-message format `Approved: RSF v<N>, Round <R>`.
- Version bumped from v0.7.0 to v0.8.0.

---

## [v0.7.0] — 2026-05-03

### Added
- `sdais/prompts/security-auditor.md` — SecurityAuditor prompt defined for
  the first time; previously referenced but never written.
- `docs/` directory replacing `HOWTO.md`: three focused guides covering
  introduction and concepts (`docs/INTRODUCTION.md`), the greenfield workflow
  (`docs/GREENFIELD.md`), and the re-engineering workflow
  (`docs/RE-ENGINEERING.md`).

### Changed
- `SDAIS-INIT.md` made fully self-contained: all 10 agent prompts, 5 RSF item
  templates, and 1 RAR finding template are embedded using
  `--- BEGIN FILE / --- END FILE` delimiters. A fresh project deployment
  requires only the three distribution files.
- `SDAIS-UPDATE.md` updated to extract all prompt and template content from
  `SDAIS-INIT.md` delimiters rather than reading existing standalone files.
- `SDAIS-UPDATE.md` now explicitly preserves `sdais/adf/v*/*.md` files
  (Architecture Definition Files) in the protected file list.
- Version numbering changed from sequential integers (v1–v6) to semantic
  versioning (v0.1.0–v0.7.0).

### Removed
- `HOWTO.md` superseded by `docs/INTRODUCTION.md`, `docs/GREENFIELD.md`,
  and `docs/RE-ENGINEERING.md`.

---

## [v0.6.0] — 2026-05-02

### Added
- **Grounder agent** (Step 0.6): mandatory when `E-` items are present;
  verifies each named infrastructure element before generation; sets
  `**Verified:** true` on confirmed items; opens `ENV-UNRESOLVABLE` RAR
  findings for unconfirmed items.
- **Designer agent** (Step 1b, optional): produces an Architecture
  Definition File (ADF) at `sdais/adf/v<N>/design.md` from cleared RSF
  items; runs between Grounder and Generator; requires human approval gate.
- **ADF artefact** (`sdais/adf/v<N>/design.md`): covers module
  decomposition, API surfaces (signatures and contracts), data flows, and
  design decisions traceable to RSF item IDs.
- `adf/` directory in the project tree alongside `rsf/`, `res/`, `cdf/`,
  `rar/`.
- **TDD mode** (Step 2, optional): activated by a `C-` RSF item; the
  TestGenerator runs before the Generator and produces pre-implementation
  test stubs; the Generator then targets 100% pass rate on those tests.
- `(DEPENDS-ON)` annotation label: cardinality 0–n, scope function/method
  and type; written by Generator and Re-engineering; lists `ANN-<8-hex>`
  IDs of directly called or structurally required units on one line.
- `(TEST-MODE)` annotation label: cardinality 0–1, scope function/method;
  written by TestGenerator in TDD mode only; value `TDD`.
- `ENV-UNRESOLVABLE` RAR finding category: applies to greenfield and
  SDAIS-RE workflows; written by the Grounder agent.
- `**Verified:**` field on `E-` item files: values `Pending` (initial) or
  `true` (confirmed by Grounder).
- Dependency cascade check in the Reviewer: when a block is set
  `(VERIFIED) false`, all blocks whose `(DEPENDS-ON)` references that
  block's `(ANN-ID)` receive a Medium-severity cascade finding.
- `sdais/prompts/designer.md` and `sdais/prompts/grounder.md` — new
  standalone prompt files.
- `sdais/prompts/test-generator.md` — new standalone prompt file covering
  Standard and TDD modes.

### Changed
- Lifecycle diagram extended with Grounder and Designer boxes between the
  Semantic Audit Cleared gate and the Generator box.
- Generator prompt updated: reads ADF if present and Approved; writes
  `(DEPENDS-ON)` on every callable unit and type.
- Reviewer prompt updated: added cascade check (step 7) and updated
  summary format to report cascade findings count.
- TestGenerator prompt updated: describes Standard and TDD modes; TDD mode
  writes `(TEST-MODE) TDD` on every block.
- SDAIS-INIT.md and prompts/init.md updated: Grounder and Designer added
  to the Agent Roles table and Directory Layout.
- SDAIS-UPDATE.md and prompts/update-sdais.md updated: grounder and
  designer added to the prompt refresh list.
- Annotation Mutation Rules table: Generator row updated for `(DEPENDS-ON)`;
  TestGenerator row updated for TDD-mode block writing; Designer and
  Grounder rows added (neither writes `[ANN]` blocks).
- Agent Role Values table: Designer and Grounder entries added.
- RAR Finding Categories table: `ENV-UNRESOLVABLE` added.
- RSF Individual File Format: `**Verified:**` field added for `E-` items.
- `e-0000-template.md` template updated to include `**Verified:** Pending`.
- README.md Agent Roles table: Grounder and Designer added.

---

## [v0.5.0] — 2026-05-02

### Added
- `(ANN-ID)` label: stable, unique identifier on every `[ANN]` block; format
  `ANN-<8-hex>`; generated once by Generator or Analyzer; never modified thereafter.
- SDAIS-RE extension covering re-engineering of existing codebases:
  - RES artefact (`sdais/res/v<N>/`) — hypothesis files with Confidence and Status fields.
  - CDF artefact (`sdais/cdf/v<N>/`) — orthogonal, combinable transformation specifications.
  - Analyzer agent — annotates existing code additively, derives RSF items, opens RAR findings.
  - Re-engineering agent — applies CDF transformations while preserving all `(ANN-ID)` values.
  - Extended lifecycle diagram for the re-engineering workflow.
- `(CONFIDENCE)` annotation label — cardinality 0–1, written by Analyzer only, marks
  inferred annotations as `Inferred-High`, `Inferred-Medium`, or `Inferred-Low`.
- Two new RAR finding categories for SDAIS-RE workflows: `RES-CONTRADICTS-CODE` and
  `CODE-INTENT-UNCLEAR`.
- `AGENTS.md` Custom Agents Extension: HTML-comment markers
  `<!-- BEGIN: Custom Agents Extension -->` / `<!-- END: Custom Agents Extension -->`,
  update contract, entry schema, and two worked examples (`DomainAuditor`,
  `ComplianceAuditor-GDPR`).
- `(ANN-ID)` split/merge rules for the Re-engineering agent: original ID follows
  primary responsibility unit on split; merged units list all original IDs
  comma-separated.

### Changed
- All `[ANN]` code examples (Go, Python, Java — Generator, Reviewer, Refiner,
  FIELD-CHANGE states) updated to include `(ANN-ID)` as the first label.
- Generator prompt updated to require cryptographically random `(ANN-ID)` generation,
  unique across the entire codebase.
- All agent prompts extracted from inline SDAIS.md text into standalone files under
  `sdais/prompts/`.
- Directory structure extended with `res/` and `cdf/` directories and new prompt
  entries `analyzer.md` and `re-engineering.md`.
- Annotation Mutation Rules table extended with Analyzer and Re-engineering rows.
- Agent Role Values table extended with Analyzer and Re-engineering entries.

---

## [v0.4.0] — 2026-04-28

### Added
- `update-sdais.md` prompt and **Updater** agent role for refreshing scaffolding
  when `SDAIS.md` itself is upgraded without disturbing project-specific content.
- Explicit table distinguishing what the Updater refreshes vs. what it leaves untouched.
- `(FIELD-CHANGE:n)` label: Refiner documents which descriptive annotation field
  was changed and why when a code fix makes the original description incorrect.
- `(CONSTRAINT:AVAIL)`, `(CONSTRAINT:CONSIST)`, `(CONSTRAINT:COMPAT)` specialised
  constraint labels added to the Syntax Table.
- `SemanticAuditor` added as a named agent role value for `(AGENT)`.
- RAR finding `Status` values table (`Open`, `Resolved`, `Waived — <rationale>`).
- Reference syntax clarification: `[RSF-<TYPE>-NNNN-V<N>]` identifies a specific
  RSF item at a specific version.
- `Template` added as a valid RSF item `Status` value.
- Template Files section with inline content for all six scaffold files.
- Note explaining why dates are not embedded in filenames (git history is authoritative).
- `SDAIS-INIT.md` and `SDAIS-UPDATE.md` distribution files at the `sdais/` root;
  three-file deployment model introduced.

### Changed
- Directory structure moved all specification and workflow artefacts under `sdais/`
  at the project root; `AGENTS.md` remains at the project root.
- RSF and RAR items are now individual files (one file per item) rather than a
  single monolithic document per version.
- Version directory semantics clarified: only new or amended items live in `rsf/vN/`;
  unchanged items remain in their original version directory.
- Audit History section is now absent from RSF items until after the first amendment.
- `(WAIVED-RAR-V<N>-F<nn>)` resolution action added to the RSF item Audit History
  format for Waive resolutions.
- Reviewer and Refiner prompt outputs made more precise; both now end with an exact
  summary format.
- Refiner rule 3 refined: descriptive fields are updated only when a code fix makes
  them factually incorrect, not as a matter of course.

### Removed
- Date-embedded filenames (e.g. `rsf-myproject-v1-2026-04-21.md`) replaced by
  per-item files with date in header metadata.
- Monolithic RSF and RAR document formats superseded by individual file formats.

---

## [v0.3.0] — 2026-04-24

### Added
- `SemanticAuditor` agent and full Semantic Audit Loop (Step 0) before generation.
- RAR (Review/Audit Record) document format for capturing findings.
- Six finding categories: `AMBIGUOUS`, `INCOMPLETE`, `CONTRADICTORY`, `INFEASIBLE`,
  `UNTESTABLE`, `UNQUANTIFIED`.
- Five resolution actions: Fix in place, Drop, Supersede, Split, Waive.
- `AGENTS.md` file at project root; Initialiser agent to scaffold it.
- `sdais/prompts/` directory with one prompt file per agent role.
- `(CONSTRAINT:PERF)` and `(CONSTRAINT:SEC)` specialised constraint labels.
- `SecurityAuditor` agent role.
- `TestGenerator` agent role (read-only on `[ANN]` blocks).
- Annotation mutation rules table defining exactly what each agent may change.

### Changed
- Review finding labels co-indexed: `(FINDING:n)`, `(SEVERITY:n)`, `(HINT:n)`
  with shared index `n`; `(FINDING:n:STATUS)` appended by Refiner after `(HINT:n)`.
- Finding indices are 1-based, local to the block, and never reused across rounds.
- Lifecycle diagram updated to include semantic audit gate and Waive path.

---

## [v0.2.0] — 2026-04-22

### Added
- `(ROUND)` label to track the review pass in which a block was last updated.
- Round-tracking rule: new findings in round N get the next available local index;
  existing indices are never renumbered.
- Explicit rule that finding labels are never removed from `[ANN]` blocks.

### Changed
- `(AGENT)` label now records the agent role that last modified the block, not the
  agent that created it.
- Refiner permitted to update descriptive fields when they become incorrect after
  a code fix.

---

## [v0.1.0] — 2026-04-21

### Added
- Initial specification of the SDAIS paradigm.
- RSF document format covering FR, NFR, Constraint, Environment, and Acceptance
  Criterion item types.
- `[ANN]` annotation block syntax for Go, Python, and Java.
- Core annotation labels: `(TASK)`, `(CONTEXT)`, `(CONSTRAINT)`, `(PRE)`,
  `(INPUT)`, `(OUTPUT)`, `(POST)`, `(ORIGIN)`, `(AGENT)`, `(VERIFIED)`.
- Review finding labels: `(FINDING:n)`, `(SEVERITY:n)`, `(HINT:n)`.
- Refiner label: `(FINDING:n:STATUS)`.
- Scope levels: Library, Package, Type/Class, Function/Method.
- Lifecycle diagram: RSF → Semantic Audit → Generate → Review → Refine → Approve.
- Agent roles: Generator, Reviewer, Refiner.
