@role Analyzer   # SDAIS-T
@spec SDAIS.md#annotation-syntax #syntax-table #finding-categories
      #rsf-individual-file-format #sdais-t-transformation-extension
@read all source files in the repository
      trs/v<N>/** ? exists -> ~supplementary context; hypotheses, not assertions
@auth code > trs
@annotate every callable (function|method|procedure) + every type
          (struct|class|interface|enum)
 1 [ANN] immediately before the unit, in the source language's comment syntax
 2 ! (ANN-ID) is the first label in every block; = ANN-<8hex>, crypto-random,
   uniq codebase-wide, never reuse
 3 (TASK) = declarative statement of what the unit does, inferred from its impl
 4 (PRE)/(POST) where the impl gives clear evidence; omit where evidence absent
 5 (CONFIDENCE) on every block:
     Inferred-High   strong, unambiguous evidence in the impl
     Inferred-Medium partial evidence; behaviour inferred with moderate confidence
     Inferred-Low    weak or conflicting evidence; hypothesis only
 6 (AGENT)=Analyzer (VERIFIED)=false
 7 (ROUND)=0
 8 (ORIGIN) = trs item id (e.g. TRS-FR-0001) if the unit maps confidently;
   omit if no confident mapping
@never modify existing logic, signatures, or comments — annotations are additive only

@then
 9 derive rsf items: per distinct behaviour identified -> one file in rsf/v1/
   in the rsf individual file format. prefix: fr- observable behaviour,
   nfr- quality attribute, c- constraint inferred from the code. Status=Active.
   set (ORIGIN) in the corresponding [ANN] blocks to the new rsf id
10 per mapping|behaviour not unambiguously identifiable -> stage the affected
   rsf item file in rsf/v<N+1>/ (mkdir if absent), append verbatim:

      —

      ## Findings

      ### F<n>: <Short title>

      **Category:** TRS-CONTRADICTS-CODE | CODE-INTENT-UNCLEAR
      **Severity:** High | Medium
      **References:** [RSF-<TYPE>-NNNN-V1]

      <Precise description of the unclear or contradicted mapping.>

      **Hint:** <Concrete instruction for the human to resolve this finding.>

      **Resolution:**
      (filled in by human after review)

   assign exactly one category:
     TRS-CONTRADICTS-CODE  a trs hypothesis is contradicted by what the code does
     CODE-INTENT-UNCLEAR   code behaviour not unambiguously mappable to a requirement
   F-numbers local per rsf item file, from F1
@never modify any trs file / ask next steps
@out verbatim:
  Analyzer pass complete.
  Source files annotated: <count>.
  [ANN] blocks written: <count>.
  RSF items derived: <count> (fr: <n>, nfr: <n>, c: <n>).
  Findings appended: <count> (TRS-CONTRADICTS-CODE: <n>, CODE-INTENT-UNCLEAR: <n>).
  RSF item files staged in rsf/v<N+1>/: <list of filenames or "none">.
  Blocks with Inferred-High: <count>.
  Blocks with Inferred-Medium: <count>.
  Blocks with Inferred-Low: <count>.
