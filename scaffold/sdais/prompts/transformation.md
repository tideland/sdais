@role Transformation   # SDAIS-T
@spec SDAIS.md#annotation-syntax #syntax-table #sdais-t-transformation-extension
@read 1 all annotated source files produced by the Analyzer
      2 all active cdf/v<N>/** — these define the transformations to apply
      3 rsf/** active (latest ver per item) — the behavioural spec the
        transformed code must satisfy
@per cdf
 1 read Source, Target, Transformation Rules, Constraints to Preserve, Affects
 2 apply every Transformation Rule to every unit listed in Affects;
   Affects=all -> every unit in the codebase
 3 produce the transformed code in the target language|framework|architecture
   defined by the cdf
@annid ! preservation
 - every [ANN] in the transformed code carries the (ANN-ID) of the corresponding
   original unit; never generate a new id for a unit mapping one-to-one
 - split: the original (ANN-ID) stays with the unit retaining primary
   responsibility for the original behaviour; each new unit receives a freshly
   generated ANN-<8hex> (crypto-random, uniq codebase-wide)
 - merge: the merged unit lists all original (ANN-ID) values in its (ANN-ID)
   field, comma-separated
 - never modify|drop|regenerate an (ANN-ID) except as required by split and
   merge above
@then
 4 identify rsf items not covered by the transformed units; per gap hand off to
   the Generator by outputting the uncovered rsf ids with the instruction
   "Generator: synthesise implementations for the following RSF items: <list>"
 5 (AGENT)=Transformation (VERIFIED)=false on every [ANN] written|modified
 6 (ROUND)=0 on every block written|modified
@never modify any rsf / cdf / trs file; ask next steps
@out verbatim:
  Transformation pass complete.
  CDFs applied: <count> (<list of CDF filenames>).
  Units transformed: <count>.
  (ANN-ID) preserved (one-to-one): <count>.
  (ANN-ID) split: <count> original IDs → <count> new units.
  (ANN-ID) merged: <count> original IDs → <count> merged units.
  New (ANN-ID) generated: <count>.
  RSF items covered: <count>.
  RSF items not covered (handed to Generator): <count> — <list of IDs>.
