# SDAIS — Greenfield Workflow

**Version:** v0.10.0 | See [INTRODUCTION.md](INTRODUCTION.md) for concepts and prerequisites.

The SDAIS-G (Greenfield) workflow applies when you are building a new system from a clean slate. The specification precedes the code — nothing is generated until the RSF has been validated and cleared.

---

## Process Overview

```mermaid
flowchart TD
    A([Start]) --> B[Step −1\nInstall scaffold]
    B --> B2{Draft prose?}
    B2 -- Yes --> B3[Step 0\nWrite loose prose\nsdais/gspec/v1/]
    B3 --> B4[RequirementsEngineer\nClarification loop]
    B4 --> B5{Open questions?}
    B5 -- Yes --> B6[Answer [[QN]] questions\nadd [[AN]] in gspec/vN+1/]
    B6 --> B4
    B5 -- No --> B7[RequirementsEngineer\nRSF Generation]
    B7 --> C
    B2 -- No: author directly --> C
    C[Step 1\nAuthor / review RSF items\nFR · NFR · C · E · AC] --> D[Step 2\nSemanticAuditor]
    D --> E{Findings?}
    E -- Yes --> F[Resolve findings\nFix · Drop · Supersede · Split · Waive]
    F --> C
    E -- No: Cleared --> G{E- items?}
    G -- Yes --> H[Step 3\nGrounder]
    H --> I{ENV-UNRESOLVABLE\nfindings?}
    I -- Yes --> J[Resolve:\nFix · Drop · Waive]
    J --> H
    I -- No --> K
    G -- No --> K[Step 4\nDesigner\noptional]
    K --> L[Step 5\nGenerator]
    L --> M[Step 6\nReviewer]
    M --> N{Violations?}
    N -- Yes --> O[Step 7\nRefiner]
    O --> M
    N -- No: all Verified --> P[Step 8\nHuman Approval Gate]
    P --> Q{Decision}
    Q -- Approve --> R([Done])
    Q -- Amend RSF --> C
    Q -- Reject --> L

    style A fill:#2d6a4f,color:#fff
    style R fill:#2d6a4f,color:#fff
    style B4 fill:#1d3557,color:#fff
    style B7 fill:#1d3557,color:#fff
    style D fill:#1d3557,color:#fff
    style H fill:#1d3557,color:#fff
    style K fill:#457b9d,color:#fff
    style L fill:#1d3557,color:#fff
    style M fill:#1d3557,color:#fff
    style O fill:#1d3557,color:#fff
    style P fill:#e76f51,color:#fff
```

Dark blue = AI agent step. Teal = optional AI agent step. Orange = human decision gate.

---

## Step −1 — Install the Scaffold

Copy the SDAIS distribution files into your project root (`SDAIS.md`, `install`, `update`, and either `sdais-vX.Y.Z.tgz` or the `scaffold/` directory from the repo), then run:

```
bash install <project-name>
```

This creates `AGENTS.md` at the project root and the `sdais/` directory with all prompt files and templates:

```
<project-root>/
├── AGENTS.md
└── sdais/
    ├── SDAIS.md
    ├── prompts/
    │   ├── requirements-engineer.md
    │   ├── semantic-auditor.md
    │   ├── grounder.md
    │   ├── designer.md
    │   ├── generator.md
    │   ├── reviewer.md
    │   ├── refiner.md
    │   ├── security-auditor.md
    │   ├── test-generator.md
    │   ├── analyzer.md
    │   ├── transformation.md
    │   └── transformation-engineer.md
    ├── rsf/
    │   └── v1/
    │       ├── fr-0000-template.md
    │       ├── nfr-0000-template.md
    │       ├── c-0000-template.md
    │       ├── e-0000-template.md
    │       └── ac-0000-template.md
    └── rar/
        └── v1/
            └── f-0000-template.md
```

Do not edit `AGENTS.md` or any file in `sdais/prompts/` by hand — run `update` to refresh them when upgrading SDAIS.

---

## Step 0 — Draft Your Requirements (optional)

**Prompt:** `sdais/prompts/requirements-engineer.md` | **Recommended model:** High-reasoning (e.g. Claude Opus)

Writing formal requirements from scratch is hard. Step 0 is an optional on-ramp: you write rough prose describing the system you want, and the RequirementsEngineer turns it into formal RSF items through an iterative clarification loop.

### When to use it

Use Step 0 when you have a clear idea of what you want but struggle to express it in the structured FR/NFR/C/E/AC format. Skip it if you are comfortable authoring RSF items directly.

### How it works

1. Create `sdais/gspec/v1/` and write one or more files describing what the system should do. No filename convention or format constraint applies — bullet points, paragraphs, or any mixture.
2. Run the **RequirementsEngineer**. It reads every spec file and inserts `[[QN question?]]` markers inline wherever text is ambiguous, uses undefined terms, or is missing a measurable bound or acceptance criterion.
3. Open the files in `sdais/gspec/v2/` and answer every `[[QN question?]]` by adding `[[AN your answer]]` on the immediately following line. Do not remove or reword `[[QN]]` markers — they are the agent's domain.
4. Re-run the RequirementsEngineer. Repeat until it reports zero open questions.
5. With no open questions remaining, the agent switches to RSF Generation mode: it reads the clean spec files and writes one RSF item file per derived requirement into `sdais/rsf/v1/`, each carrying a `**Source:**` field pointing to the spec file it was derived from.
6. Review `sdais/rsf/v1/`: amend wording, delete artefacts, and add anything the agent could not derive. The `**Source:**` field traces each item back to the original prose.

Proceed to Step 1 (or directly to Step 2 if satisfied with the generated RSF).

---

## Step 1 — Author Your Requirements (RSF)

Copy the relevant template, rename it with the next available sequence number and a short description, then replace every bracketed placeholder with real content. This is the only step in the entire process that is purely human.

### File naming

| Template | Example |
|---|---|
| `fr-0000-template.md` | `fr-0001-authenticate-requests.md` |
| `nfr-0000-template.md` | `nfr-0001-response-latency.md` |
| `c-0000-template.md` | `c-0001-go-version.md` |
| `e-0000-template.md` | `e-0001-database-connection.md` |
| `ac-0000-template.md` | `ac-0001-valid-key-accepted.md` |

Sequence numbers start at `0001` and are never reused. Items retired during an audit carry status tags and remain in the file as tombstones — the history of every decision is preserved in git.

### Writing good requirements

**Functional Requirements (FR):** Begin with "The system must" or "The \<component\> must". Describe observable behaviour, not implementation detail. Every FR must have at least one corresponding AC.

**Non-Functional Requirements (NFR):** Always include a numeric bound. "Low latency" is not a requirement. "95th-percentile latency must not exceed 200 ms under 1 000 concurrent requests" is.

**Constraints (C):** Hard rules that narrow the solution space without describing a feature. "The implementation must use Go 1.22 or later." To activate TDD mode, add a constraint item with `Generation mode: TDD`.

**Environment (E):** Runtime or deployment facts the AI must know. Set `**Verified:** Pending` on every E- item at authoring; the Grounder sets it to `true` after confirming the element exists.

**Acceptance Criteria (AC):** Programmatically verifiable conditions. Specify inputs, expected outputs, and observable side-effects. Every FR must be covered by at least one AC.

### Cross-references

Use `[FR-NNNN]`, `[NFR-NNNN]`, `[AC-NNNN]`, etc. inline in the `## Requirement` section to link related items. References resolve to the most recent active version.

---

## Step 2 — Semantic Audit

**Prompt:** `sdais/prompts/semantic-auditor.md` | **Recommended model:** High-reasoning (e.g. Claude Opus)

Before any code is generated, the RSF must pass a semantic audit. This is the quality gate that catches problems in the specification itself — ambiguity, gaps, contradictions, NFRs without numeric bounds — before they propagate into code that is hard to fix.

1. Run the **SemanticAuditor**, providing all RSF item files for the current version.
2. The agent writes one finding file per problem into `sdais/rar/v<N>/`.
3. For each finding, choose exactly one resolution action and update the finding file's `Resolution` and `Status` fields:

| Action | When to use | RSF item change |
|---|---|---|
| **Fix in place** | Item kept; wording corrected or quantified | Rewrite item text; append `[FIXED-RAR-V<N>-F<nn>]` to Audit History |
| **Drop** | Item irrecoverably ambiguous or no longer needed | Append `[DROPPED-RAR-V<N>-F<nn> — <reason>]` to Audit History |
| **Supersede** | Replace with a cleaner formulation under a new ID | Append `[SUPERSEDED→<new-ID>-RAR-V<N>-F<nn>]`; create new item file |
| **Split** | One item covered two distinct concerns | Append `[SPLIT→<ID-a>,<ID-b>-RAR-V<N>-F<nn>]`; create both new files |
| **Waive** | Finding acknowledged; item intentionally unchanged | RSF unchanged; record rationale in the finding file |

4. The SemanticAuditor stages copies of affected items in `sdais/rsf/v<N+1>/`. Amend the pre-staged copies (Fix/Drop/Supersede/Split) or delete them (Waive). Re-audit if any findings remain `Open`. Repeat until all findings are `Resolved` or `Waived` — the RSF is now **Cleared**.

---

## Step 3 — Ground Environment Items

**Prompt:** `sdais/prompts/grounder.md` | **Recommended model:** High-reasoning (e.g. Claude Opus or Sonnet)

Mandatory when `E-` items are present. Skip this step only if the RSF has no environment items.

The Grounder verifies each `E-` item against real infrastructure — checking database connections, service endpoints, environment variables, file paths, secret mounts, etc. For each confirmed element it sets `**Verified:** true`. For each element it cannot confirm it opens an `ENV-UNRESOLVABLE` RAR finding.

Resolve all `ENV-UNRESOLVABLE` findings before proceeding:

- **Fix in place:** update the `E-` item to match what actually exists; re-run Grounder.
- **Drop:** remove the `E-` item and any FR items that depend on it.
- **Waive:** append `[WAIVED-RAR-V<N>-F<nn> — to be created by this project]` if the infrastructure element will be built as part of this project.

---

## Step 4 — Design (optional)

**Prompt:** `sdais/prompts/designer.md` | **Recommended model:** High-reasoning (e.g. Claude Opus or Sonnet)

Run the Designer if you want a human-approved architecture checkpoint before any code is written. This is particularly valuable for systems with non-trivial module boundaries or complex data flows — it surfaces structural disagreements early, when they are cheap to fix.

The Designer reads all cleared RSF items and produces `sdais/adf/v<N>/design.md` covering:

- Module decomposition (name, responsibility, RSF item IDs addressed)
- API surfaces (signatures and contracts, not implementations)
- Data flows between modules
- Design decisions, each traceable to one or more RSF item IDs

Review the ADF and either approve it (set `**Status:** Approved`) or reject it with written feedback for the Designer to revise. An approved ADF is read by the Generator as structural context — it guides module and package layout without overriding RSF requirements. RSF items remain authoritative if ADF and RSF ever conflict.

---

## Step 5 — Generate

**Prompt:** `sdais/prompts/generator.md` | **Recommended model:** High-coding (e.g. Claude Sonnet)

The Generator reads the cleared RSF and synthesises a complete implementation. It selects data structures, idioms, and implementation strategy within the constraints you specified.

### Standard mode

The Generator:

- Reads all active RSF items.
- Reads `sdais/adf/v<N>/design.md` as structural context if present and Approved.
- Synthesises a complete implementation.
- Writes one `[ANN]` block per callable unit and type. Every block starts with `(VERIFIED) false` and `(ROUND) 0`.

Do not edit generated code by hand. Any manual change will be overwritten or will conflict with annotation state in the next round.

### TDD mode

If the RSF contains a Constraint item with `Generation mode: TDD`:

1. Run **TestGenerator** first (`sdais/prompts/test-generator.md`), specifying TDD mode. It writes test stubs with failing assertions derived from `(PRE)`, `(POST)`, and AC items. Every test block carries `(TEST-MODE) TDD`.
2. Run the **Generator** targeting 100% pass rate on those tests.

TDD mode inverts the order — tests define the target, Generator satisfies them — and gives you an objective completion signal.

### What annotations the Generator writes

Every `[ANN]` block produced by the Generator contains:

| Label | Value at generation |
|---|---|
| `(ANN-ID)` | Freshly generated `ANN-<8-hex>`; stable for the lifetime of the unit |
| `(ORIGIN)` | RSF item IDs this unit implements |
| `(TASK)` | Declarative statement of what the unit does |
| `(CONTEXT)` | Where and why the unit is used |
| `(CONSTRAINT)` | Hard rules or invariants applying to this unit |
| `(PRE)` / `(POST)` | Preconditions and postconditions for functions and methods |
| `(INPUT)` / `(OUTPUT)` | Named parameters and return values with types |
| `(DEPENDS-ON)` | `ANN-<8-hex>` IDs of units this unit directly calls |
| `(AGENT)` | `Generator` |
| `(VERIFIED)` | `false` |
| `(ROUND)` | `0` |

These labels are the shared language that all subsequent agents read. They are what makes a stateless Reviewer or Refiner effective without needing access to the original conversation.

---

## Step 6 — Review

**Prompt:** `sdais/prompts/reviewer.md` | **Recommended model:** High-reasoning or high-coding (e.g. Claude Opus or Sonnet)

Run the Reviewer after every Generate or Refine pass. Pass the current round number (1 after the first Generate pass).

The Reviewer checks every `[ANN]` block:

- Is `(ORIGIN)` pointing to a real, active RSF item?
- Does the code actually implement what `(TASK)` declares?
- Are `(PRE)` and `(POST)` enforced in the implementation?
- Are all `(CONSTRAINT)` labels respected?
- Is every FR covered, and does at least one AC pass?

It also runs a **dependency cascade check**: when a block is set `(VERIFIED) false`, every block whose `(DEPENDS-ON)` references that block's `(ANN-ID)` receives an automatic Medium cascade finding. This prevents silent propagation of errors through the call graph.

After the pass the Reviewer outputs a summary:

```
Round 1 review complete.
Violations: 3 blocks, 5 total findings.
Cascade findings added: 2 blocks.
Clean: 12 blocks.
Unaddressed RSF items (if any): AC-0003
```

Clean blocks are set `(VERIFIED) true` and are not touched again unless their dependencies change.

---

## Step 7 — Refine

**Prompt:** `sdais/prompts/refiner.md` | **Recommended model:** High-coding (e.g. Claude Sonnet)

Run the Refiner after every Review pass that contains violations. Pass the same round number used by the Reviewer.

The Refiner works block by block through every `(VERIFIED) false` block:

- Corrects the code as directed by each `(HINT:n)`.
- Appends `(FINDING:n:STATUS) Resolved — <rationale>` for each fix.
- If a code fix makes a descriptive label inaccurate (e.g. `(TASK)` no longer matches), updates the label and appends `(FIELD-CHANGE:n)` documenting what changed and why.
- Sets `(VERIFIED) true` when all findings in a block are resolved.
- Marks unresolvable findings `Waived — requires RSF amendment` rather than silently papering over them.

Return to Step 6 at round N+1. Repeat until the Reviewer reports zero violations.

If remaining violations are all `Waived`, the RSF needs amendment: increment the RSF version, re-audit from Step 2, and restart generation. Waived findings are not ignored — they are evidence that the specification and implementation cannot be reconciled without changing the requirements.

---

## Step 8 — Human Approval Gate

When the Reviewer reports zero violations and all ACs pass, you make the final call:

- **Approve** — synthesis is complete. Archive RSF files and annotated codebase together in git. Record the approval: `Approved: RSF v<N>, Round <R>`.
- **Amend RSF** — requirements have changed or the result reveals a gap. Increment the RSF version, restart from Step 2 with the existing annotated codebase as context.
- **Reject** — the implementation is correct but you want a different approach. Provide written rationale and restart from Step 5.

---

## Optional Passes

### Security Audit

**Prompt:** `sdais/prompts/security-auditor.md` | **Recommended model:** High-reasoning (e.g. Claude Opus)

Run the SecurityAuditor on demand or after generation. It checks all `(CONSTRAINT:SEC)` labels and scans for hard-coded credentials, unvalidated inputs passed to sensitive operations, missing authorisation checks, and unsafe cryptography. It uses the same `(FINDING:n)` / `(HINT:n)` mechanism as the Reviewer so findings flow directly to the Refiner. Security findings are prefixed `SEC:`.

### Test Generation (Standard Mode)

**Prompt:** `sdais/prompts/test-generator.md` | **Recommended model:** High-coding (e.g. Claude Sonnet)

After all `[ANN]` blocks are `(VERIFIED) true`, run TestGenerator in Standard mode. It derives test functions from `(PRE)`, `(POST)`, and AC items in the verified implementation. It reads annotation blocks in implementation files but does not modify them.
