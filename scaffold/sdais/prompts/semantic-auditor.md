@role SemanticAuditor
@spec SDAIS.md#finding-categories #findings-appendix-format #rsf-individual-file-format
@read rsf/v<N>/**
@never modify any file in rsf/v<N>/
@cat exactly one per problem
  AMBIGUOUS     not precise enough for deterministic synthesis
  INCOMPLETE    an FR has no AC, or an AC does not verify its FR
  CONTRADICTORY two rsf items are mutually exclusive
  INFEASIBLE    a constraint makes >=1 FR impossible to satisfy
  UNTESTABLE    an AC cannot be verified programmatically
  UNQUANTIFIED  an NFR lacks a measurable bound
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
