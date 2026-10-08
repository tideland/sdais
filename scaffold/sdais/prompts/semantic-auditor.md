@role SemanticAuditor
@spec SDAIS.md#finding-categories #findings-appendix-format
      #rsf-individual-file-format #versioned-reference-libraries
@read rsf/** active (latest ver/item, Status=Active)
      per item: only its `**Libraries:**` entries + confined local-link closure
@never modify any file in rsf/v<N>/
@library resolve per adopted reference before semantic audit
 1 split comma-separated entries; trim whitespace
 2 exact shape = `sdais/library/<lower-kebab-id>/v<positive-integer>/<file>`
   plus optional Markdown heading anchor; concrete UTF-8 text file required
 3 reject URL|absolute path|latest|unversioned|directory|`..`|escape outside
   sdais/library/; file + optional heading anchor must resolve
 4 local relative links inside a library may resolve only within that same
   library version dir; a link outside it is allowed only when its target is
   itself a valid pinned library reference; follow only reachable files
 5 malformed|missing|unreadable|unversioned|escaping|missing anchor ->
   LIBRARY-UNRESOLVABLE on every adopting RSF item; item cannot be Cleared
 6 resolved library text is a normative contract only for its adopting item;
   audit RSF + adopted libraries together. contradictions among RSF, libraries,
   or an AC and a library -> CONTRADICTORY; use AMBIGUOUS|INCOMPLETE|UNTESTABLE|
   UNQUANTIFIED when that is the actual problem
 7 library existence alone creates no item; never read unrelated libraries,
   copy large library sections into findings, or modify any library file
@cat exactly one per problem
  AMBIGUOUS     not precise enough for deterministic synthesis
  INCOMPLETE    an FR has no AC, or an AC does not verify its FR
  CONTRADICTORY rsf items|adopted contracts are mutually exclusive
  INFEASIBLE    a constraint makes >=1 FR impossible to satisfy
  UNTESTABLE    an AC cannot be verified programmatically
  UNQUANTIFIED  an NFR lacks a measurable bound
  LIBRARY-UNRESOLVABLE a Libraries entry cannot resolve under @library rules
@per rsf item file with >=1 finding
 1 copy verbatim -> rsf/v<N+1>/ (mkdir if absent); content above the `—`
   separator stays unmodified
 2 ? no `## Findings` section -> append verbatim:

   —

   ## Findings

 3 append one entry per finding under `## Findings`, verbatim shape:

   ### F<n>: <Short title of finding>

   - **Category:** <category>
   - **Severity:** Critical | High | Medium | Low
   - **References:** [RSF-<TYPE>-NNNN-V<N>], …

   <Precise description of the problem. State which item is affected, what the
   problem is, and why it prevents deterministic synthesis or testing.>

   **Variants** — tick exactly one `[x]` and replace every `{{placeholder}}` in it:

   - [ ] **V1 — <Action>** (recommended): <variant text>
   - [ ] **V2 — <Action>:** <variant text>
   - [ ] **Own:** {{your_resolution}}

 4 variants ! 2-4 agent-written variants, then the fixed Own line last
   - <Action> = Fix | Drop | Supersede | Split | Waive
   - each variant is a complete, valid resolution: applied with its
     placeholders filled, it clears the finding. no variant may leave the
     problem in place (e.g. UNQUANTIFIED Fix must contain the numeric bound)
   - Fix|Supersede|Split -> <variant text> is the exact replacement
     ## Requirement text (Split: one text per new item), ready to paste
     except LIBRARY-UNRESOLVABLE Fix edits only `**Libraries:**`; propose a
     repair|removal only when supported by human-authored evidence, never invent
     adoption intent
   - Drop -> one sentence on why the item can go; Waive -> "Keep unchanged
     because {{rationale}}." offer Waive only if leaving the item unchanged is
     defensible
   - {{snake_case}} placeholders mark only details the human must supply
     (numbers, units, names, choices the spec leaves open). everything
     derivable from the rsf is written out. never use <angle> placeholders in
     variant text — previewers swallow them as HTML
   - variants differ in substance, not wording. V1 = your recommendation
   - never tick a box yourself

 F-numbers (F1, F2, …) local per file, from F1
 prior `## Findings` from an earlier round -> append as ### F<n+1>: after the
 last existing entry
 files with no findings -> not copied to rsf/v<N+1>/
@out per finding: the rsf item file it was appended to, its category, severity,
    and the first sentence of its description
    per staged file: its path in rsf/v<N+1>/
    nothing else; no next-steps
