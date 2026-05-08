# AGENTS — <Project Name>

This project follows the Specification-Driven AI Synthesis (SDAIS) paradigm.
Humans author all requirements; AI agents synthesise, review, and refine all
code. Read sdais/SDAIS.md for the full workflow specification.

## Agent Roles

| Role            | Prompt file                        | When to invoke                          |
|-----------------|------------------------------------|----------------------------------------|
| SemanticAuditor | sdais/prompts/semantic-auditor.md  | Before each generation pass             |
| Grounder        | sdais/prompts/grounder.md          | After audit Cleared; when E- items exist|
| Designer        | sdais/prompts/designer.md          | Optional; after Grounder, before Generator|
| Generator       | sdais/prompts/generator.md         | After RSF is Cleared by audit           |
| Reviewer        | sdais/prompts/reviewer.md          | After each Generate or Refine pass      |
| Refiner         | sdais/prompts/refiner.md           | After each Review pass with violations  |
| Analyzer        | sdais/prompts/analyzer.md          | Re-engineering: annotate existing code  |
| Re-engineering  | sdais/prompts/re-engineering.md    | Re-engineering: transform annotated code|
| SecurityAuditor | sdais/prompts/security-auditor.md  | On demand or after generation           |
| TestGenerator   | sdais/prompts/test-generator.md    | After all blocks Verified; or before Generator in TDD mode|

## Instruction

Before acting on any task in this project, read the prompt file for your
role from the table above and follow it exactly. Do not deviate from the
SDAIS workflow defined in sdais/SDAIS.md.

## Directory Layout

sdais/
├── SDAIS.md
├── prompts/          ← one file per agent role
├── rsf/              ← requirements; one file per item; versioned by subdirectory
│   └── v1/           ← items introduced or amended in version 1
├── adf/              ← architecture definition files; produced by Designer
│   └── v1/
├── res/              ← re-engineering hypotheses; one file per item
│   └── v1/
├── cdf/              ← change definition files; one file per transformation dimension
│   └── v1/
└── rar/              ← audit findings; one file per finding; versioned by subdirectory
    └── v1/           ← findings from the audit of RSF v1

<!-- BEGIN: Custom Agents Extension -->
<!-- END: Custom Agents Extension -->
