# SDAIS — Glossary

**Version:** v0.10.0 | Read `sdais/SDAIS.md` for the full normative specification.

---

## Paradigm Acronyms

| Acronym | Full Name | Meaning |
|---|---|---|
| **SDAIS** | Specification-Driven AI Synthesis | The core paradigm: humans author specifications; AI agents synthesise all implementation code. |
| **SDAIS-G** | SDAIS Greenfield | The greenfield workflow variant: specification is written before any code exists. |
| **SDAIS-T** | SDAIS Transformation | The transformation workflow variant: applied to existing codebases. |

---

## Document Sets

| Acronym | Full Name | Location | Purpose |
|---|---|---|---|
| **RSF** | Requirements Specification File | `sdais/rsf/v<N>/` | Normative requirements defining what the system must do or be. |
| **RAR** | *(deprecated)* Requirements Audit Report | — | Previously used for separate finding files; findings are now appended as `## Findings` sections within RSF item files. |
| **TRS** | Transformation Specification | `sdais/trs/v<N>/` | Hypotheses about the behaviour and structure of an existing codebase (SDAIS-T only). |
| **CDF** | Change Definition File | `sdais/cdf/v<N>/` | Specifies a single transformation dimension to apply to an existing codebase (SDAIS-T only). |
| **ADF** | Architecture Definition File | `sdais/adf/v<N>/design.md` | Module decomposition, API surfaces, data flows, and design decisions produced by the Designer. |

---

## RSF Item Types

Items are Markdown files named `<prefix>-NNNN-<description>.md`. Sequence numbers start at `0001` and are never reused. The template file for each type uses `0000`.

| Prefix | Full Name | Purpose |
|---|---|---|
| `fr-NNNN-` | Functional Requirement (FR) | Observable behaviour the system must exhibit. |
| `nfr-NNNN-` | Non-Functional Requirement (NFR) | Measurable quality attribute; must include a numeric bound. |
| `c-NNNN-` | Constraint (C) | Hard rule that narrows the solution space without describing a feature. |
| `e-NNNN-` | Environment (E) | Runtime and deployment facts the system must operate within. |
| `ac-NNNN-` | Acceptance Criterion (AC) | Programmatically verifiable pass condition that confirms one or more FRs are satisfied. |

---

## RAR Finding Types

Findings are Markdown files named `f-NNNN-<description>.md`.

| Category | Meaning |
|---|---|
| `AMBIGUOUS` | Requirement is too vague for deterministic synthesis. |
| `INCOMPLETE` | FR has no AC, or an AC does not reference a corresponding FR. |
| `CONTRADICTORY` | Two RSF items are mutually exclusive. |
| `INFEASIBLE` | A constraint makes one or more FRs impossible to satisfy. |
| `UNTESTABLE` | An acceptance criterion cannot be verified programmatically. |
| `UNQUANTIFIED` | An NFR lacks a measurable numeric bound. |
| `ENV-UNRESOLVABLE` | A named infrastructure element cannot be confirmed in the target environment (Grounder finding). |
| `TRS-CONTRADICTS-CODE` | A TRS hypothesis is contradicted by actual code behaviour (SDAIS-T only). |
| `CODE-INTENT-UNCLEAR` | Code behaviour cannot be mapped to any requirement (SDAIS-T only). |

---

## TRS Item Types (SDAIS-T)

TRS items are hypotheses, not assertions. Files are named `trs-<prefix>-NNNN-<description>.md`.

| Prefix | Full Name | Purpose |
|---|---|---|
| `trs-fr-NNNN-` | Transformation Functional Requirement (TRS-FR) | Hypothesis about a functional behaviour of the existing system. |
| `trs-nfr-NNNN-` | Transformation Non-Functional Requirement (TRS-NFR) | Hypothesis about a quality attribute of the existing system. |
| `trs-c-NNNN-` | Transformation Constraint (TRS-C) | Hypothesis about a constraint observed in the existing system. |

Status values: `Hypothesis | Confirmed | Refuted | Refined`  
Confidence levels: `High | Medium | Low`

---

## CDF Category Prefixes (SDAIS-T)

Each CDF covers exactly one transformation dimension. Multiple CDFs may be applied to the same codebase. Files are named `<category>-NNNN-<description>.md`.

| Prefix | Transformation | Description |
|---|---|---|
| `lang-` | Language Migration | Converting the codebase from one programming language to another. |
| `ui-` | UI Framework Change | Replacing the UI or frontend framework. |
| `i18n-` | Localisation | Adding multi-language support or changing the localisation approach. (`i18n` = internationalisation, 18 letters between *i* and *n*.) |
| `pers-` | Persistence Layer Change | Replacing the database or data-storage technology. |
| `mod-` | Modularisation | Converting between monolith, modules, and services architectures. |
| `plat-` | Platform Change | Changing the deployment platform (bare metal, container, cloud). |
| `api-` | API Style Change | Converting between API paradigms (REST, gRPC, synchronous, asynchronous). |
| `obs-` | Observability Introduction | Adding monitoring, logging, and tracing capabilities. |

---

## Annotation Blocks

`[ANN]` blocks are structured comment blocks embedded in generated source code. They serve as the inter-agent protocol for multi-round synthesis, carrying intent, traceability, and verification state across Generator, Reviewer, Refiner, and other agent passes.

### Core Labels

| Identifier | Format | Scope | Meaning |
|---|---|---|---|
| `(ANN-ID)` | `ANN-<8-hex>` e.g. `ANN-7f3a9c2e` | All units | Stable unique identifier; first label in every block; never changed after creation. |
| `(TASK)` | Text | All units | Declarative statement of what the unit does. |
| `(CONTEXT)` | Text | All units | Where and why this unit is used; inherited from enclosing scope if absent. |
| `(CONSTRAINT)` | Text | All units | Hard rule, invariant, or limit applying to this unit. |
| `(PRE)` | Logical condition | Function/method | Precondition — must hold before execution. |
| `(INPUT)` | `name type — description` | Function/method | Named input parameter with type and description. |
| `(OUTPUT)` | `name type — description` | Function/method | Named output or return value with type and description. |
| `(POST)` | Logical condition | Function/method | Postcondition — must hold after execution. |

### Specialised Constraint Labels

| Identifier | Meaning |
|---|---|
| `(CONSTRAINT:PERF)` | Performance bound (latency, throughput, memory). |
| `(CONSTRAINT:SEC)` | Security classification or access-control rule. |
| `(CONSTRAINT:AVAIL)` | Availability or fault-tolerance expectation. |
| `(CONSTRAINT:CONSIST)` | Data consistency or transactional requirement. |
| `(CONSTRAINT:COMPAT)` | API, platform, or runtime compatibility requirement. |

### Structural Labels

| Identifier | Format | Meaning |
|---|---|---|
| `(DEPENDS-ON)` | Comma-separated `ANN-<8-hex>` IDs | Units this unit directly calls or structurally requires. |
| `(TEST-MODE)` | `TDD` | Set by TestGenerator in TDD mode; absent in standard test annotations. |

### Traceability Labels

| Identifier | Format | Meaning |
|---|---|---|
| `(ORIGIN)` | Comma-separated RSF IDs e.g. `FR-0002, NFR-0001` | RSF item(s) this unit implements. |
| `(AGENT)` | Agent role name | Role of the agent that last wrote or modified this block. |
| `(VERIFIED)` | `true` or `false` | Whether the Reviewer confirmed the block is correct. |
| `(ROUND)` | Integer (0, 1, 2, …) | Review round in which the block was last written or updated. |
| `(CONFIDENCE)` | `Inferred-High/Medium/Low` on ANN blocks; `High/Medium/Low` on TRS items | Set by Analyzer on ANN blocks (SDAIS-T); set by TransformationEngineer on TRS items. |

### Review Finding Labels

| Identifier | Format | Meaning |
|---|---|---|
| `(FINDING:n)` | Text | Describes one specific violation; `n` is a 1-based index. |
| `(SEVERITY:n)` | `Critical`, `High`, `Medium`, or `Low` | Severity of the paired `(FINDING:n)`. |
| `(HINT:n)` | Actionable instruction | Instruction for the Refiner to resolve the paired `(FINDING:n)`. |
| `(FINDING:n:STATUS)` | `Resolved — <rationale>` or `Waived — requires RSF amendment` | Resolution status appended by the Refiner after fixing. |
| `(FIELD-CHANGE:n)` | Text | Documents which descriptive field was changed and why. |

### Agent Role Values for `(AGENT)`

| Value | Role |
|---|---|
| `Generator` | Initial synthesis from RSF. |
| `Reviewer` | Validation pass; sets `(VERIFIED)` and writes finding labels. |
| `Refiner` | Corrects violations directed by `(HINT:n)`; writes `(FINDING:n:STATUS)`. |
| `SecurityAuditor` | Specialised pass for `(CONSTRAINT:SEC)` compliance. |
| `TestGenerator` | Derives tests from `(PRE)`, `(POST)`, and acceptance criteria. |
| `SemanticAuditor` | RSF-level semantic validation before generation. |
| `TransformationEngineer` | Clarification and TRS/CDF derivation from free-form prose in `sdais/tspec/`. |
| `Analyzer` | Transformation: annotates existing codebase and derives RSF items; references TRS item IDs in `(ORIGIN)`. |
| `Transformation` | Applies CDF transformations; preserves all `(ANN-ID)` values. |
| `Designer` | Produces ADF from a cleared RSF. |
| `Grounder` | Verifies infrastructure assumptions in E- items. |
