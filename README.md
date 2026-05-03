# SDAIS — Specification-Driven AI Synthesis

**Version:** v0.8.0 | **Status:** Draft | **License:** BSD 3-Clause

SDAIS is a software development paradigm in which humans author requirements exclusively, and AI agents synthesise, review, and refine all implementation code. No human writes implementation code.

## Core Idea

The human role is that of architect and specifier. The AI role is that of implementer, reviewer, and annotator.

Three load-bearing elements give the paradigm its name:

- **Specification-Driven** — a structured, versioned requirements document is the single upstream artefact and the authoritative source of truth.
- **AI** — one or more AI agents execute the full development lifecycle: generation, annotation, review, refinement, and test authoring.
- **Synthesis** — the output is not a translation of human code but a synthesis from requirements. The AI selects structure, idioms, and implementation strategy within the stated constraints.

## Why SDAIS

Traditional AI-assisted development treats AI as a tool inside a human workflow. SDAIS inverts this: the human retains specification authorship; AI owns the implementation artefact entirely.

Key consequences of this inversion:

- All implicit knowledge must become explicit. Architectural intent, naming rationale, and edge-case handling must be stated in the specification or they do not exist.
- Annotations become the cross-session memory of the AI. Because LLMs are stateless between invocations, structured annotations embedded in generated code are the inter-agent protocol.
- Refinement is a loop, not a one-shot operation. Agents generate, review, and refine in cycles until a review agent finds no violations.
- RSF is always authoritative. When RSF, ADF, and generated code disagree, the RSF wins. No agent may silently reconcile a conflict — disagreements must be surfaced as findings for human resolution.

## Agent Environment

SDAIS is environment-agnostic. Any AI agent system that can read and write files and maintain coherent session context is a valid execution environment. The normative specification (`SDAIS.md`) includes a model-tier table recommending appropriate capability levels per agent role (e.g. high-reasoning models for SemanticAuditor and SecurityAuditor; high-coding models for Generator and Refiner). Pin the model version per agent in your `AGENTS.md` — version drift between rounds can produce inconsistent findings. All agent outputs are authoritative only once written to disk and committed; the `sdais/` directory together with git history is the complete audit trail.

## Greenfield and Re-Engineering

SDAIS covers two entry points:

**Greenfield** — the specification precedes the code. The human authors RSF items, the SemanticAuditor validates them, and the Generator synthesises the implementation from scratch.

**Re-Engineering (SDAIS-RE)** — the existing codebase precedes the specification. The Analyzer agent annotates the existing code, derives RSF items from observed behaviour, and opens RAR findings for anything unclear. The human then authors CDF files defining the desired transformations, and the Re-engineering agent applies them while preserving all annotation identifiers. The result feeds into the standard Reviewer → Refiner → Approval loop.

## Repository Contents

| File / Directory | Purpose |
|---|---|
| `SDAIS.md` | Full normative specification (single source of truth) |
| `SDAIS-INIT.md` | Bootstrap init prompt — self-contained; copy to `sdais/` to initialise a new project |
| `SDAIS-UPDATE.md` | Bootstrap update prompt — copy to `sdais/` when upgrading SDAIS |
| `docs/INTRODUCTION.md` | Concepts, agent roles, annotation reference, upgrade procedure |
| `docs/GREENFIELD.md` | Step-by-step greenfield workflow |
| `docs/RE-ENGINEERING.md` | Step-by-step re-engineering workflow |
| `CHANGELOG.md` | Version history |
| `LICENSE` | BSD 3-Clause License |

## Quickstart — Greenfield

1. Copy the three distribution files into `sdais/` at your project root:
   `SDAIS.md`, `SDAIS-INIT.md`, `SDAIS-UPDATE.md`.
2. Run the **Initialiser** agent using `sdais/SDAIS-INIT.md` as the prompt.
   It creates `AGENTS.md`, all files in `sdais/prompts/`, and all template files.
3. Author your requirements as RSF item files in `sdais/rsf/v1/`.
4. Run the **SemanticAuditor**, then the **Grounder** (if `E-` items exist), then optionally the **Designer**.
5. Run the **Generator**, then iterate through **Review → Refine** cycles until the Reviewer reports zero violations.
6. Approve or amend. Record the approval in the commit message as `Approved: RSF v<N>, Round <R>`.

See `docs/GREENFIELD.md` for the full walkthrough.

To upgrade to a new SDAIS version: replace the three distribution files, then run the **Updater** agent using `sdais/SDAIS-UPDATE.md` as the prompt.

## Quickstart — Re-Engineering

1. Copy the three distribution files into `sdais/` and run the **Initialiser** as above.
2. Author RES hypothesis files in `sdais/res/v1/` capturing what you believe the system does.
3. Run the **Analyzer** against the existing codebase — it annotates the code, derives RSF items, and opens RAR findings.
4. Resolve RAR findings through the standard Semantic Audit Loop.
5. Author one or more CDF files in `sdais/cdf/v1/` defining the target transformations.
6. Run the **Re-engineering** agent — it applies the CDFs and preserves all annotation identifiers.
7. Hand off to the standard **Reviewer → Refiner → Approval** loop.

See `docs/RE-ENGINEERING.md` for the full walkthrough.

## Agent Roles

| Role | When to invoke |
|---|---|
| Initialiser | Once, at project creation |
| Updater | When distribution files are replaced with a new version |
| SemanticAuditor | Before each generation pass |
| Grounder | After audit Cleared; mandatory when `E-` items are present |
| Designer | Optional; after Grounder, before Generator; produces ADF |
| Generator | After RSF is cleared by audit |
| Reviewer | After each Generate or Refine pass |
| Refiner | After each Review pass with violations |
| Analyzer | Re-engineering: annotate existing code and derive RSF |
| Re-engineering | Re-engineering: apply CDF transformations |
| SecurityAuditor | On demand or after generation |
| TestGenerator | Standard: after all blocks Verified; TDD: before Generator |

## License

BSD 3-Clause — see `LICENSE`.
