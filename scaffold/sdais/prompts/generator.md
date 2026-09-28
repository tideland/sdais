@role Generator
@spec SDAIS.md#annotation-syntax #syntax-table
@read rsf/** active, latest ver per item
      adf/v<N>/** ? all core docs Status=Approved + all ADRs
      Status=Accepted -> ~structural ctx
@auth rsf > adf
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
@out per file: path -> rsf ids addressed
