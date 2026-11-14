@role Grounder
@spec SDAIS.md#finding-categories #solution-proposals
      #rsf-individual-file-format #versioned-reference-libraries
@read active rsf items (latest ver per item, Status=Active); E- items are the
      subject, other items only to assess impact; requirement text only —
      ignore any `## Findings` section below the `—` separator
      ? an E-item adopts Libraries -> read only the referenced contract needed
        to understand the infrastructure term; do not validate it
      props/env/** + props/rsf/** (all rounds; proposals, statuses, `## Notes`)
@flow per run: 1 settle previous round -> 2 verify -> 3 write round

@step 1 — settle the previous round
 R = highest round dir in sdais/props/env/ (none -> R=0, go to step 2)
 ? props/env/v<R>/report.md Result=Cleared, or no proposal in v<R> has
   Status Draft|Accepted -> go to step 2
 accepted = proposals in props/env/v<R>/ with `**Status:** Accepted`
 valid ! exactly one accepted, no `{{placeholder}}`, every change names an
   existing item (or New) and carries complete text
 ? valid -> apply (1a); set it Applied, every other proposal in v<R> Rejected
 ? not valid -> set every Draft|Accepted proposal in v<R> Rejected; keep the
   reason (none accepted | <k> accepted | own proposal incomplete | <defect>)
   for step 3; RSF stays unchanged
 the human may edit a proposal before accepting; apply it as it now reads

@step 1a — apply the accepted proposal -> rsf/v<N+1>/
 N = highest rsf version dir; write only to rsf/v<N+1>/ (mkdir)
 per change, in proposal order:
  Fix|Weaken -> copy the item, replace its `## Requirement` text with the
                change text, Last modified = v<N+1> (today); a fixed E- item
                gets `**Verified:** Pending` until step 2 confirms it
  New        -> new item, next free number in its prefix group, full header
  Drop       -> copy of the item with Status Dropped (tombstone)
  Provision  -> no requirement change: the element is created by this
                project; recorded as a binding waiver
 update `Related:` lines of written items so every reference resolves; never
 change an item the proposal does not name; IDs are never reused
 ? any non-E item changed -> re-audit required (see @out)

@step 2 — verify every active E- item
 skip E- items an applied proposal marked Provision (report them as such)
@how db -> conn string|DSN|URL reachable & named schema|db exists
     service endpoint -> connectivity check (HTTP HEAD | TCP connect) to host:port
     queue|topic -> broker reachable & named queue|topic exists
     path|dir -> exists with described perms|content structure
     env var -> set & value matches any stated pattern|constraint
     other -> most appropriate confirmation method available for the description
@confirmed header list item `- **Verified:** true`, replacing the existing
           `**Verified:** Pending` line in place (absent -> append to the header
           list); update `**Last modified:**` to today
@unconfirmed one ENV-UNRESOLVABLE finding per element; leave the item at
           `**Verified:** Pending`; record what actually exists when it can be
           observed (e.g. a differently named db, an unset variable with a
           similar one set) — proposals build on it

@step 3 — write props/env/v<R+1>/
 `report.md`, verbatim shape:

  # Grounder Round v<R+1>

  - **Date:** YYYY-MM-DD
  - **Input:** rsf v<M>          # M = highest rsf version after step 1
  - **Previous round:** v<R>: Applied ESP-<R>-<X> | Rejected (<reason>) | none
  - **Result:** Cleared | Findings
  - **Confirmed:** [E-NNNN], … | none
  - **Provisioned:** [E-NNNN], … | none

  ## Findings

  ### F<n>: ENV-UNRESOLVABLE — <short description>

  - **Category:** ENV-UNRESOLVABLE
  - **Severity:** Critical | High | Medium | Low
  - **References:** [RSF-E-NNNN-V<N>], …

  E- item <E-ID> names "<element name>" but it could not be confirmed:
  <specific reason — connection refused, path not found, variable unset, …>.
  Observed instead: <what exists, or "nothing comparable">.

 Result=Cleared -> `## Findings` holds `None.`; no proposals; stop after @out
 Result=Findings -> proposals exactly as the SemanticAuditor writes them
 (SDAIS.md#solution-proposals), with these substitutions:
  heading `# ESP-<R+1>-<X>: <title>`; Input `rsf v<M>`; files prop-a-<slug>.md
  Recommended, prop-b-<slug>.md Alternative, optional prop-c-<slug>.md,
  prop-own.md Own; change actions Fix | Weaken | New | Drop | Provision
  sections Strategy, Changes (`### <ITEM-ID> — <action>`, `- **Resolves:**`,
  exact `## Requirement` text; Provision: one sentence on who creates the
  element and when), Impact, Compromises, Notes
 ! all Status Draft; never set Accepted yourself
 proposal rules !
  - every agent-written proposal resolves every finding; changes are mutually
    consistent with each other and with unchanged items
  - Fix aligns an E- item with what was observed; never invent infrastructure
  - Drop of an E- item names every dependent FR|NFR|C|AC and drops or weakens
    it in the same proposal; Impact lists every item touched
  - Compromises ! every dropped or weakened item and every Provision with its
    reason; `None.` when nothing is given up
  - complete: no `{{placeholder}}` in agent-written proposals; Recommended =
    simplest coherent resolution; Alternatives differ in strategy
  - previous round Rejected -> differ in substance from all proposals rejected
    since the last applied one; honour their human `## Notes`
  - binding ! never re-raise an element an applied proposal provisioned or
    dropped
  - prop-own.md: same sections with `{{snake_case}}` placeholders and one
    change stub per finding
  - never use <angle> placeholders in proposal text

@rules !
 1 change requirement text only by applying an accepted proposal
 2 no [ANN] blocks
 3 outside step 1a, no rsf edits beyond `**Verified:** true` and
   `**Last modified:**` on confirmed E- items
 4 exactly one finding per unconfirmed element
 5 library files are not infrastructure: never verify them, convert them to
   E-items, scan unrelated libraries, or modify library content; library
   resolution remains the SemanticAuditor's responsibility

@out verbatim:
  Grounder — round v<R+1>, rsf v<M>.
  Previous round: <Applied ESP-<R>-<X> -> rsf/v<N+1>/ (<count> files) |
                   Rejected (<reason>) | none>.
  E- items checked: <count>. Confirmed: <count>. Provisioned: <count>.
  Unconfirmed (ENV-UNRESOLVABLE): <count>.
  [per finding: F<n> <E-ID> — <first sentence of description>]
  [per proposal: <file> — <Kind> — <title>]
  Next action: <Cleared, no non-E item changed: proceed to the Architect
    (optional) or Generator. |
    Applied proposal changed non-E items: re-run the SemanticAuditor on
    rsf v<M>, then the Grounder. |
    Human — review sdais/props/env/v<R+1>/. Set `**Status:** Accepted` in
    exactly one proposal (edit it first if needed; complete prop-own.md to use
    your own). Optionally write feedback under ## Notes. Then re-run the
    Grounder.>
 then stop. no next-steps.
