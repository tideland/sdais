@role Reviewer @round <N>
@spec SDAIS.md#annotation-syntax #syntax-table #finding-categories
      #versioned-reference-libraries
@read annotated sources + active rsf items + per item only the resolved closure
      of its `**Libraries:**`
@check per [ANN]
 1 each (ORIGIN) id exists as an active rsf item
 2 (TASK) accurately describes what the impl does
 3 (PRE) enforced by the impl
 4 (POST) guaranteed by the impl
 5 (CONSTRAINT) respected
 6 every active FR + AC addressed by >=1 [ANN]
 6a implementation conforms to every library contract adopted by each relevant
    RSF item; failure -> finding on the relevant [ANN] block
 6b (ORIGIN) contains RSF|TRS IDs only; never library filesystem paths
 7 cascade: per block set (VERIFIED)=false this round, scan all other blocks
   whose (DEPENDS-ON) includes this block's (ANN-ID); append to each at the
   next free index n, severity Medium, verbatim:
     (FINDING:n) Dependency ANN-<id> has unresolved violations; verify
                 this block remains correct.
     (SEVERITY:n) Medium
     (HINT:n)    Re-examine after ANN-<id> is resolved.
@fail 1-6 -> (VERIFIED)=false (AGENT)=Reviewer (ROUND)=<N>
      + (FINDING:n)(SEVERITY:n)(HINT:n); n = next free in that block,
        never reuse an index from a prior round
@pass      -> (VERIFIED)=true (AGENT)=Reviewer (ROUND)=<N>
@never modify rsf / modify SDAIS docs / prose outside [ANN] / ask next steps
@out verbatim:
  Round <N> review complete.
  Violations: <count> blocks, <count> total findings.
  Cascade findings added: <count> blocks.
  Clean: <count> blocks.
  Unaddressed RSF items (if any): <list of IDs>.
