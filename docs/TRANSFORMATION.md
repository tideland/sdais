# SDAIS — Transformation Workflow

**Version:** v0.10.0 | See [INTRODUCTION.md](INTRODUCTION.md) for concepts and prerequisites.

The SDAIS-T (Transformation) workflow applies when an existing codebase precedes the specification. Most real-world systems do not start with a clean specification. They start with code — accumulated over years, built by people who are often no longer around, with intent that lives in git history at best and in tribal knowledge at worst. SDAIS-T is the workflow for those systems.

The starting point is not an exact specification. It is the existing codebase, whatever documentation exists, and your own working knowledge of what the system is supposed to do. From that rough starting point, you will build a formal specification in a loop — annotating, auditing, refining — and then apply targeted transformations to bring the system to a new target state.

---

## When to Use SDAIS-T

- You are migrating an existing system to a new language, framework, or platform.
- You are extracting a monolith into modules or services.
- You need a formal specification for a system that was built without one.
- You are adding observability, a new persistence layer, or a new API style to an existing system.

If you are building from scratch, use the greenfield workflow ([GREENFIELD.md](GREENFIELD.md)).

---

## Process Overview

```mermaid
flowchart TD
    A([Start: existing codebase]) --> B[Step −1\nInstall scaffold]
    B --> B2{Draft prose?}
    B2 -- Yes --> B3[Step 0\nWrite loose prose\nsdais/tspec/v1/]
    B3 --> B4[TransformationEngineer\nClarification loop]
    B4 --> B5{Open questions?}
    B5 -- Yes --> B6[Answer [[QN]] questions\nadd [[AN]] in tspec/vN+1/]
    B6 --> B4
    B5 -- No --> B7[TransformationEngineer\nOutput Generation]
    B7 --> B8[Review TRS items\nPromote CDFs to Active]
    B8 --> C
    B2 -- No: author directly --> C
    C[Step 1\nAuthor / review TRS items\nTRS-FR · TRS-NFR · TRS-C] --> D[Step 2\nAnalyzer\nannotate + derive RSF]
    D --> E[Step 3\nSemantic Audit Loop\nResolve RAR findings]
    E --> F{Findings\nresolved?}
    F -- No --> G[Resolve:\nFix · Drop · Supersede · Waive]
    G --> E
    F -- Yes --> H[Step 4\nGrounder\nif E- items exist]
    H --> I[Step 5\nActivate CDF files\nlang · ui · pers · mod · plat · api · obs · i18n]
    I --> J[Step 6\nTransformation agent\napply CDFs]
    J --> K{Uncovered\nRSF items?}
    K -- Yes --> L[Step 7\nGenerator\nfill gaps]
    L --> M
    K -- No --> M[Step 8\nReviewer]
    M --> N{Violations?}
    N -- Yes --> O[Step 9\nRefiner]
    O --> M
    N -- No: all Verified --> P[Step 10\nHuman Approval Gate]
    P --> Q{Decision}
    Q -- Approve --> R([Done])
    Q -- Amend RSF --> E
    Q -- Reject --> J

    style A fill:#2d6a4f,color:#fff
    style R fill:#2d6a4f,color:#fff
    style B4 fill:#1d3557,color:#fff
    style B7 fill:#1d3557,color:#fff
    style D fill:#1d3557,color:#fff
    style E fill:#1d3557,color:#fff
    style H fill:#1d3557,color:#fff
    style J fill:#1d3557,color:#fff
    style L fill:#1d3557,color:#fff
    style M fill:#1d3557,color:#fff
    style O fill:#1d3557,color:#fff
    style P fill:#e76f51,color:#fff
```

Dark blue = AI agent step. Orange = human decision gate.

---

## Step −1 — Install the Scaffold

Copy the SDAIS distribution files into your project root and run `./install <project-name>` as described in [GREENFIELD.md](GREENFIELD.md) Step −1. The same scaffold and `sdais` launcher are used for both workflows.

---

## Step 0 — Draft Your Transformation Spec (optional)

**Prompt:** `sdais/prompts/transformation-engineer.md` | **Recommended model:** High-reasoning (e.g. Claude Opus)

Writing formal TRS items and CDF files from scratch is hard, especially when the existing system is not well-understood. Step 0 is an optional on-ramp: you write rough prose about the system you have and the changes you want, and the TransformationEngineer turns it into formal TRS items and draft CDF files through an iterative clarification loop.

### When to use it

Use Step 0 when the existing system is complex, poorly documented, or when the desired transformations span multiple dimensions. Skip it if you are comfortable authoring TRS items and CDF files directly.

### How it works

1. Create `sdais/tspec/v1/` and write one or more files describing: (a) what you believe the existing system does, and (b) what transformations you want applied. No filename convention or format constraint applies.
2. Run the **TransformationEngineer**. It reads every tspec file and inserts `[[QN question?]]` markers inline wherever text is ambiguous, makes tacit assumptions about the legacy system, states a transformation without a measurable target, or lacks evidence for a claim about existing behaviour.
3. Open the files in `sdais/tspec/v2/` and answer every `[[QN question?]]` by adding `[[AN your answer]]` on the immediately following line. Do not remove or reword `[[QN]]` markers — they are the agent's domain.
4. Re-run the TransformationEngineer. Repeat until it reports zero open questions.
5. With no open questions remaining, the agent switches to Output Generation mode: it writes TRS item files to `sdais/trs/v1/` (each carrying `**Confidence:**` and `**Source:**` fields) and CDF files to `sdais/cdf/v1/` (each carrying `**Status:** Draft`).
6. Review `sdais/trs/v1/`: amend wording, delete artefacts, and add anything the agent could not derive.
7. Review `sdais/cdf/v1/`: for each CDF you intend to apply, change `**Status:**` from `Draft` to `Active`.

**A note on Confidence:** answers that cite concrete code paths, configuration keys, or documentation yield High-confidence TRS items. Vague answers stated from memory yield Low-confidence items — the Analyzer will perform deep analysis on these before accepting them.

Proceed to Step 1 (or directly to Step 2 if the generated TRS items are sufficient).

---

## Step 1 — Author TRS Items (optional but recommended)

Before running the Analyzer, capture what you believe the existing system does as Transformation Specification (TRS) hypothesis files in `sdais/trs/v1/`. This primes the Analyzer and gives it hypotheses to confirm, refute, or refine — which produces better-quality derived RSF items than starting from zero.

File naming mirrors the RSF convention: `trs-fr-NNNN-<description>.md`, `trs-nfr-NNNN-<description>.md`, `trs-c-NNNN-<description>.md`.

### TRS item format

```markdown
# TRS-FR-0001: Short Title

**Type:** Functional Requirement
**Status:** Hypothesis
**Confidence:** Low | Medium | High
**Introduced:** v1 (YYYY-MM-DD)

## Hypothesis

[What you believe this part of the system does. Imprecision is fine here.]

## Evidence

[Optional. Code references, comments, documentation that support the hypothesis.]

## Open Questions

[What you are unsure about.]
```

**Confidence** governs Analyzer behaviour:

- `High` — strong evidence; Analyzer sample-checks.
- `Medium` — partial evidence; Analyzer validates carefully.
- `Low` — weak hypothesis; Analyzer performs deep analysis before accepting.

The code is always authoritative. When the Analyzer finds that a hypothesis contradicts the code, it opens a `TRS-CONTRADICTS-CODE` finding and you decide which is right.

**Status values:** `Hypothesis | Confirmed | Refuted | Refined`

---

## Step 2 — Run the Analyzer

**Prompt:** `sdais/prompts/analyzer.md` | **Recommended model:** High-coding (e.g. Claude Sonnet)

Point the Analyzer at the existing codebase and any TRS files you authored in Step 1.

The Analyzer works additively — it never modifies existing logic, signatures, or comments. It only adds:

1. `[ANN]` blocks to every callable unit and type. Each block gets a freshly generated `(ANN-ID)`, a reconstructed `(TASK)`, inferred `(PRE)` and `(POST)`, and a `(CONFIDENCE)` label (`Inferred-High`, `Inferred-Medium`, or `Inferred-Low`). Where a TRS item ID can be confidently mapped to a unit, `(ORIGIN)` is set to that TRS item ID for traceability.
2. Formal RSF item files in `sdais/rsf/v1/` derived from observed behaviour.
3. RAR finding files in `sdais/rar/v1/` for anything unclear — using categories `TRS-CONTRADICTS-CODE` (hypothesis contradicted by code) and `CODE-INTENT-UNCLEAR` (behaviour cannot be mapped to any requirement).

After the pass the Analyzer outputs a summary:

```
Analyzer pass complete.
Source files annotated: 24.
[ANN] blocks written: 187.
RSF items derived: 31 (fr: 18, nfr: 8, c: 5).
RAR findings opened: 4 (TRS-CONTRADICTS-CODE: 1, CODE-INTENT-UNCLEAR: 3).
Blocks with Inferred-High: 142.
Blocks with Inferred-Medium: 38.
Blocks with Inferred-Low: 7.
```

The `(ANN-ID)` values assigned here are permanent. They will be preserved through every subsequent transformation and provide a stable audit trail linking every unit in the final transformed codebase back to the original.

---

## Step 3 — Semantic Audit Loop

**Prompt:** `sdais/prompts/semantic-auditor.md` | **Recommended model:** High-reasoning (e.g. Claude Opus)

Run the standard semantic audit on the RSF items derived by the Analyzer. Follow the same procedure as [GREENFIELD.md](GREENFIELD.md) Step 2 exactly. Resolve all standard findings (`AMBIGUOUS`, `INCOMPLETE`, `CONTRADICTORY`, `INFEASIBLE`, `UNTESTABLE`, `UNQUANTIFIED`) before continuing.

Additionally resolve any transformation-specific findings:

- **`TRS-CONTRADICTS-CODE`** — either correct the TRS hypothesis (mark it `Refuted` and create a new RSF item reflecting what the code actually does) or correct the code if the hypothesis represents the intended behaviour.
- **`CODE-INTENT-UNCLEAR`** — clarify intent by examining surrounding context, documentation, or domain knowledge; then either derive an RSF item or mark the code explicitly as out of scope.

These findings require human judgement. The Analyzer surfaces them; you resolve them.

---

## Step 4 — Ground Environment Items

**Prompt:** `sdais/prompts/grounder.md` | **Recommended model:** High-reasoning (e.g. Claude Opus or Sonnet)

Run the Grounder as described in [GREENFIELD.md](GREENFIELD.md) Step 3. This step is especially important in transformation scenarios: `E-` items typically describe infrastructure that already exists and must be confirmed accurately before any transformation touches it.

---

## Step 5 — Activate CDF Files

Define or review the Change Definition Files (CDFs) in `sdais/cdf/v<N>/`. One file per transformation dimension. CDFs are orthogonal and combinable — multiple active CDFs transform the same codebase in a single Transformation pass.

If you ran Step 0, the TransformationEngineer already generated draft CDFs. Change `**Status:**` from `Draft` to `Active` for each CDF you want to apply.

If authoring CDFs directly, use the naming scheme `<category>-NNNN-<description>.md`:

| Prefix | Transformation |
|---|---|
| `lang-` | Language migration (e.g. Java → Go, Python → TypeScript) |
| `ui-` | UI or frontend framework replacement |
| `i18n-` | Localisation — adding multi-language support |
| `pers-` | Persistence layer change (e.g. SQL → document store) |
| `mod-` | Modularisation — monolith ↔ modules ↔ services |
| `plat-` | Platform change — bare metal, container, cloud |
| `api-` | API style change — REST, gRPC, synchronous, asynchronous |
| `obs-` | Observability introduction — logging, metrics, tracing |

### CDF file format

```markdown
# LANG-0001: Java 8 to Go 1.22 Migration

**Category:** lang-
**Status:** Active
**Affects:** all
**Source:** sdais/tspec/v3/migration-goals.md

## Source

Language: Java 8
Build tool: Maven
Runtime: JVM 8

## Target

Language: Go 1.22
Build tool: go build
Runtime: Linux/amd64 binary

## Transformation Rules

1. Replace each Java class with a Go struct and its associated functions.
2. Replace checked exceptions with Go error return values.
3. Replace Java interfaces with Go interfaces.
4. Replace Maven dependency declarations with Go module imports.
5. Replace Java generics with Go generics (1.18+) where applicable.

## Constraints to Preserve

- All (CONSTRAINT) labels from [ANN] blocks must be honoured in the target.
- All (POST) conditions must be preserved in the Go implementation.

## Acceptance

- All RSF items covered by the transformation produce equivalent behaviour
  in the Go implementation.
- All [ANN] blocks carry the same (ANN-ID) as the original Java unit.
```

The `**Affects:**` field lists either specific `(ANN-ID)` references (comma-separated) or `all`. When `all`, the transformation rules apply to every unit in the codebase.

Note: when switching languages (e.g. Python to Go), the Transformation agent discards the source language syntax entirely and re-synthesises in the target language. The `[ANN]` blocks, including their `(ANN-ID)` values, are reset to `(VERIFIED) false` and `(ROUND) 0` since the implementation is new — but the IDs themselves are preserved, maintaining the audit trail.

---

## Step 6 — Run the Transformation Agent

**Prompt:** `sdais/prompts/transformation.md` | **Recommended model:** High-coding (e.g. Claude Sonnet)

Run the Transformation agent, providing the annotated codebase, all active CDF files, and all active RSF items.

The Transformation agent:

- Applies each CDF's transformation rules to the units listed in `Affects`.
- Produces transformed code in the target language, framework, or architecture.
- Preserves all `(ANN-ID)` values according to these rules:
  - **One-to-one:** transformed unit carries the original `(ANN-ID)` unchanged.
  - **Split:** when one unit splits into multiple, the original `(ANN-ID)` stays with the unit retaining primary responsibility; new units receive freshly generated IDs.
  - **Merge:** when multiple units merge into one, the merged unit lists all original `(ANN-ID)` values comma-separated.
- Identifies any RSF items not covered by the transformation and hands them off to the Generator with an explicit list.

After the pass the Transformation agent outputs a summary:

```
Transformation pass complete.
CDFs applied: 1 (lang-0001-java-to-go.md).
Units transformed: 187.
(ANN-ID) preserved (one-to-one): 178.
(ANN-ID) split: 3 original IDs → 9 new units.
(ANN-ID) merged: 6 original IDs → 2 merged units.
New (ANN-ID) generated: 9.
RSF items covered: 29.
RSF items not covered (handed to Generator): 2 — FR-0027, FR-0031.
```

---

## Step 7 — Fill Gaps with the Generator

**Prompt:** `sdais/prompts/generator.md` | **Recommended model:** High-coding (e.g. Claude Sonnet)

If the Transformation agent reports uncovered RSF items, run the Generator to synthesise implementations for those items only. The Generator reads the partially-transformed codebase and the list of uncovered RSF item IDs. It does not touch units already transformed by the Transformation agent.

---

## Steps 8–10 — Standard Review Loop

From this point, follow the greenfield workflow:

- **Step 8 (Review):** The Reviewer checks all `[ANN]` blocks — those from the Transformation agent, any gaps filled by the Generator, and any blocks carried forward from the Analyzer. The dependency cascade check applies as usual.
- **Step 9 (Refine):** Resolve violations as directed by the Reviewer's hints.
- **Step 10 (Approval Gate):** Approve, amend RSF and re-audit, or reject and re-run the Transformation agent.

The `(ANN-ID)` values established by the Analyzer and preserved by the Transformation agent provide a stable audit trail linking every unit in the transformed codebase back to the original annotated unit — even across a complete language change.

---

## Further Reading

- [GREENFIELD.md](GREENFIELD.md) — The canonical SDAIS workflow, which the transformation loop merges into from Step 8 onwards.
- [GLOSSARY.md](GLOSSARY.md) — TRS item types, CDF category prefixes, and all annotation identifiers.
