# SDAIS — Specification-Driven AI Synthesis

**Version:** v0.14.0 | **Status:** Final | **License:** BSD 3-Clause

SDAIS is a software development paradigm in which humans author requirements and adopted reference contracts while AI agents synthesise, review, and refine all implementation code. No human writes implementation code. Human-authored RSF determines intent and adoption scope; pinned libraries supply the adopted contract details.

Read [docs/INTRODUCTION.md](docs/INTRODUCTION.md) for the full concept and motivation. For step-by-step workflows see [docs/GREENFIELD.md](docs/GREENFIELD.md) and [docs/TRANSFORMATION.md](docs/TRANSFORMATION.md). Terms and acronyms are defined in [docs/GLOSSARY.md](docs/GLOSSARY.md).

---

## Installation

Create a directory for your project, copy or download the distribution archive
into it, unpack the archive, and run the installer:

```sh
mkdir my-project
cd my-project
cp /path/to/sdais-v0.14.0.tgz .
tar xzf sdais-v0.14.0.tgz
./install.sh "My Project"
```

The archive expands directly into the current directory; it does not create an
extra version-named directory. You can replace the `cp` command with a download
command that saves the archive as `sdais-v0.14.0.tgz`.

`install.sh` and `update.sh` must be run from this project root — the directory
that contains `SDAIS.md`, `install.sh`, `update.sh`, and `scaffold/`. Do not run
them from inside the SDAIS distribution repository.

The installer argument is a human-readable label substituted into `AGENTS.md`
— it does not have to match your directory name.

`install.sh` creates `AGENTS.md`, the full `sdais/` scaffold, and the managed
`implementation/` workspace. The repository-local launcher is `./sdais.sh`.
The installer also places a convenience copy in `~/.local/bin/sdais`; the
canonical invocation used by SDAIS documentation remains `./sdais.sh` from the
project root.

`SDAIS.md` in the project root is the distribution file. `install.sh` copies it into `sdais/SDAIS.md` — the project-local copy that agents read. These are intentionally two separate files at different paths: when you upgrade, you replace the root-level `SDAIS.md` and run `./update.sh`, which refreshes `sdais/SDAIS.md` without touching any project content.

To upgrade an existing project, copy or download the new archive into the
project root, unpack it there, and run:

```sh
tar xzf sdais-v0.14.0.tgz
./update.sh --from v0.13.0
```

Unpacking replaces only distribution files and the bundled `scaffold/` tree.
`update.sh` then refreshes managed project files while preserving project
content as documented below.

## Versioned Reference Libraries

Place reusable human-authored contracts under
`sdais/library/<library-id>/v<N>/`. Requirements adopt them explicitly with an
exact file path, for example:

```markdown
The puzzle UI must follow `sdais/library/tds/v1/tds.md`.
```

The generated or human-authored RSF item carries the same contract separately
from its prose provenance:

```markdown
- **Source:** sdais/gspec/v2/ui.md
- **Libraries:** sdais/library/tds/v1/tds.md
```

The mechanism is generic: an API requirement can instead adopt
`sdais/library/example-api/v2/openapi.yaml#paths`. Libraries are normative only
where human prose or RSF explicitly adopts them. The SemanticAuditor resolves
and checks them; Architect traces them; Generator and Transformation implement
them; Reviewer verifies conformance; Refiner and TestGenerator use the same
pinned files. To amend a published contract, add `v<N+1>` and update only the
requirements that adopt it—old requirements keep using their pinned version.
Update preserves every file under `sdais/library/`.

---

## Managed Implementation Root

Fresh projects keep every agent-managed product artefact under
`implementation/`. The zero-byte marker `implementation/.sdais-root` activates
this contract:

```text
implementation/
├── .sdais-root
├── go.mod
├── cmd/
├── internal/
└── tests/
```

The same rule applies to other languages and to source, tests, package
manifests, lockfiles, fixtures, assets, migrations, build/deployment files, and
product documentation. These files are committed project content.
`generated/` is intentionally not used because the reviewed implementation is
not disposable build output.

Update does not create the marker or move code in an existing unmarked project;
that project keeps the legacy in-place behavior. To opt in, move the complete
implementation workspace into `implementation/`, then create the zero-byte
marker last. In SDAIS-T, legacy source may remain outside the root: Analyzer
annotates it in place, Transformation writes the complete target under
`implementation/`, and downstream agents operate only on that target.

---

## Running Agents

The `./sdais.sh` script launches any agent role against a model of your choice. Run it from the project root—the directory containing `sdais/prompts/`:

```
./sdais.sh                           # interactive menu
./sdais.sh <tool> <model> <role>     # direct launch
```

### Interactive menu

Run `./sdais.sh` without arguments to print every role in workflow order
together with the recommended model for each tool. Each cell carries a menu
code: `C` for Claude, `X` for Codex, `G` for Gemini, and `O` for Ollama,
followed by the role number `01`–`12`. Enter a code at the prompt (for example
`C01` for the Claude RequirementsEngineer, case-insensitive) to launch that
combination, or `q` to quit.

```
Role                    Claude                Codex                 Gemini                Ollama
RequirementsEngineer    C01 claude-opus-5-5   X01 gpt-6.1-sol       G01 gemini-4-argon    O01 gpt-oss:20b
...
Grounder                C05 claude-sonnet-5-5 X05 gpt-6-luna        G05 gemini-3.8-flash  O05 qwen3-coder:30b
...
Next step — enter a menu code (e.g. C01, q to quit):
```

Reasoning-heavy roles (RequirementsEngineer, TransformationEngineer,
SemanticAuditor, Architect, Reviewer, SecurityAuditor) use each tool's
high-reasoning model; synthesis roles (Grounder, Analyzer, Generator, Refiner,
Transformation, TestGenerator) use its high-coding model:

| Tool | Reasoning model | Coding model | Override variables |
|---|---|---|---|
| Claude | `claude-opus-5-5` | `claude-sonnet-5-5` | `SDAIS_CLAUDE_REASONING`, `SDAIS_CLAUDE_CODING` |
| Codex | `gpt-6.1-sol` | `gpt-6-luna` | `SDAIS_CODEX_REASONING`, `SDAIS_CODEX_CODING` |
| Gemini | `gemini-4-argon` | `gemini-3.8-flash` | `SDAIS_GEMINI_REASONING`, `SDAIS_GEMINI_CODING` |
| Ollama | `gpt-oss:20b` | `qwen3-coder:30b` | `SDAIS_OLLAMA_REASONING`, `SDAIS_OLLAMA_CODING` |

The defaults reflect the state of November 2026. Set the override variables to
pin the models your project uses, for example
`SDAIS_GEMINI_REASONING=gemini-3.1-pro-preview ./sdais.sh` if your Gemini CLI
does not yet accept `gemini-4-argon`. Choose Ollama models that fit your
hardware.

### Direct launch

| Argument | Values | Example |
|---|---|---|
| `tool` | `claude`, `ollama`, `codex`, `gemini` | `claude` |
| `model` | Any model ID supported by the tool | `claude-opus-5-5` |
| `role` | CamelCase or kebab-case role name | `RequirementsEngineer` or `requirements-engineer` |

Examples:

```
./sdais.sh claude  claude-opus-5-5    RequirementsEngineer
./sdais.sh claude  claude-sonnet-5-5  Generator
./sdais.sh claude  claude-opus-5-5    SemanticAuditor
./sdais.sh ollama  qwen3-coder:30b    Generator
./sdais.sh codex   gpt-6.1-sol        Reviewer
./sdais.sh gemini  gemini-3.8-flash   Generator
```

`./sdais.sh --help` prints the usage summary.

Pin the model per role in your `AGENTS.md` to prevent version drift between rounds.

---

## The Human Loop — SDAIS-G (Greenfield)

You write specifications. AI writes code. The loop looks like this:

**Phase 0 — Draft (optional)**

If you find it easier to start with free-form prose, write your ideas into `sdais/gspec/v1/` (any filename, any format) and run the **RequirementsEngineer**. It will ask clarifying questions via `[[QN]]` markers; you answer each with `[[AN answer]]`. The loop repeats until the spec is clean, then the agent generates `sdais/rsf/v1/` for you with a `**Source:**` traceability field and the smallest applicable `**Libraries:**` set on every adopting item. Skip this phase if you prefer to author RSF items directly.

**Phase 1 — Specify**

1. Author or review requirement files (FR, NFR, C, E, AC) in `sdais/rsf/v1/` using the installed templates.
2. Run the **SemanticAuditor** — it reads your requirements and writes findings for anything ambiguous, incomplete, or contradictory.
3. Resolve each finding: fix the requirement in place, drop it, split it, or waive the finding with a rationale.
4. If you have environment items (`E-`), run the **Grounder** to verify they exist in your infrastructure.
5. Optionally run the **Architect** to produce the architecture document set and ADRs before any code is written.

Repeat phases 1–5 until all findings are resolved. That cleared RSF is your contract with the AI.

**Phase 2 — Synthesise**

6. Run the **Generator** — it reads the cleared RSF and synthesises a complete, annotated implementation under `implementation/`.
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
5. Run the **Transformation** agent — it applies the CDFs to the annotated codebase, writes the managed target under `implementation/`, and preserves all annotation identifiers without deleting legacy source.
6. Continue from step 7 of the greenfield loop above (Review → Refine → Approve).

---

## Developer Automation

Repository-maintenance commands live under `scripts/` and are not included in
the SDAIS distribution archive:

```sh
make check
make release VERSION=v0.14.0
make verify ARCHIVE=dist/sdais-v0.14.0.tgz
```

`make check` runs shell syntax checks, repository tests, Markdown link and fence
checks, managed-prompt inventory checks, and `git diff --check`.

`make release` verifies that the requested version matches the specification,
README, guides, changelog, installer, and updater. It then runs all checks,
builds the complete archive in temporary staging, installs and updates temporary
projects from that archive, verifies project-library and custom-agent
preservation, and writes the result under `dist/` with its SHA-256 checksum. It
refuses to overwrite an existing archive; use `make release-force` explicitly
when rebuilding the same version.

The generated `dist/` directory is ignored by git. Release archives contain
only the user-facing distribution files; `scripts/`, `tests/`, `dist/`, and
project-specific libraries are excluded.

---

## Repository Contents

| File / Directory | Purpose |
|---|---|
| `SDAIS.md` | Full normative specification — single source of truth |
| `install.sh` | Scaffolds a new project |
| `update.sh` | Upgrades an existing project's scaffold |
| `sdais.sh` | Launcher — runs any agent role with a chosen tool and model |
| `Makefile` | Convenience entry points for checks and release automation |
| `scripts/` | Developer-only checking, release building, and archive verification |
| `tests/` | Repository regression tests; not included in releases |
| `dist/` | Ignored output directory for generated release archives |
| `scaffold/` | Prompt files and templates installed by `install` |
| `sdais/library/` (installed projects) | Project-owned, immutable versioned reference contracts; never bundled with project-specific content |
| `sdais-vX.Y.Z.tgz` | Complete distribution archive; unpack before running `install.sh` or `update.sh` |
| `docs/INTRODUCTION.md` | Concepts, motivation, agent roles, and prompt reference |
| `docs/GREENFIELD.md` | Detailed greenfield workflow with process diagram |
| `docs/TRANSFORMATION.md` | Detailed transformation workflow with process diagram |
| `docs/GLOSSARY.md` | All acronyms, document types, and annotation identifiers |
| `CHANGELOG.md` | Version history |
| `LICENSE` | BSD 3-Clause License |

---

## License

BSD 3-Clause — see `LICENSE`.
