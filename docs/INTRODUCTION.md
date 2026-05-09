# SDAIS — Introduction

**Version:** v0.9.0 | Read `sdais/SDAIS.md` for the full normative specification.

---

## The Problem Every Long-Lived Project Faces

Picture a system that was well-designed at the start. Good architecture, reasonable test coverage, clear intent. Fast-forward two years. New developers, shifted priorities, a framework upgrade, three rounds of "just this once" shortcuts, and documentation that no one trusts anymore because it stopped matching the code six months ago. Requirements live in Confluence pages, Jira tickets, and the memories of people who have since left. The codebase has become the only reliable source of truth — but reading it requires reverse-engineering decisions that were made in contexts no one remembers.

This is not an unusual situation. It is the normal trajectory of software under continuous change.

What breaks down is not the code itself but the chain of reasoning from *what we need* to *what we built*. Once that chain is broken, every change carries risk. Refactoring is scary. Migrations are expensive. Technical debt compounds because nobody wants to touch the parts they do not understand.

---

## Specification as the Unbroken Chain

SDAIS starts from a different premise: **the specification is the only artefact that humans write and maintain**. Not code. Code is synthesised — by AI, from the specification, every time.

This has one important consequence: the specification can never fall behind the code, because the code is always derived from it. When requirements change, you update the specification and regenerate. The implementation follows. The chain from intent to artefact is never broken because it is enforced structurally.

The specification consists of five types of items:

| Type | Purpose |
|---|---|
| Functional Requirement (FR) | Observable behaviour the system must exhibit |
| Non-Functional Requirement (NFR) | Measurable quality attribute — always includes a numeric bound |
| Constraint (C) | Hard rule narrowing the solution space without describing a feature |
| Environment (E) | Runtime and deployment facts the AI must know |
| Acceptance Criterion (AC) | Programmatically verifiable condition confirming an FR is satisfied |

Each item is a single Markdown file. Together they form the Requirements Specification (RSF) — versioned, git-tracked, and the single upstream artefact for everything that follows.

---

## A Team of Specialists, Not One Generalist

Traditional AI-assisted development treats a single model as a universal assistant: write some code, fix a bug, review a PR. SDAIS takes the opposite approach. Different phases of development demand different cognitive strengths, and different models have different strengths.

The paradigm defines a set of specialist agent roles, each with a focused responsibility and a recommended model tier:

| Prompt | Role | Purpose | Recommended tier |
|---|---|---|---|
| `semantic-auditor.md` | SemanticAuditor | Validates RSF items before generation: detects ambiguity, incompleteness, contradictions, and untestable acceptance criteria | High-reasoning (e.g. Claude Opus) |
| `grounder.md` | Grounder | Verifies that every Environment item describes something that actually exists in your infrastructure | High-reasoning (e.g. Claude Opus or Sonnet) |
| `designer.md` | Designer | Produces a module decomposition, API surface, and design decisions document (ADF) traceable to RSF items | High-reasoning (e.g. Claude Opus or Sonnet) |
| `generator.md` | Generator | Synthesises a complete, annotated implementation from cleared RSF items | High-coding (e.g. Claude Sonnet) |
| `reviewer.md` | Reviewer | Checks every annotation block against the RSF; sets blocks verified or raises findings | High-reasoning or high-coding (e.g. Claude Opus or Sonnet) |
| `refiner.md` | Refiner | Fixes every violation directed by the Reviewer's hints; marks resolved blocks verified | High-coding (e.g. Claude Sonnet) |
| `security-auditor.md` | SecurityAuditor | Specialised pass for security constraints, credential handling, input validation, and authorisation | High-reasoning (e.g. Claude Opus) |
| `test-generator.md` | TestGenerator | Derives test functions from preconditions, postconditions, and acceptance criteria; supports both standard and TDD modes | High-coding (e.g. Claude Sonnet) |
| `analyzer.md` | Analyzer | Re-engineering: annotates an existing codebase and derives RSF items from observed behaviour | High-coding (e.g. Claude Sonnet) |
| `re-engineering.md` | Re-engineering | Re-engineering: applies Change Definition Files to transform the annotated codebase | High-coding (e.g. Claude Sonnet) |

The SemanticAuditor, for example, is primarily a language and logic task — it needs to detect subtle contradictions and vague wording. A model with strong reasoning capabilities does that well. The Generator, on the other hand, needs to produce correct, idiomatic code at scale. That is a different strength. Assigning the right model to each role is not premature optimisation; it is what makes the loop converge reliably.

Pin the model version for each role in your `AGENTS.md`. Version drift between rounds produces inconsistent finding interpretations and slows convergence.

---

## Annotations: The Inter-Agent Memory

LLMs are stateless between invocations. A Reviewer running in round 3 has no memory of what the Generator intended in round 1 — unless that intent is written into the code itself.

SDAIS solves this with `[ANN]` blocks: structured comment blocks embedded in every generated function, method, and type. They carry the declared task, the RSF items being implemented, preconditions, postconditions, dependencies on other units, and the current verification state. When the Reviewer writes a finding, it goes into the same block. When the Refiner fixes it, the resolution goes into the same block.

The annotation block is the inter-agent protocol. It is what allows a Reviewer to understand a Generator's intent without re-reading the RSF from scratch, and what allows a Refiner to target the exact block that needs correction. It is also the audit trail: every block carries the round number and the agent role that last touched it.

This is how SDAIS maintains coherence across multiple agents, multiple rounds, and multiple LLM sessions.

---

## The Development Lifecycle

A full SDAIS project moves through a predictable lifecycle, regardless of the scale of the system:

1. **Specify** — write RSF items expressing what the system must do.
2. **Audit** — the SemanticAuditor validates the specification; you resolve findings.
3. **Ground** — the Grounder confirms infrastructure assumptions; you resolve any unresolvable items.
4. **Design** (optional) — the Designer produces a module decomposition before any code is written.
5. **Generate** — the Generator synthesises the implementation with full annotation coverage.
6. **Review** — the Reviewer checks every block; findings are precise and actionable.
7. **Refine** — the Refiner fixes violations; verified blocks accumulate.
8. **Approve** — you review the result. Approve, amend the RSF and restart, or reject and regenerate.

Steps 6–7 repeat until the Reviewer reports zero violations. Steps 1–5 repeat whenever requirements change. The RSF version increments; the previous version is never modified.

When requirements change — and they always do — you amend the specification, the SemanticAuditor validates the new version, and generation resumes with the existing annotated codebase as context. The annotations carry forward. The chain from intent to implementation remains unbroken.

---

## Two Entry Points

Not every project starts from a blank slate. SDAIS covers both scenarios:

**Greenfield** — the specification is written before any code exists. This is the canonical SDAIS workflow: specify, audit, generate, review, refine, approve. See [GREENFIELD.md](GREENFIELD.md) for the detailed walkthrough.

**Re-Engineering (SDAIS-RE)** — an existing codebase precedes the specification. The Analyzer annotates the existing code, derives RSF items from observed behaviour, and surfaces anything unclear as findings. You then define the desired transformations as Change Definition Files (CDF), and the Re-engineering agent applies them while preserving all annotation identifiers. From there the standard review loop takes over. See [RE-ENGINEERING.md](RE-ENGINEERING.md) for the detailed walkthrough.

---

## Further Reading

- [GREENFIELD.md](GREENFIELD.md) — Step-by-step greenfield workflow, prompt-by-prompt, with process diagram.
- [RE-ENGINEERING.md](RE-ENGINEERING.md) — Step-by-step re-engineering workflow with process diagram.
- [GLOSSARY.md](GLOSSARY.md) — All acronyms, document types, and annotation block identifiers.
- `sdais/SDAIS.md` — The full normative specification.
