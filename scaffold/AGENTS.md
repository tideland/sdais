# AGENTS — <Project Name>

This project follows the Specification-Driven AI Synthesis (SDAIS) paradigm.
Humans author all requirements; AI agents synthesise, review, and refine all
code. Read sdais/SDAIS.md for the full workflow specification.

## Agent Roles

| Role                      | Prompt file                                   | When to invoke                                         |
|---------------------------|-----------------------------------------------|--------------------------------------------------------|
| RequirementsEngineer      | sdais/prompts/requirements-engineer.md        | Before RSF authoring; refines loose prose into RSF     |
| TransformationEngineer    | sdais/prompts/transformation-engineer.md      | T: before authoring TRS/CDF; refines transformation prose |
| SemanticAuditor           | sdais/prompts/semantic-auditor.md             | Before each generation pass                            |
| Grounder                  | sdais/prompts/grounder.md                     | After audit Cleared; when E- items exist               |
| Designer                  | sdais/prompts/designer.md                     | Optional; after Grounder, before Generator             |
| Generator                 | sdais/prompts/generator.md                    | After RSF is Cleared by audit                          |
| Reviewer                  | sdais/prompts/reviewer.md                     | After each Generate or Refine pass                     |
| Refiner                   | sdais/prompts/refiner.md                      | After each Review pass with violations                 |
| Analyzer                  | sdais/prompts/analyzer.md                     | Transformation: annotate existing code                 |
| Transformation            | sdais/prompts/transformation.md               | Transformation: transform annotated code               |
| SecurityAuditor           | sdais/prompts/security-auditor.md             | On demand or after generation                          |
| TestGenerator             | sdais/prompts/test-generator.md               | After all blocks Verified; or before Generator in TDD mode |

## Instruction

Before acting on any task in this project, read the prompt file for your
role from the table above and follow it exactly. Do not deviate from the
SDAIS workflow defined in sdais/SDAIS.md.

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
├── gspec/             ← loose prose input; versioned by subdirectory
│   └── v1/           ← initial human prose (any filenames, any format)
├── tspec/            ← transformation prose input; versioned by subdirectory
│   └── v1/           ← initial human prose about existing system + desired changes
├── rsf/              ← requirements; one file per item; versioned by subdirectory
│   └── v1/           ← items introduced or amended in version 1
├── adf/              ← architecture definition files; produced by Designer
│   └── v1/
├── trs/              ← transformation hypotheses; one file per item
│   └── v1/
└── cdf/              ← change definition files; one file per transformation dimension
    └── v1/

<!-- BEGIN: Custom Agents Extension -->
<!-- END: Custom Agents Extension -->
