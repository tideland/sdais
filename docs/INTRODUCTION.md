# SDAIS — Introduction

**Version:** v0.8.0 | Read `sdais/SDAIS.md` for the full normative specification.

---

## What SDAIS Is

Specification-Driven AI Synthesis (SDAIS) is a software development paradigm in which humans author requirements exclusively and AI agents synthesise, review, and refine all implementation code. No human writes implementation code.

The human role is that of architect and specifier. The AI role is that of implementer, reviewer, and annotator.

---

## Core Concepts

### Requirements Specification (RSF)

Every requirement is one Markdown file in `sdais/rsf/v<N>/`. Five item types:

| Prefix | Type | Purpose |
|---|---|---|
| `fr-NNNN-` | Functional Requirement | Observable behaviour the system must exhibit |
| `nfr-NNNN-` | Non-Functional Requirement | Measurable quality attribute (always quantified) |
| `c-NNNN-` | Constraint | Hard rule narrowing the solution space |
| `e-NNNN-` | Environment | Runtime and deployment facts |
| `ac-NNNN-` | Acceptance Criterion | Programmatically verifiable pass condition |

Sequence numbers start at `0001` and are never reused. Numbers are local to each type prefix.

### Annotation Blocks `[ANN]`

Every generated function, method, and type carries a structured `[ANN]` comment block. Annotations are the inter-agent protocol — the only mechanism by which a subsequent agent understands what a prior agent intended.

**Core labels:**

| Label | Required | Description |
|---|---|---|
| `(ANN-ID)` | yes | Stable unique identifier; format `ANN-<8-hex>`; never changes |
| `(ORIGIN)` | yes | RSF item IDs this unit implements |
| `(TASK)` | yes | Declarative statement of what this unit does |
| `(CONTEXT)` | no | Where and why this unit is used |
| `(CONSTRAINT)` | no | Hard rules, invariants, limits |
| `(PRE)` | no | Preconditions (functions/methods) |
| `(INPUT)` | no | Named inputs with types |
| `(OUTPUT)` | no | Named outputs with types |
| `(POST)` | no | Postconditions (functions/methods) |
| `(DEPENDS-ON)` | no | `ANN-<8-hex>` IDs of units this unit directly calls |
| `(AGENT)` | yes | Agent role that last modified this block |
| `(VERIFIED)` | yes | `true` — reviewed and clean; `false` — pending or violation |
| `(ROUND)` | yes | Review-round number when this block was last written or updated |

**Finding labels** (written by Reviewer into blocks where `(VERIFIED) false`):

| Label | Written by | Description |
|---|---|---|
| `(FINDING:n)` | Reviewer | Describes one specific violation |
| `(SEVERITY:n)` | Reviewer | `Critical / High / Medium / Low` |
| `(HINT:n)` | Reviewer | Actionable instruction for the Refiner |
| `(FINDING:n:STATUS)` | Refiner | `Resolved — <rationale>` or `Waived — requires RSF amendment` |
| `(FIELD-CHANGE:n)` | Refiner | Documents a descriptive field updated due to a code fix |

Finding indices are 1-based, local to the block, and never reused across rounds.

### Agent Roles

| Role | When to invoke |
|---|---|
| SemanticAuditor | Before each generation pass |
| Grounder | After audit Cleared; mandatory when `E-` items are present |
| Designer | Optional; after Grounder, before Generator; produces ADF |
| Generator | After RSF is Cleared by audit (and Grounder + Designer if applicable) |
| Reviewer | After each Generate or Refine pass |
| Refiner | After each Review pass with violations |
| SecurityAuditor | On demand or after generation |
| TestGenerator | Standard: after all blocks Verified; TDD: before Generator |
| Analyzer | Re-engineering: annotate existing code and derive RSF |
| Re-engineering | Re-engineering: apply CDF transformations |

### Two Entry Points

**Greenfield** — specification precedes code. See `docs/GREENFIELD.md`.

**Re-Engineering** — existing code precedes specification. See `docs/RE-ENGINEERING.md`.

---

## Prerequisites

- An AI agent environment capable of reading files and writing code (Claude Code, Cursor, Aider, or a similar tool).
- A git repository for your project.
- Familiarity with writing requirements in plain prose.

---

## Distribution Files

The SDAIS distribution set consists of:

| File | Purpose |
|---|---|
| `SDAIS.md` | Full normative specification |
| `install.sh` | Scaffolds a new project; run once at project creation |
| `update.sh` | Upgrades an existing project's scaffold to the current version |
| `sdais-vX.Y.Z.tgz` | Prompt files and templates (or `scaffold/` directory from the repo) |

Run `bash install.sh <project-name>` from the project root to create `AGENTS.md` and the full `sdais/` scaffold in one step.

---

## Upgrading

1. Replace `SDAIS.md`, `install.sh`, `update.sh`, and the tgz (or `scaffold/` directory) with the new release.
2. Run `bash update.sh --from <old-version>` from the project root.

`update.sh` refreshes `AGENTS.md` (preserving the Custom Agents Extension block), all files in `sdais/prompts/`, all `*-0000-template.md` files, and `sdais/SDAIS.md`. It does not touch RSF items, RAR findings, RES files, CDF files, ADF files, or source code.

---

## RAR Finding Categories

| Category | Applies to | Meaning |
|---|---|---|
| `AMBIGUOUS` | All workflows | Requirement too vague for deterministic synthesis |
| `INCOMPLETE` | All workflows | FR has no AC, or AC does not verify its FR |
| `CONTRADICTORY` | All workflows | Two items are mutually exclusive |
| `INFEASIBLE` | All workflows | A constraint makes one or more FRs impossible |
| `UNTESTABLE` | All workflows | An AC cannot be verified programmatically |
| `UNQUANTIFIED` | All workflows | An NFR lacks a measurable bound |
| `ENV-UNRESOLVABLE` | All workflows | A named infrastructure element cannot be confirmed |
| `RES-CONTRADICTS-CODE` | SDAIS-RE | A RES hypothesis is contradicted by the code |
| `CODE-INTENT-UNCLEAR` | SDAIS-RE | Code behaviour cannot be mapped to a requirement |
