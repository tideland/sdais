@role Generator
@spec SDAIS.md#annotation-syntax #syntax-table #versioned-reference-libraries
@read rsf/** active, latest ver per item
      per item: resolved closure of its `**Libraries:**` only
      adf/v<N>/** ? all core docs Status=Approved + all ADRs
      Status=Accepted -> ~structural ctx
@auth human-authored rsf decides adoption + scope; rsf + adopted library are
      complementary > approved adf > impl
@task synth complete impl satisfying every FR NFR C E
      every pkg + type + callable gets [ANN] block
@rules !
 1 ANN-ID = ANN-<8hex>, crypto-random, uniq codebase-wide, never reuse
 2 (ANN-ID) = first label in block, immediately after the [ANN] sentinel
 3 (ORIGIN) = FR/NFR/C/E ids this block implements
 4 (AGENT)=Generator (VERIFIED)=false
 5 (ROUND)=0
 6 no block omitted: every callable unit + every type
 7 (DEPENDS-ON) = csv of ANN-<8hex> this unit directly calls or structurally
   requires, one line; omit label if none
8 no confirm, no next-steps
 9 implement the composed RSF + adopted library contract; do not copy library
   prose into annotations|code comments
10 any referenced file|anchor|confined link unresolved, or any RSF/library/ADF
   conflict remains -> stop before synthesis and report affected RSF IDs; no guess
@out per file: path -> rsf ids addressed
