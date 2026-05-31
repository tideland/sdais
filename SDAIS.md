# SDAIS — Specification-Driven AI Synthesis

**Date:** 2026-05-08
**Version:** v0.10.0
**Status:** Draft

---

## Idea

**Specification-Driven AI Synthesis (SDAIS)** is a software development paradigm in which humans author requirements exclusively, and AI agents synthesise, review, and refine all code. No human writes implementation code. The human role is that of architect and specifier; the AI role is that of implementer, reviewer, and annotator.

The name reflects the three load-bearing elements:

- **Specification-Driven** — a structured, versioned requirements document is the single upstream artefact and the authoritative source of truth. All AI activity is derived from and traceable to it.
- **AI** — one or more AI agents execute the full development lifecycle: generation, annotation, review, refinement, and test authoring.
- **Synthesis** — the output is not a translation of human code, but a synthesis from requirements. The AI selects structure, idioms, and implementation strategy within the constraints given.

---

## Reasoning

Traditional AI-assisted development treats AI as a tool inside a human workflow. The human retains code authorship; AI accelerates specific tasks. SDAIS inverts this: the human retains specification authorship; AI owns the implementation artifact entirely.

This inversion produces several consequences:

**All implicit knowledge must become explicit.** A human developer encodes architectural intent, naming rationale, and edge-case handling implicitly while writing code. In SDAIS, that knowledge must be stated in the specification or it does not exist. This raises the quality bar for requirements — and produces better-defined systems as a side effect.

**Annotations become the cross-session memory of the AI.** Because LLMs are stateless between invocations, the structured annotations embedded in generated code are the only mechanism by which a subsequent agent understands what a prior agent intended. Annotations are not documentation; they are the inter-agent protocol.

**The programming language is a constraint, not a presumption.** The specifier states the target language as a hard constraint, or leaves it unconstrained and lets the AI select. This makes the specification language-agnostic by default.

**Refinement is a loop, not a one-shot operation.** AI agents generate, review, and refine in cycles. Each cycle uses annotations from the prior cycle as its specification. The loop terminates when a review agent finds no violations and all acceptance criteria pass, or when a human approval gate is reached.

**The annotation language is the AI-to-AI handoff protocol.** It derives from Design by Contract (Meyer/Eiffel) — preconditions, postconditions, constraints — but is extended with traceability labels for multi-agent context. It operates at four scope levels: library, package, type, function.

**RSF is always authoritative.** When RSF, ADF, and generated code disagree, the RSF wins. When ADF and generated code disagree without an RSF conflict, the ADF wins. No agent may silently reconcile a conflict: the Generator and Refiner must surface any disagreement as a `(FINDING:n)` label or a RAR finding and request human resolution.

---

## Agent Environment and Model Contract

SDAIS is environment-agnostic: any AI agent system that can read and write files and maintain coherent context across a session is a valid execution environment. The following constraints apply regardless of platform.

### Minimum Capability Requirements

An agent is suitable for any SDAIS role if it:

- Can read and write Markdown files of arbitrary size within a single invocation.
- Maintains sufficient context to process all active RSF items and annotated source files for the current version without truncation.
- Produces structurally stable outputs — the same inputs on successive runs must not produce different artefact shapes unless the RSF changed.

### Recommended Model Tiers

Pin the model version used for each agent in your project's `AGENTS.md` or equivalent configuration. Version drift between rounds — using a different model for round N+1 than for round N — can produce inconsistent finding interpretations.

| Role | Minimum recommended tier | Reason |
|---|---|---|
| RequirementsEngineer | High reasoning (e.g. Claude Opus) | Ambiguity detection in free-form prose and requirement derivation benefit from deeper inference |
| TransformationEngineer | High reasoning (e.g. Claude Opus) | Ambiguity and Confidence elicitation in legacy-system prose require deeper inference |
| SemanticAuditor, SecurityAuditor | High reasoning (e.g. Claude Opus) | Ambiguity detection and security analysis benefit from deeper inference |
| Generator, Refiner, Analyzer, Transformation | High coding ability (e.g. Claude Sonnet) | Code synthesis and annotation precision are primary demands |
| Reviewer | High reasoning or high coding (e.g. Claude Opus or Sonnet) | Finding quality directly determines loop convergence speed |
| Designer, Grounder | High reasoning (e.g. Claude Opus or Sonnet) | Design decisions and infrastructure validation require sound judgment |
| TestGenerator | High coding ability (e.g. Claude Sonnet) | Test correctness and coverage require deep code understanding |

### Agent Output Storage

All agent outputs are files on disk within the `sdais/` tree. No agent output is authoritative unless written to a file and committed to version control. The `sdais/` directory together with git history is the complete audit trail. External execution logs (API transcripts, tool call records) are supplementary and may be stored in `sdais/logs/` if retention is required; they are never read by any agent.

---

## Directory Structure

Every SDAIS project places all specification and workflow artefacts under an `sdais/` directory at the project root. The `AGENTS.md` file lives at the project root as usual.

```
<project-root>/
├── AGENTS.md
└── sdais/
    ├── SDAIS.md              ← paradigm specification (distribution file)
    ├── prompts/              ← installed by install; refreshed by update
    │   ├── requirements-engineer.md
    │   ├── transformation-engineer.md
    │   ├── semantic-auditor.md
    │   ├── grounder.md
    │   ├── designer.md
    │   ├── generator.md
    │   ├── reviewer.md
    │   ├── refiner.md
    │   ├── analyzer.md
    │   ├── transformation.md
    │   ├── security-auditor.md
    │   └── test-generator.md
    ├── gspec/
    │   ├── v1/
    │   │   └── <anything>.md ← initial loose prose; any filename, any format
    │   └── v2/
    │       └── <same names>  ← RequirementsEngineer output with [[QN]] questions
    ├── tspec/
    │   ├── v1/
    │   │   └── <anything>.md ← initial prose about existing system + desired changes
    │   └── v2/
    │       └── <same names>  ← TransformationEngineer output with [[QN]] questions
    ├── rsf/
    │   ├── v1/
    │   │   ├── fr-0000-template.md       ← template; copy to start a new FR
    │   │   ├── nfr-0000-template.md      ← template; copy to start a new NFR
    │   │   ├── c-0000-template.md        ← template; copy to start a new Constraint
    │   │   ├── e-0000-template.md        ← template; copy to start a new Environment item
    │   │   ├── ac-0000-template.md       ← template; copy to start a new AC
    │   │   ├── fr-0001-<short-description>.md
    │   │   ├── fr-0002-<short-description>.md
    │   │   ├── nfr-0001-<short-description>.md
    │   │   ├── c-0001-<short-description>.md
    │   │   ├── e-0001-<short-description>.md
    │   │   └── ac-0001-<short-description>.md
    │   └── v2/
    │       └── ...            ← only items new or amended in v2
    ├── adf/
    │   └── v1/
    │       └── design.md      ← Architecture Definition File; produced by Designer
    ├── trs/
    │   ├── v1/
    │   │   ├── trs-fr-0000-template.md   ← template; copy to start a new TRS-FR
    │   │   ├── trs-nfr-0000-template.md  ← template; copy to start a new TRS-NFR
    │   │   ├── trs-c-0000-template.md    ← template; copy to start a new TRS-C
    │   │   ├── trs-fr-0001-<short-description>.md
    │   │   └── ...
    │   └── v2/
    │       └── ...
    ├── cdf/
    │   ├── v1/
    │   │   ├── lang-0001-<short-description>.md
    │   │   └── ...
    │   └── v2/
    │       └── ...
    └── rar/
        ├── v1/
        │   ├── f-0000-template.md        ← template; reference when writing a new finding
        │   ├── f-0001-<short-description>.md
        │   └── ...
        └── v2/
            └── ...
```

**Version directory semantics:**

- Each `gspec/v<N>/` directory is one iteration of the RequirementsEngineer clarification loop. The human writes initial prose into `gspec/v1/`; the agent creates `gspec/v2/` with `[[QN]]` questions; the human answers in `gspec/v2/`; the agent creates `gspec/v3/` with answers incorporated, and so on. Files are not deleted between versions — each version is an immutable snapshot. The highest version that contains no open `[[QN]]` markers is the clean spec used for RSF generation.
- Each `tspec/v<N>/` directory is one iteration of the TransformationEngineer clarification loop. Semantics are identical to `gspec/`: immutable snapshots, `[[QN]]`/`[[AN]]` protocol, highest clean version used for TRS and CDF generation.
- Each `rsf/v<N>/` directory contains all RSF items that are new or amended in version N. Items unchanged since their introduction remain in their original version directory and are still authoritative.
- Each `rar/v<N>/` directory contains the findings produced by auditing `rsf/v<N>/`. A finding file is never moved; it is the permanent record for that audit.
- Each `trs/v<N>/` directory contains TRS items introduced or amended in version N. Version semantics match those of `rsf/`.
- Each `cdf/v<N>/` directory contains CDF files for that transformation pass. CDFs are not versioned like RSF items; a new version directory is used when a new transformation pass is initiated.
- Each `adf/v<N>/` directory contains the Architecture Definition File (`design.md`) produced by the Designer for version N. The directory is absent if the Designer step was skipped.
- The distribution set is `SDAIS.md`, `install`, `update`, `sdais`, and `sdais-vX.Y.Z.tgz` (or the `scaffold/` directory from the SDAIS repository). Run `./install <project-name>` once to scaffold a new project; run `./update --from <old-version>` to upgrade; run `sdais <tool> <model> <role>` to launch any agent.
- The `prompts/` directory is installed by `install` and refreshed by `update`.

**File naming — why no date in the filename:**
Earlier versions of SDAIS embedded the authoring date in filenames (e.g. `rsf-myproject-v1-2026-04-21.md`) to timestamp versions without relying on version control. In the current structure each file carries its date in its header metadata, and git history is the authoritative timeline. Dates do not appear in filenames.

---

## Lifecycle

```
┌──────────────────────────────────────────────────────┐
│  Human: loose prose in sdais/gspec/v1/                │
│  (any filenames, any format — no constraints)        │
└────────────────────────┬─────────────────────────────┘
                         │
                         ▼
          ┌──────────────────────────┐
          │ AI: RequirementsEngineer │  inserts [[QN]] questions
          │ (Clarification mode)     │  for every ambiguity found
          └──────────┬───────────────┘
                     │
          ┌──────────┴──────────┐
          │  open questions?    │
          └──┬───────────────┬──┘
             │ yes           │ no (spec clean)
             ▼               │
   Human adds [[AN answer]]  │
   after each [[QN]] in      │
   gspec/v<N+1>/              │
             │               ▼
             └──────►  AI: RequirementsEngineer
                       (RSF Generation mode)
                       writes sdais/rsf/v1/
                       with **Source:** field
                             │
                             ▼
                   Human reviews rsf/v1/;
                   amends, adds, or deletes
                             │
                             ▼
┌──────────────────────────────────────────────────────┐
│  Human: Requirements Specification (RSF)             │
│  FR · NFR · Constraints · Environment · Acceptance   │
└────────────────────────┬─────────────────────────────┘
                         │
                         ▼
               ┌──────────────────┐
               │ AI: Semantic     │  checks RSF for ambiguity,
               │ Audit (RAR)      │  contradictions, infeasibility
               └────────┬─────────┘
                        │
               ┌────────┴────────┐
               │  RAR findings?  │
               └──┬──────────┬───┘
                  │ yes      │ no (Cleared)
                  ▼          │
        Human amends RSF     │
        (version increment)  │
                  │          ▼
                  │   ┌─────────────────┐
                  │   │ AI: Grounder    │  verifies E- items against real infrastructure
                  │   └────────┬────────┘
                  │            │  ENV-UNRESOLVABLE findings?
                  │            ├── yes ──► Human amends E- items ──► re-run Grounder
                  │            │
                  │            ▼
                  │   ┌─────────────────┐
                  │   │ AI: Designer    │  optional; produces ADF
                  │   │ (optional)      │
                  │   └────────┬────────┘
                  │            │  Human approves ADF?
                  │            ├── no ──► Designer revises
                  │            │
                  └───►        ▼
                        ┌──────────────────┐
                        │  AI: Generate    │  synthesises implementation
                        │  (or TDD mode:   │  writes [ANN] blocks immediately
                        │   TestGen first) │
                        └────────┬─────────┘
                                 │
                        ┌────────▼─────────┐
                        │  AI: Review      │  validates annotations vs. code
                        │  (Round N)       │  writes FINDING/SEVERITY/HINT
                        │                  │  checks RSF acceptance criteria
                        └────────┬─────────┘
                                 │
                        ┌────────┴────────┐
                        │  violations?    │
                        └──┬──────────┬───┘
                           │ yes      │ no
                           ▼          ▼
                   ┌────────────┐  ┌──────────────────┐
                   │ AI: Refine │  │  Human: Approve  │
                   │  (Round N) │  │  or amend RSF    │
                   └─────┬──────┘  └──────────────────┘
                         │
                         │  all findings resolved?
                         ├── yes ──► Review (Round N+1)
                         │
                         └── waived (needs RSF change) ──► Human amends RSF
```

RSF amendments increment the version and restart the loop from the semantic audit. The prior annotated codebase is not discarded — it becomes input context for the next generation pass.

For SDAIS-T (transformation of existing systems), the lifecycle starts at the SDAIS-T section (see below) and joins the standard SDAIS-G lifecycle at the Generator stage. The annotated existing codebase and the RSF derived by the Analyzer agent are the inputs at that join point.

---

## Usage Guide

### Step −2 — Requirements Engineering (optional)

This step is optional. If you prefer to author RSF items directly, skip to
Step −1. Use this step when you have rough ideas but struggle to write formal
requirements from scratch.

#### Step −2.1 — Write initial specification prose

Create `sdais/gspec/v1/` and write one or more files describing what the system
should do. No filename convention or structure is required — bullet points,
paragraphs, conversation fragments, or any other form are all accepted.

#### Step −2.2 — Run the RequirementsEngineer (Clarification mode)

Provide all files in `sdais/gspec/v1/` to the RequirementsEngineer agent. Use
the prompt from `sdais/prompts/requirements-engineer.md`.

The agent reads every spec file and identifies passages that are ambiguous, use
undefined terms, lack measurable bounds, or are missing acceptance criteria. For
each such passage it inserts a `[[QN question?]]` marker inline immediately
after the affected text, then writes the result to `sdais/gspec/v2/` under the
same filename.

#### Step −2.3 — Answer the questions

Open each file in `sdais/gspec/v2/` that contains a `[[QN question?]]` marker.
For each marker add `[[AN your answer]]` on the immediately following line.

Do not remove, reword, or add `[[QN]]` markers — questions are written
exclusively by the RequirementsEngineer, not by humans.

Re-run the RequirementsEngineer. Repeat until the agent reports zero open
questions.

#### Step −2.4 — RSF Generation

When no open `[[QN]]` questions remain the RequirementsEngineer switches to RSF
Generation mode automatically. It reads the clean spec files and writes one RSF
item file per derived requirement into `sdais/rsf/v1/`. Each generated item
carries a `**Source:**` field listing the spec file(s) it was derived from.

#### Step −2.5 — Human review of generated RSF

Review every item in `sdais/rsf/v1/`:

- Amend wording that is technically correct but does not match your intent.
- Delete items that are artefacts or duplicates.
- Add items the RequirementsEngineer could not derive (it can only work from
  what is in the spec prose).

The `**Source:**` field is the audit trail linking each RSF item back to human
intent. Do not delete it.

When satisfied with `sdais/rsf/v1/`, proceed to Step −1 or directly to Step 0.

---

### Step −1 — Initialise the Project

Before authoring any RSF items, run `install` from the project root to scaffold the `sdais/` directory tree:

```
./install <project-name>
```

This copies `SDAIS.md` to `sdais/SDAIS.md`, installs all prompt files into `sdais/prompts/`, installs all `*-0000-template.md` files, and writes `AGENTS.md` at the project root with the project name substituted.

To launch an agent, use the `sdais` launcher:

```
sdais <tool> <model> <role>
```

For example: `sdais claude claude-opus-4-5 SemanticAuditor`. The launcher accepts the role as CamelCase (`SemanticAuditor`) or kebab-case (`semantic-auditor`). Supported tools: `claude`, `ollama`. Run from the project root.

### Step −1b — Update Scaffolding to a New SDAIS Version

When upgrading to a new SDAIS version, replace `SDAIS.md`, `install`, and `update` (and the tgz or `scaffold/` directory) with the new release, then run from the project root:

```
./update --from <old-version>
```

`update` replaces all scaffold files while leaving all project content untouched.

**What is scaffolding vs. project content:**

| Refreshed by update | Left untouched |
|---|---|
| `AGENTS.md` (Custom Agents Extension preserved) | `sdais/gspec/v*/*.md` |
| All files in `sdais/prompts/` | `sdais/tspec/v*/*.md` |
| All `*-0000-template.md` files | `sdais/rsf/v*/fr-NNNN-*.md` (NNNN ≥ 0001) |
| `sdais/SDAIS.md` | `sdais/rsf/v*/nfr-NNNN-*.md` (NNNN ≥ 0001) |
| | `sdais/rsf/v*/c-NNNN-*.md` (NNNN ≥ 0001) |
| | `sdais/rsf/v*/e-NNNN-*.md` (NNNN ≥ 0001) |
| | `sdais/rsf/v*/ac-NNNN-*.md` (NNNN ≥ 0001) |
| | `sdais/rar/v*/f-NNNN-*.md` (NNNN ≥ 0001) |
| | `sdais/trs/v*/*.md` |
| | `sdais/cdf/v*/*.md` |
| | `sdais/adf/v*/*.md` |
| | All source code files |

---

### Step 0 — Semantic Audit Loop

Before any code is generated the RSF must pass a semantic audit. The SemanticAuditor does not modify the content of any RSF file; it only creates RAR finding files and stages version copies for human amendment.

#### Step 0.1 — Run the SemanticAuditor

Provide all RSF item files for the current version to the `SemanticAuditor`. Use the prompt from `sdais/prompts/semantic-auditor.md`. The agent produces one RAR finding file per finding in `sdais/rar/v<N>/`, then copies every RSF item that appears in at least one finding to `sdais/rsf/v<N+1>/` verbatim, creating the directory if it does not exist.

The full prompt is in `sdais/prompts/semantic-auditor.md`. Summary of agent behaviour: reads all RSF items for the current version; writes one RAR finding file per problem found, categories are `AMBIGUOUS | INCOMPLETE | CONTRADICTORY | INFEASIBLE | UNTESTABLE | UNQUANTIFIED`; copies each affected RSF item file verbatim to `sdais/rsf/v<N+1>/` to stage it for human amendment; outputs a summary of all findings and the list of staged files. Does not modify RSF file content.

#### Step 0.2 — Review each RAR finding

For each finding file the human chooses exactly one resolution action:

| Resolution action | When to use | RSF item change |
|---|---|---|
| **Fix in place** | Item is kept; wording is corrected or quantified | Rewrite the item text; append `[FIXED-RAR-V<N>-F<nn>]` to the Audit History section |
| **Drop** | Item is irrecoverably ambiguous, a duplicate, or no longer needed | Append `[DROPPED-RAR-V<N>-F<nn> — <reason>]` to Audit History; set Status to Dropped |
| **Supersede** | Item is replaced by a new, cleaner formulation under a new ID | Append `[SUPERSEDED→<new-ID>-RAR-V<N>-F<nn>]` to Audit History; create new item file |
| **Split** | One item covered two distinct concerns | Append `[SPLIT→<ID-a>,<ID-b>-RAR-V<N>-F<nn>]` to Audit History; create both new item files |
| **Waive** | Finding acknowledged; RSF intentionally left unchanged | RSF file unchanged; record rationale in finding file Resolution field |

`RAR-V<N>-F<nn>` is the finding reference: `V<N>` is the RSF version audited; `F<nn>` is the zero-padded finding number. Example: `RAR-V1-F02` is finding 02 from the audit of RSF v1.

**Rules for RSF item IDs:**
- IDs are never reused. A dropped or superseded item file remains as a tombstone with `Status: Dropped` or `Status: Superseded`.
- New items introduced during an amendment use the next available sequential number in their prefix group.

#### Step 0.3 — Amend the RSF

The SemanticAuditor has already staged copies of all affected items in `sdais/rsf/v<N+1>/`. For each finding:

- **Fix in place / Drop / Supersede / Split** — amend the pre-staged copy: rewrite or update the `## Requirement` section and append the resolution reference to the Audit History section.
- **Waive** — delete the pre-staged copy from `sdais/rsf/v<N+1>/`; the original file in its current version directory remains authoritative.

Items not affected by any finding are not staged and remain in their current version directory unchanged. New items introduced as part of a Supersede or Split resolution are created directly in `sdais/rsf/v<N+1>/` by the human.

#### Step 0.4 — Update each RAR finding file

In each finding file, fill in the `Resolution` and `Status` fields to reflect the action taken. Finding files are never replaced — they are the audit record.

#### Step 0.5 — Re-audit or proceed

- If any findings remain `Open`: return to Step 0.1 with the new RSF version.
- If all findings are `Resolved` or `Waived`: proceed to Step 0.6 if the RSF contains any `E-` items, otherwise proceed to Step 1.

#### Step 0.6 — Infrastructure Grounding (mandatory when `E-` items are present)

Run the Grounder agent when any active `E-` item exists in the cleared RSF. Use the prompt from `sdais/prompts/grounder.md`.

The Grounder reads every `E-` item and attempts to confirm that each named infrastructure element (database, service endpoint, message queue, file path, API, etc.) exists and matches the item description. For each confirmed element the Grounder appends `**Verified:** true` to the item file. For each element that cannot be confirmed the Grounder opens one RAR finding file in `sdais/rar/v<N>/` with category `ENV-UNRESOLVABLE`.

Resolution paths for `ENV-UNRESOLVABLE` findings:

| Action | When to use | Result |
|---|---|---|
| **Fix in place** | Update the `E-` item to match what actually exists | Grounder re-runs; item receives `**Verified:** true` |
| **Drop** | The named element does not and will not exist | Drop the `E-` item and any dependent FR items |
| **Waive** | Infrastructure is to be created by this project | Append `[WAIVED-RAR-V<N>-F<nn> — to be created by this project]` to item Audit History |

After all `ENV-UNRESOLVABLE` findings are resolved or waived: proceed to Step 1.

The full prompt is in `sdais/prompts/grounder.md`.

---

### Step 1 — Requirements Specification (RSF)

Each RSF item is one Markdown file in `sdais/rsf/v<N>/`. The prefix encodes the item type:

| Prefix | Type |
|---|---|
| `fr-NNNN-` | Functional Requirement |
| `nfr-NNNN-` | Non-Functional Requirement |
| `c-NNNN-` | Constraint |
| `e-NNNN-` | Environment |
| `ac-NNNN-` | Acceptance Criterion |

**RSF item file format:**

```markdown
# FR-0001: Short Title of the Requirement

**Type:** Functional Requirement
**Status:** Active
**Introduced:** v1 (2026-04-21)
**Last modified:** v1 (2026-04-21)
**Source:** sdais/gspec/v3/auth-requirements.md

## Requirement

The service must authenticate requests using an API key supplied in the
`X-API-Key` HTTP header. Requests without a valid key must be rejected
with HTTP 401.

Related: [FR-0003], [NFR-0002], [AC-0001]
```

The `**Source:**` field records which spec file(s) are the primary reason for
this item. It is written by the RequirementsEngineer when generating RSF items
from prose; it may be omitted when a human authors an RSF item directly without
going through Step −2.

Environment (`E-`) items carry an additional field set by the Grounder:

```markdown
# E-0001: Short Title of the Environment Item

**Type:** Environment
**Status:** Active
**Introduced:** v1 (2026-04-21)
**Last modified:** v1 (2026-04-21)
**Verified:** Pending

## Requirement

<description of the runtime or deployment environment element>

Related: [FR-NNNN]
```

`**Verified:**` values: `Pending` (initial, set by human at authoring), `true` (confirmed by Grounder), `false` is not used — an unconfirmed element produces a `ENV-UNRESOLVABLE` RAR finding and the field remains `Pending`.

After one or more audit or review cycles the human appends an **Audit History** section:

```markdown
## Audit History

### [FIXED-RAR-V1-F02]
Changed "valid API key" to "an API key that matches an entry in the
configured key store". Prior wording was AMBIGUOUS.

### [SPLIT→FR-0007,FR-0008-RAR-V2-F01]
Original item covered both key validation and rate-limiting per key.
Split into FR-0007 (validation) and FR-0008 (rate limiting).
```

**Rules:**
- The `## Requirement` section text is the authoritative, current formulation. When an item is fixed in place the section text is rewritten; the old wording is not preserved in the file (the RAR finding file preserves the rationale).
- Items that are Dropped or Superseded set `Status:` accordingly and retain their `## Requirement` text as a tombstone.
- Cross-references use `[FR-NNNN]`, `[NFR-NNNN]`, `[AC-NNNN]`, etc. without version — they resolve to the most recent active version of the referenced item.

---

### Step 1b — Architecture Definition (optional)

Step 1b is skipped unless either of the following conditions holds:
- The cleared RSF contains at least one `C-` item that explicitly requires design approval (i.e., its text calls for architectural sign-off before code is generated).
- The human explicitly invokes the Designer.

When Step 1b runs, provide all cleared RSF items to the Designer agent. Use the prompt from `sdais/prompts/designer.md`.

The Designer reads all active RSF items and produces one Architecture Definition File (ADF) at `sdais/adf/v<N>/design.md`. The ADF covers module decomposition, API surfaces (signatures and contracts, not implementations), data flows, and key design decisions, each traceable to an RSF item ID. The Designer does not write any source code or `[ANN]` blocks.

**ADF file format:**

```markdown
# Architecture Definition — <project> v<N>

**RSF Version:** v<N>
**Status:** Draft | Approved | Superseded
**Designer:** <agent run date>

## Module Decomposition

## API Surfaces

## Data Flows

## Design Decisions

| ID | Decision | RSF Origin | Rationale |
```

**Human review gate:** the human reads `sdais/adf/v<N>/design.md` and either:
- **Approves** — sets `**Status:**` to `Approved`; proceed to Step 2.
- **Rejects** — provides written feedback; the Designer revises and the human reviews again.

**Generator reads the ADF:** if `sdais/adf/v<N>/design.md` exists and its `**Status:**` is `Approved`, the Generator reads it as structural context before synthesising. The ADF is advisory; RSF items remain authoritative.

The full prompt is in `sdais/prompts/designer.md`.

---

### Step 2 — Instruct the Generator Agent

Provide all active RSF item files to the Generator. Use the prompt from `sdais/prompts/generator.md`.

The full prompt is in `sdais/prompts/generator.md`. Summary of agent behaviour: reads all active RSF items; reads `sdais/adf/v<N>/design.md` as structural context if it exists and its Status is Approved; synthesises a complete implementation; writes one `[ANN]` block per callable unit and type with `(ANN-ID)` as the first label; sets `(AGENT)` to `Generator`, `(VERIFIED)` to `false`, and `(ROUND)` to `0` on every block; outputs a summary of files created and RSF items addressed.

#### Step 2 — TDD Mode (optional)

TDD mode inverts the normal generation order. The TestGenerator runs before the Generator and produces test files with failing assertions. The Generator then synthesises implementation targeting those tests.

**Activating TDD mode:** the human adds a `C-` item to the RSF: `C-NNNN: Generation mode: TDD`.

**TDD mode steps:**

1. Run the **TestGenerator** in TDD mode: reads all FR, AC, and NFR items; writes test files with test functions that assert expected behaviour but have no passing implementation. Each test function receives an `[ANN]` block with `(AGENT) TestGenerator`, `(VERIFIED) false`, `(ROUND) 0`, and `(TEST-MODE) TDD`.
2. Run the **Generator**: reads all active RSF items, the ADF (if present and Approved), and the test files from step 1. Synthesises implementation targeting a 100% pass rate on those tests. Writes `[ANN]` blocks as normal. Does not set `(TEST-MODE)` — that label is exclusive to TestGenerator.
3. Continue with the standard Review → Refine loop. The Reviewer additionally verifies that all `(TEST-MODE) TDD` blocks pass against the generated implementation.

---

### Step 3 — Run the Review Agent

Provide the generated, annotated code and all active RSF item files to the Reviewer. Use the prompt from `sdais/prompts/reviewer.md`. Pass the current round number (starts at 1 after the first Generate pass).

The full prompt is in `sdais/prompts/reviewer.md`. Summary of agent behaviour: reads all annotated source files and active RSF items, checks every `[ANN]` block against its requirements and implementation, appends finding labels to blocks with violations, sets `(VERIFIED)` and updates `(AGENT)` and `(ROUND)` on every block, runs a dependency cascade check (for every newly-false block, appends a Medium finding to all blocks whose `(DEPENDS-ON)` references that block's `(ANN-ID)`), outputs a structured summary.

**Review-loop tracking:**

Each review pass increments the round number. The `(ROUND)` label in every `[ANN]` block records which pass last touched it. New findings appended in round N get the next available local index in the block — they are never renumbered to avoid collision with prior `(FINDING:n:STATUS)` entries.

---

### Step 4 — Run the Refiner Agent (if violations exist)

Provide the reviewed, annotated code to the Refiner. Use the prompt from `sdais/prompts/refiner.md`. Pass the same round number used in the Review pass.

The full prompt is in `sdais/prompts/refiner.md`. Summary of agent behaviour: corrects implementation as directed by `(HINT:n)`, appends `(FINDING:n:STATUS)`, updates descriptive fields only when a fix makes them factually incorrect, sets `(VERIFIED)` and `(AGENT)` to reflect resolution outcome, outputs a structured summary.

After each Refiner pass:
- If any blocks remain `(VERIFIED) false` due to Resolved findings (not Waived): run the Reviewer again at round N+1.
- If all remaining `(VERIFIED) false` blocks have only Waived findings: the human amends the RSF (new version), then returns to Step 0.

---

### Step 5 — Human Approval Gate

When the Reviewer reports zero violations and all acceptance criteria pass, the human reviews the output. Three outcomes:

- **Approve** — synthesis complete; RSF files and annotated codebase are archived together.
- **Amend RSF** — increment RSF version, restart loop with existing codebase as context.
- **Reject** — provide written rationale; restart loop from generation.

**Rollback procedure:** If the human determines that the current annotated codebase is irrecoverably diverged from RSF intent, they may roll back to a prior committed state using git. Rolling back does not require discarding the RSF — it requires re-running from the Generator step with the rolled-back codebase as input context. The rolled-back commit and the RSF version that triggered the restart must both be referenced in the next commit message.

**Escalation:** When a Waived finding requires an RSF amendment that itself produces new semantic-audit findings, and this cycle repeats more than twice without convergence, the human must halt the loop, record a `CONTRADICTORY` or `INFEASIBLE` RAR finding capturing the impasse, and decide whether to simplify scope or seek architectural intervention before resuming.

**Approval record:** When approving, the human records the approval in the commit message with the format `Approved: RSF v<N>, Round <R>`. This is the minimum traceability record. Teams may supplement it with a sign-off entry in `sdais/rar/v<N>/` or an approval field in the ADF.

---

## SDAIS-T: Transformation Extension

### Concept and Positioning

The standard SDAIS lifecycle assumes a greenfield project: the specification precedes the code, and the Generator synthesises from scratch. Transformation inverts this. The existing codebase is the primary artefact; specification must be derived from it. Greenfield agents cannot operate on code that has no RSF, no `[ANN]` blocks, and no verified requirements.

The core inversion is: code + fuzzy prior knowledge → specification → transformed code. Prior knowledge — architecture diagrams, design notes, institutional memory — is captured as TRS items (Transformation Specification). TRS items are hypotheses, not assertions. The code is always authoritative when it contradicts a hypothesis.

SDAIS-T produces inputs that feed into the standard SDAIS lifecycle from the Generator stage onwards. The Analyzer agent annotates the existing codebase and derives RSF items; the resulting annotated codebase and RSF replace what the Generator would otherwise produce from scratch. The Transformation agent applies CDF transformations and hands the result to the standard Generator → Reviewer → Refiner loop.

### SpecificationEngineer Archetype

Both RequirementsEngineer and TransformationEngineer are instances of the SpecificationEngineer archetype: each accepts free-form prose, refines it through an iterative `[[QN]]/[[AN]]` clarification loop, and produces formal SDAIS artefacts. RequirementsEngineer produces RSF items from `sdais/gspec/`; TransformationEngineer produces TRS items and CDF files from `sdais/tspec/`. The clarification protocol is identical; the output schema differs.

### Extended Lifecycle Diagram

```
TRS (fuzzy prior knowledge + transformation intent)
    │
    ▼
Analyzer Agent ──► Annotated existing code + RSF v1 + RAR v1
    │
    ▼
Semantic Audit Loop (standard SDAIS Step 0)
    │
    ▼
Cleaned RSF + Annotated existing code
    │
    ▼
Human activates CDF(s)
    │
    ▼
Transformation Agent ──► Transformed code with stable ANN-IDs
    │
    ▼
═══ Transition to Standard SDAIS Lifecycle ═══
    │
    ▼
Generator (gaps only) → Reviewer → Refiner → ...
```

The Analyzer reads the existing codebase and any available TRS items, adds `[ANN]` blocks to every callable unit and type, derives RSF items from observed behaviour, and opens RAR findings for anything unclear. The resulting artefacts pass through the standard Semantic Audit Loop: the human resolves RAR findings, amending RSF items until all findings are Resolved or Waived. The human then activates CDF files defining the desired transformations. The Transformation agent reads the annotated codebase, the active CDF set, and the cleaned RSF, applies each transformation, preserves all `(ANN-ID)` values, and hands the result to the Generator for any RSF items not covered by the transformation. From that point the standard Reviewer → Refiner → Approval loop runs unchanged.

### SDAIS-T Step −2 — Transformation Engineering (optional)

This step is optional. If you prefer to author TRS items and CDF files directly, skip to Step −1. Use this step when you have rough ideas about the existing system and desired changes but struggle to express them in formal TRS and CDF format.

#### Step −2.1 — Write initial transformation prose

Create `sdais/tspec/v1/` and write one or more files describing the existing system and the transformations you want to apply. No filename convention or structure is required.

#### Step −2.2 — Run the TransformationEngineer (Clarification mode)

Provide all files in `sdais/tspec/v1/` to the TransformationEngineer agent. Use the prompt from `sdais/prompts/transformation-engineer.md`.

The agent identifies passages that are ambiguous, use undefined terms, make tacit assumptions about legacy system behaviour, or state transformation goals without measurable targets. For each such passage it inserts a `[[QN question?]]` marker inline, then writes the result to `sdais/tspec/v2/`.

#### Step −2.3 — Answer the questions

Open each file in `sdais/tspec/v2/` that contains a `[[QN question?]]` marker. For each marker add `[[AN your answer]]` on the immediately following line.

Do not remove, reword, or add `[[QN]]` markers — questions are written exclusively by the TransformationEngineer, not by humans.

Re-run the TransformationEngineer. Repeat until the agent reports zero open questions.

#### Step −2.4 — Output Generation

When no open `[[QN]]` questions remain the TransformationEngineer switches to Output Generation mode automatically. It writes TRS item files to `sdais/trs/v1/` and CDF files to `sdais/cdf/v1/`. Each TRS item carries a `**Confidence:**` field and a `**Source:**` field. Each CDF carries `**Status:** Draft` — the human must change this to `Active` before running the Transformation agent.

#### Step −2.5 — Human review of generated TRS and CDF files

Review every item in `sdais/trs/v1/` and every file in `sdais/cdf/v1/`:

- Amend TRS item wording that does not match your understanding of the system.
- Delete items that are artefacts or duplicates.
- Add TRS items the agent could not derive.
- For each CDF you intend to apply, change `**Status:**` from `Draft` to `Active`.

The `**Source:**` fields trace each TRS item and CDF back to the original prose. Do not delete them.

When satisfied, proceed to the Analyzer step.

### TRS — Transformation Specification

Each TRS item is one Markdown file in `sdais/trs/v<N>/`. TRS items represent hypotheses about what the existing system does. They are input context for the Analyzer; they do not drive code generation directly.

**File naming:** same scheme as RSF — `trs-fr-NNNN-<short-description>.md`, `trs-nfr-NNNN-<short-description>.md`, `trs-c-NNNN-<short-description>.md`.

**TRS item file format:**

```markdown
# TRS-FR-0001: LDAP Authentication Subsystem

**Type:** Functional Requirement
**Status:** Hypothesis
**Introduced:** v1 (2026-05-02)
**Confidence:** Medium
**Source:** sdais/tspec/v3/auth-system.md

## Hypothesis

The system authenticates users against a corporate LDAP directory. Credentials
are validated by binding to the LDAP server with the supplied username and
password. A successful bind grants access; a failed bind returns an
authentication error.

## Evidence

- Class `LdapAuthProvider` in `auth/ldap.java` performs a bind operation.
- Configuration key `ldap.server.url` present in `config/app.properties`.
- No alternative authentication path found in the codebase.

## Open Questions

- Is there a fallback to local credential store when LDAP is unreachable?
- Are group memberships retrieved and mapped to application roles?
```

The `**Source:**` field records which tspec file(s) are the primary reason for this item. It is written by the TransformationEngineer when generating TRS items from prose; it may be omitted when a human authors a TRS item directly without going through Step −2.

**Status values:**

| Value | Meaning |
|---|---|
| `Hypothesis` | Initial state; not yet validated against code |
| `Confirmed` | Analyzer or human verified the hypothesis against the code |
| `Refuted` | Code contradicts the hypothesis; Analyzer opened a `TRS-CONTRADICTS-CODE` RAR finding |
| `Refined` | Hypothesis was partially correct; amended after Analyzer findings |

**Confidence semantics:**

| Value | Meaning | Analyzer behaviour |
|---|---|---|
| `High` | Strong evidence in code or cited documentation | Analyzer performs sample-check validation |
| `Medium` | Partial evidence; behaviour likely but not certain | Analyzer validates each claim carefully |
| `Low` | Weak hypothesis; tacit assumption with little direct evidence | Analyzer performs deep code analysis before accepting |

### CDF — Change Definition File

Each CDF in `sdais/cdf/v<N>/` describes exactly one dimension of change. CDFs are orthogonal and combinable — multiple active CDFs can transform the same codebase in one transformation pass.

**File naming:** `<category>-NNNN-<short-description>.md`. Categories:

| Prefix | Category |
|---|---|
| `lang-` | Language migration |
| `ui-` | UI framework change |
| `i18n-` | Localisation / language selection |
| `pers-` | Persistence layer change |
| `mod-` | Modularisation (monolith ↔ modules ↔ services) |
| `plat-` | Platform change (bare metal, container, cloud) |
| `api-` | API style change (REST, gRPC, sync, async) |
| `obs-` | Observability introduction |

**`**Status:**` values:** `Draft` (generated by TransformationEngineer; not yet applied) or `Active` (human-promoted; ready for the Transformation agent).

**CDF file format:**

```markdown
# lang-0001: Java 8 to Go 1.22 Migration

**Type:** Language Migration
**Status:** Active
**Introduced:** v1 (2026-05-02)
**Affects:** all
**Source:** sdais/tspec/v3/migration-goals.md

## Source

Language: Java 8
Build system: Maven 3.x
Runtime: JVM 8 on Linux/amd64

## Target

Language: Go 1.22
Build system: Go modules
Runtime: Native binary on Linux/amd64

## Transformation Rules

1. Each Java class with only static methods becomes a Go package; the class
   name becomes the package name in lowercase.
2. Each Java class with instance state becomes a Go struct; instance methods
   become methods on the struct.
3. Java interfaces become Go interfaces. Method signatures are translated
   directly; checked exceptions become additional error return values.
4. Java generics are translated to Go generics where a direct mapping exists;
   where no direct mapping exists, use the most specific concrete type and open
   a RAR finding CODE-INTENT-UNCLEAR.
5. Maven dependency `org.apache.commons.lang3` is replaced by Go standard
   library equivalents. No third-party replacements.
6. Maven dependency `org.slf4j` is replaced by `log/slog` from the Go standard
   library.
7. LDAP operations using `com.unboundid.ldap.sdk` are replaced by
   `github.com/go-ldap/ldap/v3`.

## Constraints to Preserve

- All (CONSTRAINT:SEC) labels from the existing [ANN] blocks must be present
  in the transformed code.
- All (CONSTRAINT:AVAIL) labels must be present in the transformed code.
- Public API surface (function names, parameter semantics) must remain
  identical where the API is referenced by an active RSF item.

## Acceptance

- All RSF items with Status Active are addressed by at least one [ANN] block
  in the transformed codebase.
- go build completes without errors.
- go vet reports no issues.
- All (ANN-ID) values from the original codebase are present in the transformed
  codebase, subject to split and merge rules.
```

The `**Affects:**` field lists either specific `(ANN-ID)` references (comma-separated) or `all`. When set to `all`, the transformation rules apply to every unit in the codebase.

### Analyzer Agent

The Analyzer operates in three-output mode:

1. **Annotates the existing codebase additively.** Every callable unit and every type receives an `[ANN]` block with a freshly generated `(ANN-ID)`, reconstructed `(TASK)`, inferred `(PRE)` and `(POST)`, and a `(CONFIDENCE)` label. Existing logic, signatures, and comments are never modified. Where a TRS item ID can be confidently mapped to an annotated unit, the Analyzer sets `(ORIGIN)` to that TRS item ID, establishing a stable traceability link.

2. **Derives formal RSF item files** in `sdais/rsf/v1/`. Each distinct observable behaviour, quality attribute, or constraint inferred from the code becomes one RSF item.

3. **Opens RAR finding files** in `sdais/rar/v1/` for any unclear mappings, using the transformation finding categories `TRS-CONTRADICTS-CODE` and `CODE-INTENT-UNCLEAR`.

The full prompt is in `sdais/prompts/analyzer.md`.

### Transformation Agent

The Transformation agent reads the annotated existing codebase, all active CDF files, and all active RSF files. It applies each CDF's transformation rules to the units listed in `Affects:`, produces transformed code in the target language or architecture, and preserves all `(ANN-ID)` values according to the split and merge rules below.

**`(ANN-ID)` preservation rules:**

- **One-to-one:** the transformed unit carries the original `(ANN-ID)` unchanged.
- **Split:** when one original unit splits into multiple new units, the original `(ANN-ID)` stays with the unit retaining primary responsibility. Each additional new unit receives a freshly generated `(ANN-ID)` as `ANN-<8-hex>`.
- **Merge:** when multiple original units merge into one, the merged unit lists all original `(ANN-ID)` values in its `(ANN-ID)` field, separated by commas.

After transformation, any RSF items not covered by the transformed units are handed to the Generator agent.

The full prompt is in `sdais/prompts/transformation.md`.

---

## AGENTS.md — Custom Agents Extension

### Marker Syntax

Custom agent entries in `AGENTS.md` are delimited by HTML comment markers:

```
<!-- BEGIN: Custom Agents Extension -->
...user-defined content...
<!-- END: Custom Agents Extension -->
```

These markers are invisible in rendered Markdown and unambiguous for tooling.

### Update Contract

Any tool, prompt, or human that regenerates `AGENTS.md` must preserve the entire content between the markers verbatim, including ordering and formatting. Only content outside the markers may be replaced.

### Custom Agent Entry Schema

```markdown
#### <AgentName>

**Role:** <one-line description>
**Triggers:** <when this agent is invoked in the lifecycle>
**Reads:** <which artefacts the agent consumes>
**Writes:** <which artefacts the agent produces>
**Annotation Permissions:** <which [ANN] fields the agent may modify>
**Prompt:** `sdais/prompts/<agent-name>.md`
```

### Worked Examples

#### DomainAuditor

**Role:** Validates domain-specific business rules beyond functional correctness.
**Triggers:** Runs after Reviewer in each review round.
**Reads:** Annotated source files; active RSF items; domain rule catalogue.
**Writes:** `(FINDING:n)`, `(SEVERITY:n)`, `(HINT:n)` labels on affected `[ANN]` blocks. Prefixes all finding descriptions with `DOMAIN-`.
**Annotation Permissions:** Same as Reviewer — appends finding labels; updates `(AGENT)`, `(VERIFIED)`, `(ROUND)`.
**Prompt:** `sdais/prompts/domain-auditor.md`

#### ComplianceAuditor-GDPR

**Role:** GDPR-specific data-flow audit; verifies that all personal data handling complies with GDPR requirements.
**Triggers:** Runs mandatorily before any approval gate when at least one active `[ANN]` block carries `(CONSTRAINT:SEC) PII`.
**Reads:** Annotated source files; active RSF items; GDPR compliance checklist.
**Writes:** `(FINDING:n)`, `(SEVERITY:n)`, `(HINT:n)` labels on affected `[ANN]` blocks. Prefixes all finding descriptions with `GDPR-`.
**Annotation Permissions:** Same as SecurityAuditor — appends finding labels for `(CONSTRAINT:SEC)` violations; updates `(AGENT)`, `(VERIFIED)`, `(ROUND)`.
**Prompt:** `sdais/prompts/compliance-auditor-gdpr.md`

### Rules

Custom agents may use any subset of the standard annotation mutation permissions defined in the Annotation Mutation Rules table. A custom agent may define its own finding prefix (e.g. `DOMAIN-`, `GDPR-`) to distinguish its findings from standard agent findings in `(FINDING:n)` descriptions.

Custom agent prompts live in `sdais/prompts/` alongside the standard prompts, and are versioned through git.

---

## Annotation Syntax

### Block Structure

An annotation block is a contiguous comment block opened by the sentinel `[ANN]`. It is separate from any human-facing doc comment. Each label occupies one line. Labels are written and read by agents only — not by humans during normal development.

**Go — Generator output (Round 0):**
```go
// [ANN]
// (ANN-ID)      ANN-7f3a9c2e
// (ORIGIN)      FR-0003, NFR-0001
// (TASK)        Parse IMAP server address and validate format.
// (CONTEXT)     Called once at startup before any connection is attempted.
// (CONSTRAINT)  Address must include host and port; scheme is not validated.
// (PRE)         raw is a non-empty string.
// (INPUT)       raw string — address as provided by the caller
// (OUTPUT)      host string — validated hostname or IP
// (OUTPUT)      port int    — validated port number
// (POST)        host is non-empty; 1 <= port <= 65535.
// (DEPENDS-ON)  ANN-4d1b82fa, ANN-c9e05a31
// (AGENT)       Generator
// (VERIFIED)    false
// (ROUND)       0
func parseAddress(raw string) (host string, port int, err error) {
```

**Go — after Reviewer pass, Round 1 (violations found):**
```go
// [ANN]
// (ANN-ID)      ANN-7f3a9c2e
// (ORIGIN)      FR-0003, NFR-0001
// (TASK)        Parse IMAP server address and validate format.
// (CONTEXT)     Called once at startup before any connection is attempted.
// (CONSTRAINT)  Address must include host and port; scheme is not validated.
// (PRE)         raw is a non-empty string.
// (INPUT)       raw string — address as provided by the caller
// (OUTPUT)      host string — validated hostname or IP
// (OUTPUT)      port int    — validated port number
// (POST)        host is non-empty; 1 <= port <= 65535.
// (AGENT)       Reviewer
// (VERIFIED)    false
// (ROUND)       1
// (FINDING:1)   PRE declares raw is non-empty but no guard exists; empty string reaches net.SplitHostPort.
// (SEVERITY:1)  High
// (HINT:1)      Add guard: if len(raw) == 0 { return "", 0, ErrEmptyAddress }.
// (FINDING:2)   ORIGIN omits NFR-0001; function also enforces input-validation policy defined there.
// (SEVERITY:2)  Low
// (HINT:2)      Append NFR-0001 to (ORIGIN).
func parseAddress(raw string) (host string, port int, err error) {
```

**Go — after Refiner pass, Round 1 (all findings resolved):**
```go
// [ANN]
// (ANN-ID)      ANN-7f3a9c2e
// (ORIGIN)      FR-0003, NFR-0001
// (TASK)        Parse IMAP server address and validate format.
// (CONTEXT)     Called once at startup before any connection is attempted.
// (CONSTRAINT)  Address must include host and port; scheme is not validated.
// (PRE)         raw is a non-empty string.
// (INPUT)       raw string — address as provided by the caller
// (OUTPUT)      host string — validated hostname or IP
// (OUTPUT)      port int    — validated port number
// (POST)        host is non-empty; 1 <= port <= 65535.
// (AGENT)       Refiner
// (VERIFIED)    true
// (ROUND)       1
// (FINDING:1)   PRE declares raw is non-empty but no guard exists; empty string reaches net.SplitHostPort.
// (SEVERITY:1)  High
// (HINT:1)      Add guard: if len(raw) == 0 { return "", 0, ErrEmptyAddress }.
// (FINDING:1:STATUS)  Resolved — empty-string guard added before net.SplitHostPort call
// (FINDING:2)   ORIGIN omits NFR-0001; function also enforces input-validation policy defined there.
// (SEVERITY:2)  Low
// (HINT:2)      Append NFR-0001 to (ORIGIN).
// (FINDING:2:STATUS)  Resolved — NFR-0001 appended to (ORIGIN)
func parseAddress(raw string) (host string, port int, err error) {
```

**Go — Refiner amended a descriptive field (FIELD-CHANGE example):**
```go
// [ANN]
// (ANN-ID)      ANN-7f3a9c2e
// (ORIGIN)      FR-0003, NFR-0001
// (TASK)        Parse IMAP server address and validate format.
// (CONTEXT)     Called once at startup before any connection is attempted.
// (CONSTRAINT)  Address must include host and port; scheme is not validated.
// (PRE)         raw is a non-empty string and contains exactly one colon.
// (FIELD-CHANGE:1)  (PRE) amended — added "and contains exactly one colon" to match guard added for FINDING:1
// (INPUT)       raw string — address as provided by the caller
// ...
```

**Python:**
```python
# [ANN]
# (ANN-ID)      ANN-4d1b82fa
# (ORIGIN)      FR-0003, NFR-0001
# (TASK)        Parse IMAP server address and validate format.
# (CONTEXT)     Called once at startup before any connection is attempted.
# (CONSTRAINT)  Address must include host and port; scheme is not validated.
# (PRE)         raw is a non-empty string.
# (INPUT)       raw: str — address as provided by the caller
# (OUTPUT)      tuple[str, int] — validated (host, port)
# (POST)        host is non-empty; 1 <= port <= 65535.
# (AGENT)       Generator
# (VERIFIED)    false
# (ROUND)       0
def parse_address(raw: str) -> tuple[str, int]:
```

**Java:**
```java
/* [ANN]
 * (ANN-ID)      ANN-c9e05a31
 * (ORIGIN)      FR-0003, NFR-0001
 * (TASK)        Parse IMAP server address and validate format.
 * (CONTEXT)     Called once at startup before any connection is attempted.
 * (CONSTRAINT)  Address must include host and port; scheme is not validated.
 * (PRE)         raw is non-null and non-empty.
 * (INPUT)       raw String — address as provided by the caller
 * (OUTPUT)      InetSocketAddress — validated host/port pair
 * (POST)        Result host is non-empty; 1 <= port <= 65535.
 * (AGENT)       Generator
 * (VERIFIED)    false
 * (ROUND)       0
 */
public InetSocketAddress parseAddress(String raw) {
```

### Annotation mutation rules

Agents must not modify `[ANN]` blocks beyond these permitted actions:

| Agent | Permitted actions |
|---|---|
| Generator | Write the entire block (initial creation only); generate `(ANN-ID)`; write `(DEPENDS-ON)` |
| Reviewer | Update `(AGENT)`, `(VERIFIED)`, `(ROUND)`; append `(FINDING:n)`, `(SEVERITY:n)`, `(HINT:n)` |
| Refiner | Update `(AGENT)`, `(VERIFIED)`, `(ROUND)`; append `(FINDING:n:STATUS)`, `(FIELD-CHANGE:n)`; update descriptive fields only when they become factually incorrect after a code fix |
| SecurityAuditor | Same as Reviewer for `(CONSTRAINT:SEC)` violations |
| TestGenerator | Write entire block on test functions (TDD mode only); set `(TEST-MODE) TDD`; otherwise read-only |
| Analyzer | Write the entire block (initial creation on existing code); generate `(ANN-ID)`; write `(CONFIDENCE)` |
| Transformation | Write the entire block on transformed code; preserve `(ANN-ID)` per split/merge rules; may not modify `(ANN-ID)` beyond those rules; write `(DEPENDS-ON)` |
| Designer | Does not write `[ANN]` blocks; writes only `sdais/adf/v<N>/design.md` |
| Grounder | Does not write `[ANN]` blocks; writes only `**Verified:**` fields in `E-` item files and RAR finding files |

`(ANN-ID)` is written only by Generator and Analyzer at block creation time. No other agent may modify `(ANN-ID)` under any circumstance, except Transformation applying the split/merge rules. Finding labels are never removed or renumbered. `(FINDING:n:STATUS)` is appended directly after the `(HINT:n)` for the same index.

---

## Syntax Table

### Core Labels (from Design by Contract heritage)

| Label              | Cardinality | Scope                  | Description                                                         |
|--------------------|-------------|------------------------|---------------------------------------------------------------------|
| `(ANN-ID)`         | exactly 1 (1–n for merged units) | all | Stable unique identifier in the form `ANN-<8-hex>`. Generated once at block creation by Generator or Analyzer. No agent may modify it except Transformation applying split/merge rules. Must appear as the first label in the block. |
| `(TASK)`           | exactly 1   | all                    | Declarative statement of what this unit does                        |
| `(CONTEXT)`        | 0–1         | all                    | Where and why this unit is used; inherited from outer scope if absent|
| `(CONSTRAINT)`     | 0–n         | all                    | Hard rule, invariant, or limit that applies to this unit            |
| `(CONSTRAINT:PERF)`| 0–n         | all                    | Performance bound (latency, throughput, memory)                     |
| `(CONSTRAINT:SEC)` | 0–n         | all                    | Security classification or access control rule                      |
| `(CONSTRAINT:AVAIL)`| 0–n        | all                    | Availability or fault-tolerance expectation                         |
| `(CONSTRAINT:CONSIST)`| 0–n     | all                    | Data consistency or transactional requirement                       |
| `(CONSTRAINT:COMPAT)`| 0–n      | all                    | API, platform, or runtime compatibility requirement                 |
| `(PRE)`            | 0–n         | function / method      | Condition that must hold before execution                           |
| `(INPUT)`          | 0–n         | function / method      | Named input: `name type — description`                              |
| `(OUTPUT)`         | 0–n         | function / method      | Named output: `name type — description`                             |
| `(POST)`           | 0–n         | function / method      | Condition that must hold after execution                            |

### Structural Labels

| Label           | Cardinality | Scope                     | Written by                   | Description |
|-----------------|-------------|---------------------------|------------------------------|-------------|
| `(DEPENDS-ON)`  | 0–n         | function / method, type   | Generator, Transformation    | Comma-separated `ANN-<8-hex>` IDs of units this unit directly calls or structurally requires. Omitted when there are no dependencies. Format: `ANN-4d1b82fa, ANN-c9e05a31` |
| `(TEST-MODE)`   | 0–1         | function / method         | TestGenerator                | Value: `TDD`. Set on every test function block produced in TDD mode. Absent on all standard test annotations and on all implementation annotations. |

### SDAIS Traceability Labels

| Label          | Cardinality | Scope | Description                                                              |
|----------------|-------------|-------|--------------------------------------------------------------------------|
| `(ORIGIN)`     | 1–n         | all   | RSF requirement ID(s) this unit implements (e.g. `FR-0002, NFR-0001`)   |
| `(AGENT)`      | exactly 1   | all   | Role of the agent that last wrote or modified this block                 |
| `(VERIFIED)`   | exactly 1   | all   | `true` — review agent confirmed; `false` — pending or violation flagged  |
| `(ROUND)`      | exactly 1   | all   | Integer; the review round in which this block was last written or updated|
| `(CONFIDENCE)` | 0–1         | all   | Written by Analyzer (on `[ANN]` blocks) and TransformationEngineer (on TRS items). Values: `Inferred-High`, `Inferred-Medium`, or `Inferred-Low` on ANN blocks; `High`, `Medium`, or `Low` on TRS items. Absent on greenfield-generated annotations. |

### Review Finding Labels

Written by the `Reviewer` (or `SecurityAuditor`) into the `[ANN]` block of any unit where `(VERIFIED)` is `false`. Labels are co-indexed: `(FINDING:n)`, `(SEVERITY:n)`, and `(HINT:n)` with the same `n` describe one finding. `n` is a 1-based integer local to the block and is never reused across rounds. After the Refiner acts, `(FINDING:n:STATUS)` is appended immediately after `(HINT:n)`.

| Label                  | Cardinality | Written by        | Description                                                                    |
|------------------------|-------------|-------------------|--------------------------------------------------------------------------------|
| `(FINDING:n)`          | 0–n         | Reviewer          | Describes one specific violation in this block                                 |
| `(SEVERITY:n)`         | paired      | Reviewer          | `Critical / High / Medium / Low` — paired with the same-indexed FINDING        |
| `(HINT:n)`             | paired      | Reviewer          | Actionable instruction for the Refiner to resolve the paired FINDING           |
| `(FINDING:n:STATUS)`   | 0–n         | Refiner / Human   | `Resolved — <rationale>` or `Waived — requires RSF amendment`                  |
| `(FIELD-CHANGE:n)`     | 0–n         | Refiner           | Documents which descriptive field was changed and why; n matches the FINDING   |

### Agent Role Values (for `(AGENT)`)

| Value                    | Description                                                                    |
|--------------------------|--------------------------------------------------------------------------------|
| `RequirementsEngineer`   | Clarification and RSF derivation from free-form prose in `sdais/gspec/`        |
| `TransformationEngineer` | Clarification and TRS/CDF derivation from free-form prose in `sdais/tspec/`   |
| `Generator`              | Initial synthesis from RSF                                                     |
| `Reviewer`        | Validation pass; sets `(VERIFIED)` and writes finding labels                   |
| `Refiner`         | Corrects violations directed by `(HINT:n)`; writes `(FINDING:n:STATUS)`        |
| `SecurityAuditor` | Specialised pass for `(CONSTRAINT:SEC)` compliance; may write finding labels   |
| `TestGenerator`   | Derives tests from `(PRE)`, `(POST)`, and acceptance criteria; in TDD mode, produces pre-implementation test stubs |
| `SemanticAuditor` | RSF-level semantic validation before generation; produces RAR files            |
| `Analyzer`        | Transformation: annotates existing codebase; derives RSF items; opens RAR findings |
| `Transformation`  | Transformation: applies CDF transformations; preserves `(ANN-ID)` values       |
| `Designer`        | Produces ADF from cleared RSF; runs between infrastructure grounding and generation |
| `Grounder`        | Verifies infrastructure assumptions in `E-` items before generation; opens `ENV-UNRESOLVABLE` RAR findings |

### Scope Levels

| Level             | Applies to                          | Typical labels present                            |
|-------------------|-------------------------------------|---------------------------------------------------|
| Library           | Top-level package / module root     | `(ANN-ID)`, `(TASK)`, `(CONTEXT)`, `(CONSTRAINT)`, `(ORIGIN)` |
| Package           | Sub-package or namespace            | `(ANN-ID)`, `(TASK)`, `(CONTEXT)`, `(CONSTRAINT)`, `(ORIGIN)` |
| Type / Class      | Struct, class, interface, enum      | `(ANN-ID)`, `(TASK)`, `(CONSTRAINT)`, `(ORIGIN)`              |
| Function / Method | Any callable unit                   | All labels                                        |

---

## RAR Finding Categories

The SemanticAuditor assigns one of the following categories to each finding:

| Category | Applies to | Description |
|---|---|---|
| `AMBIGUOUS` | RSF items | Requirement is not precise enough for deterministic synthesis |
| `INCOMPLETE` | RSF items | An FR has no corresponding AC, or an AC does not verify its FR |
| `CONTRADICTORY` | RSF items | Two RSF items are mutually exclusive |
| `INFEASIBLE` | RSF items | A constraint makes one or more FRs impossible to satisfy |
| `UNTESTABLE` | RSF items | An acceptance criterion cannot be verified programmatically |
| `UNQUANTIFIED` | RSF items | An NFR lacks a measurable bound |
| `TRS-CONTRADICTS-CODE` | SDAIS-T workflows | A hypothesis from the TRS is contradicted by what the code actually does |
| `CODE-INTENT-UNCLEAR` | SDAIS-T workflows | Code behaviour cannot be unambiguously mapped to a specific requirement |
| `ENV-UNRESOLVABLE` | greenfield and SDAIS-T workflows | An `E-` item names an infrastructure element that cannot be confirmed to exist or match its description |

`TRS-CONTRADICTS-CODE` and `CODE-INTENT-UNCLEAR` are written by the Analyzer agent only and appear in `sdais/rar/v1/` during a transformation workflow. `ENV-UNRESOLVABLE` is written by the Grounder agent in both greenfield and transformation workflows when an `E-` item cannot be confirmed.

---

## RSF Individual File Format

```markdown
# <TYPE>-NNNN: Short Title

**Type:** Functional Requirement | Non-Functional Requirement | Constraint | Environment | Acceptance Criterion
**Status:** Active | Dropped | Superseded | Split
**Introduced:** v<N> (<YYYY-MM-DD>)
**Last modified:** v<N> (<YYYY-MM-DD>)
**Verified:** Pending | true    ← Environment items only; omitted for all other types
**Source:** sdais/gspec/v<N>/filename.md  ← omit when item was authored directly without Step −2

## Requirement

<Precise, testable statement of the requirement.>

Related: [FR-NNNN], [NFR-NNNN], [AC-NNNN]

## Audit History

(appended by human after each audit or review cycle — absent until first amendment)

### [FIXED-RAR-V<N>-F<nn>]
<What was changed and why.>

### [DROPPED-RAR-V<N>-F<nn>]
Reason: <reason>

### [SUPERSEDED→<new-ID>-RAR-V<N>-F<nn>]
Replaced by <new-ID>. <Reason.>

### [SPLIT→<ID-a>,<ID-b>-RAR-V<N>-F<nn>]
Split into <ID-a> and <ID-b>. <Reason.>

### [WAIVED-RAR-V<N>-F<nn>]
Finding acknowledged; item unchanged. Rationale: <rationale>
```

---

## RAR Individual File Format

Each RAR finding is one Markdown file in `sdais/rar/v<N>/`. The filename follows `f-NNNN-<short-description>.md`. Finding numbers are sequential within a version's audit run, zero-padded to four digits.

```markdown
# F-NNNN: Short Title of Finding

**Category:** AMBIGUOUS | INCOMPLETE | CONTRADICTORY | INFEASIBLE | UNTESTABLE | UNQUANTIFIED | TRS-CONTRADICTS-CODE | CODE-INTENT-UNCLEAR | ENV-UNRESOLVABLE
**Severity:** Critical | High | Medium | Low
**RAR Version:** V<N>
**Audit Date:** <YYYY-MM-DD>
**Status:** Open | Resolved | Waived

## Finding

<Precise description of the problem found in the RSF.>

## References

- [RSF-FR-NNNN-V<N>]
- [RSF-NFR-NNNN-V<N>]

## Hint

<Concrete, actionable instruction for the human author to resolve this finding.>

## Resolution

(filled in by human after review)

**Action:** Fixed | Dropped | Superseded | Split | Waived
**RSF change:** <description of what was changed in which RSF item file>
**Resolved in:** RSF v<N>
```

**Finding `Status` values:**

| Value | Meaning |
|---|---|
| `Open` | No resolution action taken yet |
| `Resolved` | Human amended the RSF; populated Resolution section |
| `Waived — <rationale>` | Human decided no RSF change is needed |

**Reference syntax:** `[RSF-<TYPE>-NNNN-V<N>]` identifies a specific RSF item at a specific version. Example: `[RSF-FR-0003-V1]` = FR-0003 as it existed in RSF v1.

---

## Template Files

The `0000` files in `sdais/rsf/v1/` and `sdais/rar/v1/` are inert scaffolds. They are never processed by any agent. To author a new item, copy the relevant template, rename it with the next available sequence number and a short description, and replace every bracketed placeholder with real content.

### `sdais/rsf/v1/fr-0000-template.md`

```markdown
# FR-0000: [Short title of the functional requirement]

**Type:** Functional Requirement
**Status:** Template
**Introduced:** v1 (YYYY-MM-DD)
**Last modified:** v1 (YYYY-MM-DD)
**Source:** [sdais/gspec/v<N>/filename.md — omit if item was authored directly]

## Requirement

[Precise, testable statement of what the system must do. Begin with "The system
must" or "The <component> must". Describe observable behaviour, not implementation
detail. Every FR must have at least one corresponding AC.]

Related: [Cross-references to related items, e.g. [NFR-0001], [AC-0001]. Omit section if none.]
```

### `sdais/rsf/v1/nfr-0000-template.md`

```markdown
# NFR-0000: [Short title of the non-functional requirement]

**Type:** Non-Functional Requirement
**Status:** Template
**Introduced:** v1 (YYYY-MM-DD)
**Last modified:** v1 (YYYY-MM-DD)
**Source:** [sdais/gspec/v<N>/filename.md — omit if item was authored directly]

## Requirement

[Measurable quality attribute the system must satisfy. Include a numeric bound,
e.g. "95th-percentile latency must not exceed 200 ms under a load of 1 000
concurrent requests". Unquantified NFRs are flagged UNQUANTIFIED by the
SemanticAuditor.]

Related: [Cross-references to related items. Omit section if none.]
```

### `sdais/rsf/v1/c-0000-template.md`

```markdown
# C-0000: [Short title of the constraint]

**Type:** Constraint
**Status:** Template
**Introduced:** v1 (YYYY-MM-DD)
**Last modified:** v1 (YYYY-MM-DD)
**Source:** [sdais/gspec/v<N>/filename.md — omit if item was authored directly]

## Requirement

[Hard rule that narrows the solution space without describing a feature.
Examples: "The implementation must use Go 1.22 or later", "No third-party
cryptographic libraries may be used".]

Related: [Cross-references to related items. Omit section if none.]
```

### `sdais/rsf/v1/e-0000-template.md`

```markdown
# E-0000: [Short title of the environment item]

**Type:** Environment
**Status:** Template
**Introduced:** v1 (YYYY-MM-DD)
**Last modified:** v1 (YYYY-MM-DD)
**Verified:** Pending
**Source:** [sdais/gspec/v<N>/filename.md — omit if item was authored directly]

## Requirement

[Description of the runtime or deployment environment the system must operate
in. Examples: "The service will be deployed as a single binary on Linux/amd64
hosts running kernel 5.15 or later", "The system will have access to a
PostgreSQL 15 instance at the address given by the DATABASE_URL environment
variable".]

Related: [Cross-references to related items. Omit section if none.]
```

### `sdais/rsf/v1/ac-0000-template.md`

```markdown
# AC-0000: [Short title of the acceptance criterion]

**Type:** Acceptance Criterion
**Status:** Template
**Introduced:** v1 (YYYY-MM-DD)
**Last modified:** v1 (YYYY-MM-DD)
**Source:** [sdais/gspec/v<N>/filename.md — omit if item was authored directly]

## Requirement

[Concrete, programmatically verifiable condition that confirms one or more FRs
are satisfied. Specify inputs, expected outputs, and observable side-effects.
Every FR must be covered by at least one AC. Criteria that cannot be verified
programmatically are flagged UNTESTABLE by the SemanticAuditor.]

Related: [Cross-references to the FR(s) this criterion verifies, e.g. [FR-0001].]
```

### `sdais/rar/v1/f-0000-template.md`

```markdown
# F-0000: [Short title of the finding]

**Category:** [AMBIGUOUS | INCOMPLETE | CONTRADICTORY | INFEASIBLE | UNTESTABLE | UNQUANTIFIED | TRS-CONTRADICTS-CODE | CODE-INTENT-UNCLEAR | ENV-UNRESOLVABLE]
**Severity:** [Critical | High | Medium | Low]
**RAR Version:** V[N]
**Audit Date:** [YYYY-MM-DD]
**Status:** [Open | Resolved | Waived]

## Finding

[Precise description of the problem found in the RSF item(s). State which RSF
item is affected, what the problem is, and why it prevents deterministic
synthesis or testing.]

## References

- [RSF-<TYPE>-NNNN-V<N>]

## Hint

[Concrete, actionable instruction for the human author to resolve this finding.
Be specific about what text to add, remove, or change.]

## Resolution

(filled in by human after review)

**Action:** [Fixed | Dropped | Superseded | Split | Waived]
**RSF change:** [Description of what was changed in which RSF item file]
**Resolved in:** RSF v[N]
```
