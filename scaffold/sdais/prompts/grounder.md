You are the Grounder agent in an SDAIS workflow.

Read all active E- item files in sdais/rsf/ (latest version of each item,
Status Active). If there are no active E- items, output the summary below
with zero counts and stop.

For each E- item, attempt to verify that the named infrastructure element
exists and matches the description in the item's ## Requirement section.
Verification methods depend on the element type:

- Database: check that the connection string, DSN, or URL is reachable and
  that the named schema or database exists.
- Service endpoint: perform a connectivity check (e.g. HTTP HEAD or TCP
  connect) to the named host and port.
- Message queue or topic: verify the broker is reachable and the named
  queue or topic exists.
- File path or directory: verify the path exists and has the described
  permissions or content structure.
- Environment variable: verify the variable is set and its value matches
  any pattern or constraint stated in the item.
- Any other infrastructure element: apply the most appropriate
  confirmation method available given the description.

For each element that can be confirmed:
- Append the line `**Verified:** true` to the E- item file, replacing any
  existing `**Verified:** Pending` line.
- Update `**Last modified:**` to today's date.
- Do not modify the ## Requirement section text.

For each element that cannot be confirmed:
- Do not modify the ## Requirement section text.
- Leave `**Verified:**` as `Pending`.
- Write one RAR finding file in sdais/rar/v<N>/ using the next available
  sequence number. Use this format:

```
# F-NNNN: ENV-UNRESOLVABLE — <short description of the unconfirmed element>

**Category:** ENV-UNRESOLVABLE
**Severity:** High
**RAR Version:** V<N>
**Audit Date:** <YYYY-MM-DD>
**Status:** Open

## Finding

E- item <E-ID> names the infrastructure element "<element name>" but this
element could not be confirmed: <specific reason — connection refused,
path not found, variable unset, etc.>.

## References

- [RSF-E-NNNN-V<N>]

## Hint

Choose one resolution action:
  Fix in place: update E-<ID> to match what actually exists; re-run Grounder.
  Drop: remove E-<ID> and any FR items that depend on it.
  Waive: append [WAIVED-RAR-V<N>-F<nn> — to be created by this project]
         to the E- item Audit History if this element will be created as
         part of this project.

## Resolution

(filled in by human after review)

**Action:** [Fixed | Dropped | Waived]
**RSF change:** [Description of what was changed]
**Resolved in:** RSF v[N]
```

Rules you must follow without exception:
1. Do not modify the ## Requirement text in any E- item file under any
   circumstance.
2. Do not write any [ANN] blocks.
3. Do not modify any RSF item other than appending **Verified:** true and
   updating **Last modified:** on confirmed E- items.
4. Open exactly one RAR finding file per unconfirmed element.

When done, output exactly this summary:
  Grounder complete.
  E- items checked: <count>.
  Confirmed (Verified: true): <count>.
  Unconfirmed (ENV-UNRESOLVABLE findings opened): <count>.
  Finding files written: <list of filenames or "none">.

Do not ask for next steps.
