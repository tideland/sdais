# SDAIS — Greenfield Workflow

**Version:** v0.8.0 | See `docs/INTRODUCTION.md` for concepts and prerequisites.

The greenfield workflow applies when you are building a new system from a clean slate. The specification precedes the code.

---

## Step −1 — Install the Scaffold

Copy the SDAIS distribution files into your project root (`SDAIS.md`, `install.sh`, `update.sh`, and either `sdais-vX.Y.Z.tgz` or the `scaffold/` directory), then run:

```
bash install.sh <project-name>
```

After install, your tree looks like:

```
<project-root>/
├── AGENTS.md
└── sdais/
    ├── SDAIS.md
    ├── prompts/
    │   ├── semantic-auditor.md
    │   ├── grounder.md
    │   ├── designer.md
    │   ├── generator.md
    │   ├── reviewer.md
    │   ├── refiner.md
    │   ├── analyzer.md
    │   ├── re-engineering.md
    │   ├── security-auditor.md
    │   └── test-generator.md
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

Do not edit `AGENTS.md` or any file in `sdais/prompts/` by hand — run `update.sh` to refresh them when upgrading SDAIS.

---

## Step 1 — Author Your Requirements (RSF)

Copy the relevant template, rename it with the next available sequence number and a short description, then replace every bracketed placeholder with real content.

### File naming

| Template | Example |
|---|---|
| `fr-0000-template.md` | `fr-0001-authenticate-requests.md` |
| `nfr-0000-template.md` | `nfr-0001-response-latency.md` |
| `c-0000-template.md` | `c-0001-go-version.md` |
| `e-0000-template.md` | `e-0001-database-connection.md` |
| `ac-0000-template.md` | `ac-0001-valid-key-accepted.md` |

Sequence numbers start at `0001` and are never reused. Items retired by audit carry status tags and remain in the file as tombstones.

### Writing good requirements

**Functional Requirements (FR):** Begin with "The system must" or "The \<component\> must". Describe observable behaviour, not implementation detail. Every FR must have at least one corresponding AC.

**Non-Functional Requirements (NFR):** Always include a numeric bound. "Low latency" is not a requirement. "95th-percentile latency must not exceed 200 ms under 1 000 concurrent requests" is.

**Constraints (C):** Hard rules that narrow the solution space without describing a feature. "The implementation must use Go 1.22 or later." To activate TDD mode, add `C-NNNN: Generation mode: TDD`.

**Environment (E):** Runtime or deployment facts the AI must know. Set `**Verified:** Pending` on every E- item at authoring; the Grounder sets it to `true` after confirming the element exists.

**Acceptance Criteria (AC):** Programmatically verifiable conditions. Specify inputs, expected outputs, and observable side-effects. Every FR must be covered by at least one AC.

### Cross-references

Use `[FR-NNNN]`, `[NFR-NNNN]`, `[AC-NNNN]`, etc. inline in the `## Requirement` section. References resolve to the most recent active version of the item.

---

## Step 2 — Semantic Audit

Before any code is generated, the RSF must pass a semantic audit.

1. Run the **SemanticAuditor** agent (`sdais/prompts/semantic-auditor.md`), providing all RSF item files for the current version.
2. The agent writes one finding file per problem into `sdais/rar/v<N>/`.
3. For each finding, choose exactly one resolution action and update the finding file's `Resolution` and `Status` fields:

| Action | When to use | RSF item change |
|---|---|---|
| **Fix in place** | Item kept; wording corrected or quantified | Rewrite item text; append `[FIXED-RAR-V<N>-F<nn>]` to Audit History |
| **Drop** | Item irrecoverably ambiguous or no longer needed | Append `[DROPPED-RAR-V<N>-F<nn> — <reason>]` to Audit History |
| **Supersede** | Replace with a cleaner formulation under a new ID | Append `[SUPERSEDED→<new-ID>-RAR-V<N>-F<nn>]`; create new item file |
| **Split** | One item covered two distinct concerns | Append `[SPLIT→<ID-a>,<ID-b>-RAR-V<N>-F<nn>]`; create both new files |
| **Waive** | Finding acknowledged; item intentionally unchanged | RSF unchanged; record rationale in the finding file |

4. The SemanticAuditor has already staged copies of affected items in `sdais/rsf/v<N+1>/`. Amend the pre-staged copies (Fix/Drop/Supersede/Split) or delete them (Waive). Re-audit if any findings remain `Open`. Repeat until all findings are `Resolved` or `Waived`.

---

## Step 3 — Ground Environment Items (mandatory if E- items exist)

Run the **Grounder** agent (`sdais/prompts/grounder.md`) after the audit is Cleared.

The Grounder verifies each `E-` item against real infrastructure — checking database connections, service endpoints, environment variables, file paths, etc. For each confirmed element it sets `**Verified:** true`. For each element it cannot confirm it opens an `ENV-UNRESOLVABLE` RAR finding.

Resolve all `ENV-UNRESOLVABLE` findings before proceeding. Resolution options:
- **Fix in place:** update the `E-` item to match what exists; re-run Grounder.
- **Drop:** remove the `E-` item and any FR items that depend on it.
- **Waive:** append `[WAIVED-RAR-V<N>-F<nn> — to be created by this project]` if the element will be built as part of this project.

---

## Step 4 — Design (optional)

Run the **Designer** agent (`sdais/prompts/designer.md`) if you want a human-approved architecture checkpoint before any code is written.

The Designer reads all cleared RSF items and produces `sdais/adf/v<N>/design.md` covering:
- Module decomposition (name, responsibility, RSF item IDs addressed)
- API surfaces (signatures and contracts, not implementations)
- Data flows between modules
- Design decisions traceable to RSF item IDs

Review the ADF:
- **Approve** — set `**Status:** Approved` in the file; Generator will read it as structural context.
- **Reject** — provide written feedback; the Designer revises.

The ADF is advisory. RSF items remain authoritative if the ADF and RSF conflict.

---

## Step 5 — Generate

### Standard mode

Run the **Generator** agent (`sdais/prompts/generator.md`).

The Generator:
- Reads all active RSF items.
- Reads `sdais/adf/v<N>/design.md` as structural context if present and Approved.
- Synthesises a complete implementation.
- Writes one `[ANN]` block per callable unit and type, with `(ANN-ID)`, `(VERIFIED) false`, `(ROUND) 0`, and `(DEPENDS-ON)` where dependencies exist.

Do not edit generated code by hand.

### TDD mode

If the RSF contains a `C-` item with `Generation mode: TDD`:

1. Run **TestGenerator** in TDD mode first (`sdais/prompts/test-generator.md`, specify "TDD"). It writes test stubs with failing assertions. Every test block gets `(TEST-MODE) TDD`.
2. Run the **Generator** targeting 100% pass rate on those tests.

---

## Step 6 — Review

Run the **Reviewer** agent (`sdais/prompts/reviewer.md`). Pass the current round number (1 after the first Generate pass).

The Reviewer:
- Checks every `[ANN]` block: `(ORIGIN)` validity, `(TASK)` accuracy, `(PRE)`/`(POST)` enforcement, `(CONSTRAINT)` respect, FR and AC coverage.
- Runs a dependency cascade check: when a block is set `(VERIFIED) false`, all blocks whose `(DEPENDS-ON)` references that block's `(ANN-ID)` receive a Medium cascade finding.
- Sets `(VERIFIED) true` on clean blocks.

After the pass the Reviewer outputs:

```
Round 1 review complete.
Violations: 3 blocks, 5 total findings.
Cascade findings added: 2 blocks.
Clean: 12 blocks.
Unaddressed RSF items (if any): AC-0003
```

---

## Step 7 — Refine (if violations exist)

Run the **Refiner** agent (`sdais/prompts/refiner.md`) with the same round number.

The Refiner:
- Corrects each violation as directed by `(HINT:n)`.
- Appends `(FINDING:n:STATUS) Resolved — <rationale>` for each fix.
- If a descriptive annotation field becomes incorrect after a code fix, updates the field and appends `(FIELD-CHANGE:n)` documenting the change.
- Marks `(VERIFIED) true` when all findings in a block are resolved.
- Marks unresolvable findings `Waived — requires RSF amendment`.

Return to Step 6 at round N+1. Repeat until the Reviewer reports zero violations.

If remaining violations are all `Waived`, amend the RSF (new version), re-audit from Step 2, and restart generation.

---

## Step 8 — Human Approval Gate

When the Reviewer reports zero violations and all ACs pass:

- **Approve** — synthesis complete. Archive RSF files and annotated codebase together.
- **Amend RSF** — increment RSF version, restart loop from Step 2 with the existing codebase as context.
- **Reject** — provide written rationale; restart from Step 5.

---

## Optional Passes

### Security Audit

Run the **SecurityAuditor** agent (`sdais/prompts/security-auditor.md`) on demand or after generation. It checks `(CONSTRAINT:SEC)` labels and scans for hard-coded credentials, unvalidated inputs passed to sensitive operations, and missing authorisation checks. It uses the same `(FINDING:n)` / `(HINT:n)` mechanism as the Reviewer; findings are prefixed `SEC:`.

### Test Generation (Standard Mode)

After all `[ANN]` blocks are `(VERIFIED) true`, run the **TestGenerator** agent in Standard mode (`sdais/prompts/test-generator.md`, specify "Standard"). It derives test functions from `(PRE)`, `(POST)`, and AC items. It reads `[ANN]` blocks in implementation files but does not modify them.
