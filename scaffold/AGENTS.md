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

- RequirementsEngineer — `sdais/prompts/requirements-engineer.md` — before RSF authoring; refines loose prose into RSF
- TransformationEngineer — `sdais/prompts/transformation-engineer.md` — T: before authoring TRS/CDF; refines transformation prose
- SemanticAuditor — `sdais/prompts/semantic-auditor.md` — before each generation pass
- Grounder — `sdais/prompts/grounder.md` — after audit Cleared; when E- items exist
- Architect — `sdais/prompts/architect.md` — optional; after Grounder, before Generator
- Generator — `sdais/prompts/generator.md` — after RSF is Cleared by audit
- Reviewer — `sdais/prompts/reviewer.md` — after each Generate or Refine pass
- Refiner — `sdais/prompts/refiner.md` — after each Review pass with violations
- Analyzer — `sdais/prompts/analyzer.md` — T: annotate existing code
- Transformation — `sdais/prompts/transformation.md` — T: transform annotated code
- SecurityAuditor — `sdais/prompts/security-auditor.md` — on demand or after generation
- TestGenerator — `sdais/prompts/test-generator.md` — after all blocks Verified; or before Generator in TDD mode

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
