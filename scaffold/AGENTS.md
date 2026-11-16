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

`<placeholder>` marks what an agent fills in. `{{placeholder}}` marks what a
human must supply — values, units, names, texts — in templates, own proposals,
resolutions, and records. Agents never write `{{…}}` except in `prop-own.md`
templates, and treat a remaining `{{…}}` in a human-authored artefact as
incomplete.

## Agent Roles

Role — prompt file — when to invoke:

- RequirementsEngineer — `sdais/prompts/requirements-engineer.md` — before RSF authoring; refines loose prose and preserves adopted library references
- TransformationEngineer — `sdais/prompts/transformation-engineer.md` — T: before authoring TRS/CDF; refines transformation prose, libraries, and target placement
- SemanticAuditor — `sdais/prompts/semantic-auditor.md` — before each generation pass; resolves libraries and managed-root conflicts; writes RSF Solution Proposals per round and applies the one the human accepted
- Grounder — `sdais/prompts/grounder.md` — after audit Cleared; when E- items exist; writes environment Solution Proposals for unconfirmed elements
- Architect — `sdais/prompts/architect.md` — optional; after Grounder, before Generator; traces libraries and implementation locations
- Generator — `sdais/prompts/generator.md` — after RSF is Cleared; implements the composed contract under the active implementation root
- Reviewer — `sdais/prompts/reviewer.md` — after each Generate or Refine pass; verifies contract and root conformance
- Refiner — `sdais/prompts/refiner.md` — after each Review pass with violations; repairs only the active implementation workspace
- Analyzer — `sdais/prompts/analyzer.md` — T: annotate existing code in place and carry relevant TRS/CDF library references into RSF
- Transformation — `sdais/prompts/transformation.md` — T: transform annotated code into the managed target
- SecurityAuditor — `sdais/prompts/security-auditor.md` — on demand or after generation; audits the active implementation workspace
- TestGenerator — `sdais/prompts/test-generator.md` — after all blocks Verified, or before Generator in TDD mode; writes tests under the active implementation root

## SpecificationEngineer Archetype

RequirementsEngineer and TransformationEngineer are both instances of the
SpecificationEngineer archetype: each accepts free-form prose, refines it
through an iterative clarification loop, and produces formal SDAIS artefacts.
RequirementsEngineer produces RSF items (greenfield); TransformationEngineer
produces TRS items and CDF files (transformation).

## Solution Proposals

RequirementsEngineer, TransformationEngineer, SemanticAuditor, Grounder, and
Architect work in rounds under `sdais/props/<domain>/v<R>/`. Each round holds
a `report.md` and, when there are open items, at least two agent-written
proposals (Recommended, Alternative) plus an Own template, all Status=Draft.
Each proposal resolves everything in the round coherently and documents its
compromises. The human accepts exactly one; the next run of the same agent
applies it, or reports an error when zero or several are accepted.
Spec files (gspec, tspec) stay pure prose.

## Directory Layout

<project-root>/
├── AGENTS.md
├── implementation/       ← complete agent-managed product workspace
│   ├── .sdais-root       ← zero-byte managed-root activation marker
│   └── <language-native project tree>
└── sdais/
    ├── SDAIS.md
    ├── prompts/          ← one file per agent role
    ├── library/          ← project-owned, versioned reusable contracts
    │   └── <library-id>/
    │       └── v<N>/     ← immutable published version; UTF-8 reference files
    ├── gspec/            ← loose prose input; versioned by subdirectory
    │   └── v1/           ← initial human prose (any filenames, any format)
    ├── tspec/            ← transformation prose input; versioned by subdirectory
    │   └── v1/           ← prose about existing system + desired changes
    ├── rsf/              ← requirements; one file per item; versioned
    │   └── v1/
    ├── props/            ← Solution Proposals; one dir per agent domain and round
    │   ├── gspec/v<R>/   ← RequirementsEngineer
    │   ├── tspec/v<R>/   ← TransformationEngineer
    │   ├── rsf/v<R>/     ← SemanticAuditor
    │   ├── env/v<R>/     ← Grounder
    │   └── adf/v<R>/     ← Architect
    ├── adf/              ← architecture definition files; one v<R>/ per accepted ADP
    │   ├── v1/           ← round 1 ADF set (all Approved+Accepted)
    │   └── v2/ …        ← round 2+ (previous rounds preserved as history)
    ├── trs/              ← transformation hypotheses
    │   └── v1/
    └── cdf/              ← change definition files
        └── v1/

When `implementation/.sdais-root` exists, all agent-created product files—code,
tests, manifests, lockfiles, assets, migrations, build/deployment files, and
product documentation—stay under `implementation/`. The directory is
project-owned and committed, not disposable generated output. Without the
marker, an upgraded legacy project retains repository-wide in-place behavior.
Do not create the marker or move legacy code implicitly. In managed SDAIS-T,
Analyzer may annotate legacy source outside the root; Transformation writes the
complete target under `implementation/` and leaves the source intact.

<!-- BEGIN: Custom Agents Extension -->
<!-- END: Custom Agents Extension -->
