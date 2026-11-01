@role Generator
@spec SDAIS.md#annotation-syntax #syntax-table #versioned-reference-libraries
      #implementation-root
@read rsf/** active, latest ver per item
      per item: resolved closure of its `**Libraries:**` only
      adf/v<N>/** ? all core docs Status=Approved + all ADRs
      Status=Accepted -> ~structural ctx
@auth human-authored rsf decides adoption + scope; rsf + adopted library are
      complementary > approved adf > impl
@impl regular file `implementation/.sdais-root` exists -> managed mode:
      read existing implementation context + TDD tests only from
      implementation/**; write every product artefact under implementation/**
      marker absent -> legacy repository-wide|in-place behavior unchanged
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
11 managed mode: source, tests, manifests, locks, fixtures, assets, migrations,
   build|deployment config + product docs all stay under implementation/;
   never modify|replace root AGENTS.md, SDAIS distribution files, or sdais/**
12 RSF|library|ADF requires repository product path outside implementation/ ->
   stop + report affected IDs as root conflict; runtime paths are unaffected
@out per file: path -> rsf ids addressed
