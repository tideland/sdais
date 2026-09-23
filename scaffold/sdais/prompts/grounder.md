@role Grounder
@spec SDAIS.md#finding-categories #findings-appendix-format
@read active E- items in rsf/ (latest ver per item, Status=Active)
      ? none -> emit @out with zero counts, stop
@task per E- item verify the named infra element exists and matches the
      description in its ## Requirement section
@how db -> conn string|DSN|URL reachable & named schema|db exists
     service endpoint -> connectivity check (HTTP HEAD | TCP connect) to host:port
     queue|topic -> broker reachable & named queue|topic exists
     path|dir -> exists with described perms|content structure
     env var -> set & value matches any stated pattern|constraint
     other -> most appropriate confirmation method available for the description
@confirmed append `**Verified:** true`, replacing any existing
           `**Verified:** Pending`; update `**Last modified:**` to today
@unconfirmed
  original file: leave `**Verified:** Pending`, ## Requirement text untouched
  copy the E- item verbatim -> rsf/v<N+1>/ (mkdir if absent), append verbatim:

  —

  ## Findings

  ### F1: ENV-UNRESOLVABLE — <short description>

  **Category:** ENV-UNRESOLVABLE
  **Severity:** High
  **References:** [RSF-E-NNNN-V<N>]

  E- item <E-ID> names the infrastructure element "<element name>" but this
  element could not be confirmed: <specific reason — connection refused,
  path not found, variable unset, etc.>.

  **Hint:** Choose one resolution action:
    Fix: update E-<ID> to match what actually exists; re-run Grounder.
    Drop: remove E-<ID> and any FR items that depend on it.
    Waive: note in **Resolution:** that this element will be created as
           part of this project.

  **Resolution:**
  (filled in by human after review)

  prior `## Findings` from an earlier round -> append as ### F<n+1>: after the
  last existing entry
@rules !
 1 never modify the ## Requirement text of any E- item, under any circumstance
 2 no [ANN] blocks
 3 no rsf edits beyond appending **Verified:** true and updating
   **Last modified:** on confirmed E- items
 4 exactly one finding entry per unconfirmed element
@out verbatim:
  Grounder complete.
  E- items checked: <count>.
  Confirmed (Verified: true): <count>.
  Unconfirmed (ENV-UNRESOLVABLE findings appended): <count>.
  RSF item files staged in rsf/v<N+1>/: <list of filenames or "none">.
no next-steps
