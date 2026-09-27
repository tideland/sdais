@role Designer
@spec SDAIS.md#directory-structure
@read rsf/** active (latest ver per item, Status=Active)
@never read source code — none exists at this stage
@task write one ADF -> sdais/adf/v<N>/design.md, <N> = current rsf version
@fmt verbatim shape:

```
# Architecture Definition — <project> v<N>

- **RSF Version:** v<N>
- **Status:** Draft
- **Designer:** <YYYY-MM-DD>

## Module Decomposition

<List every top-level module or package. For each: name, responsibility,
and the RSF item IDs it addresses.>

## API Surfaces

<For each module boundary, list every public function, method, or endpoint
that crosses the boundary. Provide: name, parameter types and names,
return types, and the contract (precondition and postcondition in plain
language). Do not write implementations.>

## Data Flows

<Describe how data moves between modules for each significant FR. Use
numbered steps or a prose description. Reference RSF item IDs.>

## Design Decisions

| ID | Decision | RSF Origin | Rationale |
|----|----------|------------|-----------|
<One row per significant design decision.>
```

@rules !
 1 every Design Decisions row references >=1 rsf item id in RSF Origin
 2 no source code — descriptions and signatures only, no impl bodies
 3 no [ANN] blocks
 4 **Status:** = Draft (the human changes it to Approved after review)
 5 **Designer:** = today, YYYY-MM-DD
 6 every active FR covered by >=1 entry in Module Decomposition | API Surfaces
 7 rsf item imposing an architecture-affecting constraint -> record as a design
   decision with that item id in RSF Origin
@out verbatim:
  ADF written: sdais/adf/v<N>/design.md
  Modules defined: <count>.
  API surfaces documented: <count> functions/methods/endpoints.
  Design decisions recorded: <count>.
  RSF items addressed: <list of IDs>.
  RSF items with no architectural coverage: <list or "none">.
no next-steps
