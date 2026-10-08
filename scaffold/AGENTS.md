# AGENTS — <Project Name>

This project follows the Specification-Driven AI Synthesis (SDAIS) paradigm.
Humans author all requirements; AI agents synthesise, review, and refine all
code.

## Instruction

Before acting on any task in this project, read the prompt file for your role
below and follow it exactly. Each prompt opens with an `@spec` line naming the
sections of `sdais/SDAIS.md` you must read; read those sections, not the whole
document. Do not deviate from the SDAIS workflow.

## Prompt Notation

Prompt files use a compact notation instead of prose. Read it as:

    @X   section marker        ->   then / produces / yields
    !    mandatory             ~    advisory, non-authoritative
    ?    conditional           >    authority ordering (a > b)
    |    alternatives          <x>  placeholder
    nN   numbered rule         #    comment

Text under `@out verbatim:` and inside fenced blocks is literal — emit or write
it exactly as given, substituting only `<placeholders>`.

## Agent Roles

Role — prompt file — when to invoke:

- RequirementsEngineer — `sdais/prompts/requirements-engineer.md` — before RSF authoring; refines loose prose and preserves adopted library references
- TransformationEngineer — `sdais/prompts/transformation-engineer.md` — T: before authoring TRS/CDF; refines transformation prose and preserves adopted library references
- SemanticAuditor — `sdais/prompts/semantic-auditor.md` — before each generation pass; resolves and audits adopted libraries
- Grounder — `sdais/prompts/grounder.md` — after audit Cleared; when E- items exist
- Architect — `sdais/prompts/architect.md` — optional; after Grounder, before Generator; traces adopted libraries
- Generator — `sdais/prompts/generator.md` — after RSF is Cleared; implements RSF plus adopted libraries
- Reviewer — `sdais/prompts/reviewer.md` — after each Generate or Refine pass; verifies library conformance
- Refiner — `sdais/prompts/refiner.md` — after each Review pass with violations; reads the same pinned libraries
- Analyzer — `sdais/prompts/analyzer.md` — T: annotate existing code and carry relevant TRS/CDF library references into RSF
- Transformation — `sdais/prompts/transformation.md` — T: transform annotated code against the composed contract
- SecurityAuditor — `sdais/prompts/security-auditor.md` — on demand or after generation; reads relevant adopted interface contracts
- TestGenerator — `sdais/prompts/test-generator.md` — after all blocks Verified, or before Generator in TDD mode; derives library conformance tests

## SpecificationEngineer Archetype

RequirementsEngineer and TransformationEngineer are both instances of the
SpecificationEngineer archetype: each accepts free-form prose, refines it
through an iterative clarification loop, and produces formal SDAIS artefacts.
RequirementsEngineer produces RSF items (greenfield); TransformationEngineer
produces TRS items and CDF files (transformation).

The clarification loop uses lightweight inline markers (`[[Q1]]`, `[[Q2]]`, …)
at each ambiguous point in the prose, with the full question text and human
answers collected in a `## Questions` section at the end of the same file
(below a `—` separator). Questions accumulate across versions; answered entries
are never deleted.

## Directory Layout

sdais/
├── SDAIS.md
├── prompts/          ← one file per agent role
├── library/          ← project-owned, versioned reusable contracts
│   └── <library-id>/
│       └── v<N>/     ← immutable published version; UTF-8 reference files
├── gspec/            ← loose prose input; versioned by subdirectory
│   └── v1/           ← initial human prose (any filenames, any format)
├── tspec/            ← transformation prose input; versioned by subdirectory
│   └── v1/           ← initial human prose about existing system + desired changes
├── rsf/              ← requirements; one file per item; versioned by subdirectory
│   └── v1/           ← items introduced or amended in version 1
├── adf/              ← UTF-8 Markdown architecture definition files; produced by Architect
│   └── v1/
│       ├── adf-01-context-and-goals.md
│       ├── adf-02-internal-architecture.md
│       ├── adf-03-external-architecture.md
│       ├── adf-04-requirement-trace.md
│       ├── adf-05-glossary.md
│       └── decisions/adr-NNNN-<slug>.md
├── trs/              ← transformation hypotheses; one file per item
│   └── v1/
└── cdf/              ← change definition files; one file per transformation dimension
    └── v1/

<!-- BEGIN: Custom Agents Extension -->
<!-- END: Custom Agents Extension -->
