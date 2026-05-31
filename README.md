# SDAIS — Specification-Driven AI Synthesis

**Version:** v0.10.0 | **Status:** Draft | **License:** BSD 3-Clause

SDAIS is a software development paradigm in which humans author requirements exclusively and AI agents synthesise, review, and refine all implementation code. No human writes implementation code. The specification is the single source of truth — always.

Read [docs/INTRODUCTION.md](docs/INTRODUCTION.md) for the full concept and motivation. For step-by-step workflows see [docs/GREENFIELD.md](docs/GREENFIELD.md) and [docs/TRANSFORMATION.md](docs/TRANSFORMATION.md). Terms and acronyms are defined in [docs/GLOSSARY.md](docs/GLOSSARY.md).

---

## Installation

Create a directory for your project and copy the SDAIS distribution files into it:

```
mkdir my-project && cd my-project
cp /path/to/sdais-dist/{SDAIS.md,install,update,sdais,sdais-vX.Y.Z.tgz} .
```

`install` and `update` must be run from this project root — the directory that contains `SDAIS.md`, `install`, and `update`. Do not run them from inside the SDAIS distribution repository.

Run the installer:

```
./install <project-name>
```

`install` creates `AGENTS.md`, the full `sdais/` scaffold with all prompt files and templates, and installs the `sdais` launcher into `~/.local/bin/sdais` so it is available as a global command. If `~/.local/bin` is not in your `PATH`, the script will tell you.

`SDAIS.md` in the project root is the distribution file. `install` copies it into `sdais/SDAIS.md` — the project-local copy that agents read. These are intentionally two separate files at different paths: when you upgrade, you replace the root-level `SDAIS.md` and run `./update`, which refreshes `sdais/SDAIS.md` without touching any project content.

To upgrade an existing project to a new SDAIS version, replace the distribution files and run:

```
./update --from <old-version>
```

---

## Running Agents

The `sdais` command launches any agent role against a model of your choice. It is installed globally by `./install` and must be run from the project root (the directory that contains `sdais/prompts/`):

```
sdais <tool> <model> <role>
```

| Argument | Values | Example |
|---|---|---|
| `tool` | `claude`, `ollama` | `claude` |
| `model` | Any model ID supported by the tool | `claude-opus-4-5` |
| `role` | CamelCase or kebab-case role name | `RequirementsEngineer` or `requirements-engineer` |

Examples:

```
sdais claude claude-opus-4-5  RequirementsEngineer
sdais claude claude-sonnet-4-5 Generator
sdais claude claude-opus-4-5  SemanticAuditor
sdais ollama gemma4            Reviewer
```

Pin the model per role in your `AGENTS.md` to prevent version drift between rounds.

---

## The Human Loop — SDAIS-G (Greenfield)

You write specifications. AI writes code. The loop looks like this:

**Phase 0 — Draft (optional)**

If you find it easier to start with free-form prose, write your ideas into `sdais/gspec/v1/` (any filename, any format) and run the **RequirementsEngineer**. It will ask clarifying questions via `[[QN]]` markers; you answer each with `[[AN answer]]`. The loop repeats until the spec is clean, then the agent generates `sdais/rsf/v1/` for you with a `**Source:**` traceability field on every item. Skip this phase if you prefer to author RSF items directly.

**Phase 1 — Specify**

1. Author or review requirement files (FR, NFR, C, E, AC) in `sdais/rsf/v1/` using the installed templates.
2. Run the **SemanticAuditor** — it reads your requirements and writes findings for anything ambiguous, incomplete, or contradictory.
3. Resolve each finding: fix the requirement in place, drop it, split it, or waive the finding with a rationale.
4. If you have environment items (`E-`), run the **Grounder** to verify they exist in your infrastructure.
5. Optionally run the **Designer** to produce a module decomposition and API surface document before any code is written.

Repeat phases 1–5 until all findings are resolved. That cleared RSF is your contract with the AI.

**Phase 2 — Synthesise**

6. Run the **Generator** — it reads the cleared RSF and synthesises a complete, annotated implementation.
7. Run the **Reviewer** — it checks every annotated code unit against the RSF and writes findings for any violations.
8. Run the **Refiner** — it fixes every violation guided by the Reviewer's hints.
9. Return to step 7. Repeat until the Reviewer reports zero violations.

**Phase 3 — Approve**

10. Review the result. Approve, amend the RSF and restart, or reject and regenerate.
11. Optionally run the **SecurityAuditor** and **TestGenerator** at any point after generation.

---

## The Human Loop — SDAIS-T (Transformation)

You have an existing codebase. You want to migrate it, modularise it, or bring it under formal specification.

**Phase 0 — Draft (optional)**

If you find it easier to start with free-form prose, write your ideas about the existing system and desired changes into `sdais/tspec/v1/` and run the **TransformationEngineer**. It will ask clarifying questions via `[[QN]]` markers; you answer each with `[[AN answer]]`. The loop repeats until the spec is clean, then the agent generates TRS items in `sdais/trs/v1/` and draft CDF files in `sdais/cdf/v1/`. Skip this phase if you prefer to author TRS items and CDF files directly.

1. Write hypothesis files (TRS) capturing what you believe the system does.
2. Run the **Analyzer** — it reads the codebase, adds annotation blocks to every unit, derives formal RSF items from observed behaviour, and opens findings for anything unclear.
3. Resolve findings and refine the derived RSF through the standard semantic audit loop.
4. Activate one or more Change Definition Files (CDF) describing the transformation you want (language migration, modularisation, new persistence layer, etc.).
5. Run the **Transformation** agent — it applies the CDFs to the annotated codebase while preserving all annotation identifiers.
6. Continue from step 7 of the greenfield loop above (Review → Refine → Approve).

---

## Repository Contents

| File / Directory | Purpose |
|---|---|
| `SDAIS.md` | Full normative specification — single source of truth |
| `install` | Scaffolds a new project |
| `update` | Upgrades an existing project's scaffold |
| `sdais` | Launcher — runs any agent role with a chosen tool and model |
| `scaffold/` | Prompt files and templates installed by `install` |
| `docs/INTRODUCTION.md` | Concepts, motivation, agent roles, and prompt reference |
| `docs/GREENFIELD.md` | Detailed greenfield workflow with process diagram |
| `docs/TRANSFORMATION.md` | Detailed transformation workflow with process diagram |
| `docs/GLOSSARY.md` | All acronyms, document types, and annotation identifiers |
| `CHANGELOG.md` | Version history |
| `LICENSE` | BSD 3-Clause License |

---

## License

BSD 3-Clause — see `LICENSE`.
