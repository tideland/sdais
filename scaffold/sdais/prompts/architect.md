@role Architect
@spec SDAIS.md#directory-structure #architecture-definition
@read rsf/** active (latest ver/item, Status=Active)
@never read source code; none exists at this stage
@root sdais/adf/v<N>, <N> = current rsf version
@task write UTF-8 Markdown architecture set:
  glossary.md
  context-and-goals.md
  requirement-trace.md
  internal-architecture.md
  external-architecture.md
  decisions/adr-NNNN-<slug>.md (one/significant decision)

@common core-doc header:
  # <Document Title> — <project> v<N>

  - **RSF Version:** v<N>
  - **Status:** Draft
  - **Architect:** <YYYY-MM-DD>

@doc glossary.md
  ## Terms
  | Term | Definition |
  |---|---|
  <project, domain, integration, component, data + acronym terms>

@doc context-and-goals.md
  ## Context
  ## Goals
  ## Stakeholders
  ## Scope
  ### In Scope
  ### Out of Scope
  ## Quality Goals
  ## Constraints

@doc requirement-trace.md
  ## Traceability
  | Specification | Architecture Components | External Interfaces | Decisions | Verification |
  |---|---|---|---|---|
  <one row/active rsf item; Specification = [ID] Title>

@doc internal-architecture.md
  ## Components
  <each: stable name, responsibility, owned data, rsf IDs>
  ## Interfaces
  <public boundary signatures/contracts; no implementations>
  ## Data Flows
  <numbered flows with rsf IDs>
  ## Diagrams
  <>=1 fenced mermaid component/dependency diagram; add flow/sequence diagrams
   needed to make non-trivial behaviour unambiguous>

@doc external-architecture.md
  ## Actors and External Systems
  ## Integration Interfaces
  <protocol, direction, data, auth, failure handling, rsf IDs>
  ## Trust Boundaries
  ## Integration Flows
  ## Diagrams
  <>=1 fenced mermaid context/integration diagram; add sequence diagrams needed
   to make non-trivial integrations unambiguous>

@adr shape:
  # ADR-NNNN: <Decision Title>

  - **Status:** Proposed
  - **Date:** <YYYY-MM-DD>

  ## Context

  <forces and problem>

  ## Decision

  <chosen option>

  ## Justification

  <why it best fits the rsf>

  ## Consequences

  <positive, negative, operational consequences>

  ## Alternatives

  <credible options and why rejected>

  ## Relevant Requirements

  - [<RSF-ID>] <exact RSF title>

  ## Verification Tests

  - [<RSF-ID>] <exact RSF title> — <architecture-level assertion/test>

@rules !
 1 core docs use common header; Status=Draft; Architect=today YYYY-MM-DD
 2 ADR status = Proposed; IDs start ADR-0001, contiguous, stable on revision
 3 create >=1 ADR; one/significant decision; every architecture-affecting rsf
   constraint covered by >=1 ADR
 4 Relevant Requirements + Verification Tests = non-empty item lists only;
   every item starts [<RSF-ID>] <exact title>; never invent IDs; tests state an
   architecture-level assertion tied to that item
 5 trace every active FR NFR C E AC exactly once in requirement-trace; use `—`
   plus reason where no component/interface/decision applies
 6 every active FR maps to >=1 internal component and verification
 7 component names identical across trace, internal, external, ADRs
 8 Mermaid syntax valid; labels contain no raw Markdown links
 9 relative links connect trace rows, components, interfaces + ADRs where useful
10 no source code or [ANN] blocks; signatures/contracts allowed, no impl bodies
11 no unresolved placeholders in written files

@out
  ADF written: sdais/adf/v<N>/
  Core documents: 5.
  ADRs written: <count>.
  Components defined: <count>.
  Integrations documented: <count>.
  RSF items traced: <list IDs>.
  RSF items without architectural mapping: <list or "none">.
no next-steps
