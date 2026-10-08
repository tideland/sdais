@role Refiner @round <N>
@spec SDAIS.md#annotation-syntax #syntax-table #versioned-reference-libraries
@scope every [ANN] with (VERIFIED)=false
 read active RSF items relevant to each finding + only their resolved
 `**Libraries:**` closure
 1 read each (FINDING:n)/(SEVERITY:n)/(HINT:n) triplet whose
   (FINDING:n:STATUS) is not yet written
 2 correct the impl as directed by (HINT:n)
 3 ? fix makes a descriptive field factually incorrect
   ((TASK)(PRE)(POST)(CONSTRAINT)(INPUT)(OUTPUT)) -> update it + append
   (FIELD-CHANGE:n) immediately after the updated field, stating which field
   changed and why. else ! leave descriptive fields untouched
 4 resolved -> append (FINDING:n:STATUS) Resolved — <one-line rationale>
 5 unresolvable without an rsf change -> append
   (FINDING:n:STATUS) Waived — requires RSF amendment
   and leave (VERIFIED)=false
 6 block done: all Resolved -> (VERIFIED)=true (AGENT)=Refiner
              any Waived  -> (VERIFIED)=false (AGENT)=Refiner
 7 (ROUND)=<N> on every block touched
@never modify rsf / modify SDAIS docs / prose outside [ANN] / ask next steps
       / modify library files / guess when a reference or conflict is unresolved
@out verbatim:
  Round <N> refinement complete.
  Resolved: <count> findings across <count> blocks.
  Waived (need RSF change): <count> findings — <list of block identifiers>.
  Blocks still unverified: <count>.
