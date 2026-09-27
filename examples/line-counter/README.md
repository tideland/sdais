# Fixture — CSV line counter

A deliberately small SDAIS-G project for evaluating the workflow and the prompt
notation. Not part of the scaffold; nothing here ships into user projects.

`sdais/gspec/v1/idea.md` is fifteen lines of loose prose chosen to exercise
every RSF item type and both RequirementsEngineer modes:

| Prose                                    | Should become                        |
|------------------------------------------|--------------------------------------|
| counts records, skips header row         | FR + AC                              |
| "fast even on big files"                 | NFR — no numeric bound, must ask     |
| Go, standard library only                | C                                    |
| `SDAIS_DEMO_INPUT` environment variable  | E (and a Grounder check)             |
| "handled gracefully"                     | no success criterion, must ask       |
| "our usual CLI conventions"              | context absent from the spec, must ask |

So a correct first run lands in **Mode A**, not Mode B: three or more `[[QN]]`
markers, `gspec/v2/` written, `gspec/v1/` untouched. Answer the questions in
`gspec/v2/`, re-run, and the second pass should reach **Mode B** and write
`rsf/v1/`.

## Running it

This directory holds only the prose input. `bootstrap.sh` scaffolds it into a
throwaway project — so the agent's new version directories land outside the
repo — and generates a CSV for the synthesised tool to read:

    ./bootstrap.sh /tmp/lc
    cd /tmp/lc
    export SDAIS_DEMO_INPUT=/tmp/lc/data
    sdais claude <model> RequirementsEngineer

Options:

    --rows N        data rows to generate (default: 1000)
    --size BYTES    generate approximately BYTES instead; K, M, G suffixes
    --malformed N   inject N malformed rows, spread evenly (default: 0)
    --force         replace an existing fixture directory

The generated `data/records.csv` has a header row plus `id,name,email,amount,
created_at`, which gives the header-skipping FR something to be wrong about.
`--malformed` injects three kinds in rotation — too few fields, one field too
many, and an unterminated quote — so the "handled gracefully" requirement has
something to exercise once you have pinned down what graceful means:

    ./bootstrap.sh /tmp/lc --rows 250000 --malformed 5
    ./bootstrap.sh /tmp/lc --size 500M --force     # for the NFR bound

`--force` only replaces a directory that already looks like a bootstrapped
fixture; it refuses to delete anything else.

## What to check

Mode A:

- `gspec/v1/` is byte-for-byte unchanged
- `gspec/v2/` exists, one file per source file, same filename
- each `[[QN]]` in the prose has a matching `### QN:` under `## Questions`
- the summary matches the `A.4 output verbatim` block in the prompt, line for line

Mode B, after answering:

- every FR file has at least one AC referencing it
- every NFR carries a numeric bound
- the `SDAIS_DEMO_INPUT` item is an `e-` file and carries `**Verified:** Pending`
- every item has a `**Source:**` line pointing back into `gspec/`

Grounder, with `SDAIS_DEMO_INPUT` exported as above:

- the `e-` item flips to `**Verified:** true` and `**Last modified:**` moves to
  today; unset the variable and re-run and it should instead stage an
  `ENV-UNRESOLVABLE` finding in `rsf/v2/` and leave the original at `Pending`

## Notation regression check

The prompts use the compact notation described in `AGENTS.md`. To test whether
a given model still reads every obligation, hand it a prompt file cold — no
repo, no context — and ask it to enumerate the obligations as a numbered list.
Compare against the prose version at tag `v0.10.0`. Rules that go missing are
usually `@never` lines or conditionals, not the `@` markers themselves. Worth
repeating per model in the `sdais.sh` matrix; smaller models lose more.
