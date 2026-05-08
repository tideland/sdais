# SDAIS — Re-Engineering Workflow

**Version:** v0.8.0 | See `docs/INTRODUCTION.md` for concepts and prerequisites.

The re-engineering workflow (SDAIS-RE) applies when an existing codebase precedes the specification. The Analyzer agent derives RSF items from observed code behaviour. The Re-engineering agent applies CDF transformations while preserving annotation identifiers. The result feeds into the standard greenfield loop from Review onwards.

---

## When to Use SDAIS-RE

Use the re-engineering workflow when:
- You are migrating an existing system to a new language, framework, or platform.
- You are extracting a monolith into modules or services.
- You need a formal specification for a system that was built without one.
- You are adding observability, a new persistence layer, or a new API style to an existing system.

If you are building from scratch, use the greenfield workflow (`docs/GREENFIELD.md`).

---

## Step −1 — Install the Scaffold

Copy the SDAIS distribution files into your project root and run `bash install.sh <project-name>` as described in `docs/GREENFIELD.md` Step −1.

---

## Step 1 — Author RES Hypotheses (optional but recommended)

Before running the Analyzer, capture what you believe the existing system does as Re-engineering Specification (RES) hypothesis files in `sdais/res/v1/`.

File naming follows the same convention as RSF: `res-fr-NNNN-<short-description>.md`, `res-nfr-NNNN-...`, etc.

### RES item file format

```markdown
# RES-FR-0001: Short Title

**Type:** Functional Requirement
**Status:** Hypothesis
**Confidence:** Low | Medium | High
**Introduced:** v1 (YYYY-MM-DD)

## Hypothesis

[What you believe this part of the system does. May be imprecise.]

## Evidence

[Optional. Code references, comments, documentation fragments that support
the hypothesis.]

## Open Questions

[What you are unsure about.]
```

**Confidence** governs Analyzer behaviour:
- `High` — strong evidence; Analyzer sample-checks.
- `Medium` — partial evidence; Analyzer validates carefully.
- `Low` — weak hypothesis; Analyzer performs deep analysis before accepting.

RES items are hypotheses, not assertions. The code is always authoritative when it contradicts a hypothesis.

**Status values:** `Hypothesis | Confirmed | Refuted | Refined`

---

## Step 2 — Run the Analyzer

Run the **Analyzer** agent (`sdais/prompts/analyzer.md`), pointing it at the existing codebase and any RES files.

The Analyzer:
1. Adds `[ANN]` blocks to every callable unit and type in the codebase, additively — existing logic, signatures, and comments are never modified.
2. Each block gets a freshly generated `(ANN-ID)`, reconstructed `(TASK)`, inferred `(PRE)` and `(POST)`, and a `(CONFIDENCE)` label (`Inferred-High`, `Inferred-Medium`, or `Inferred-Low`).
3. Derives formal RSF item files in `sdais/rsf/v1/` from observed behaviour.
4. Opens RAR finding files in `sdais/rar/v1/` for anything unclear, using categories `RES-CONTRADICTS-CODE` and `CODE-INTENT-UNCLEAR`.

After the pass the Analyzer outputs:

```
Analyzer pass complete.
Source files annotated: 24.
[ANN] blocks written: 187.
RSF items derived: 31 (fr: 18, nfr: 8, c: 5).
RAR findings opened: 4 (RES-CONTRADICTS-CODE: 1, CODE-INTENT-UNCLEAR: 3).
Blocks with Inferred-High: 142.
Blocks with Inferred-Medium: 38.
Blocks with Inferred-Low: 7.
```

---

## Step 3 — Semantic Audit Loop

Run the standard semantic audit on the RSF items derived by the Analyzer. Follow Steps 2–3 from `docs/GREENFIELD.md` exactly. Resolve all findings before continuing.

Additionally resolve any `RES-CONTRADICTS-CODE` and `CODE-INTENT-UNCLEAR` findings. These require human judgement:
- `RES-CONTRADICTS-CODE` — either correct the RES hypothesis (mark as `Refuted` and create a new RSF item reflecting reality) or update the code if it is wrong.
- `CODE-INTENT-UNCLEAR` — clarify intent by examining surrounding context, documentation, or domain knowledge; then either derive an RSF item or mark the code as out of scope.

---

## Step 4 — Ground Environment Items

Run the **Grounder** as described in `docs/GREENFIELD.md` Step 3. This is especially important in re-engineering scenarios, where `E-` items often describe existing infrastructure that must be confirmed before transformation.

---

## Step 5 — Author CDF Files

Define the desired transformations as Change Definition Files (CDFs) in `sdais/cdf/v<N>/`. One file per transformation dimension.

File naming: `<category>-NNNN-<short-description>.md`

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

CDFs are orthogonal and combinable. Multiple active CDFs transform the same codebase in one pass.

### CDF file format

```markdown
# LANG-0001: Java 8 to Go 1.22 Migration

**Category:** lang-
**Status:** Active
**Affects:** all

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

---

## Step 6 — Run the Re-engineering Agent

Run the **Re-engineering** agent (`sdais/prompts/re-engineering.md`), providing the annotated codebase, all active CDF files, and all active RSF items.

The Re-engineering agent:
- Applies each CDF's transformation rules to the units listed in `Affects`.
- Produces transformed code in the target language, framework, or architecture.
- Preserves all `(ANN-ID)` values according to these rules:
  - **One-to-one:** transformed unit carries the original `(ANN-ID)` unchanged.
  - **Split:** when one unit splits into multiple, the original `(ANN-ID)` stays with the unit retaining primary responsibility; new units receive freshly generated IDs.
  - **Merge:** when multiple units merge into one, the merged unit lists all original `(ANN-ID)` values comma-separated.
- Identifies any RSF items not covered by the transformation and hands them off to the Generator with an explicit list.

After the pass the Re-engineering agent outputs:

```
Re-engineering pass complete.
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

If the Re-engineering agent reports uncovered RSF items, run the **Generator** (`sdais/prompts/generator.md`) to synthesise implementations for those items only. The Generator reads the partially-transformed codebase and the uncovered RSF item IDs.

---

## Steps 8 onwards — Standard Loop

From this point, follow the greenfield workflow from Step 6 (Review) onwards:

- **Step 6:** Review — the Reviewer checks all `[ANN]` blocks, including those from the Re-engineering agent and any gaps filled by the Generator.
- **Step 7:** Refine — resolve violations.
- **Step 8:** Human Approval Gate.
- **Optional:** SecurityAuditor, TestGenerator (Standard mode).

The `(ANN-ID)` values established by the Analyzer and preserved by the Re-engineering agent provide a stable audit trail linking every unit in the transformed codebase back to the original annotated unit.
