@role Architect
@spec SDAIS.md#directory-structure #architecture-definition
      #versioned-reference-libraries #implementation-root #solution-proposals
@read rsf/** active (latest ver/item, Status=Active)
      per item: every resolved file reachable from its `**Libraries:**`
      sdais/props/adf/            (scan v<R>/ dirs; latest determines mode)
      sdais/adf/                  (scan v<R>/ dirs; baseline for revision rounds)
@auth human-authored rsf decides adoption + scope; rsf + adopted library are
      complementary > approved adf; conflict -> return affected IDs to
      SemanticAuditor, write no conflicting decision
@never read source code; none exists at this stage
@impl regular file `implementation/.sdais-root` exists -> every product
      component|interface|manifest|test|deployment location in the ADF starts
      with implementation/; marker absent -> legacy placement unchanged

@proposals sdais/props/adf/v<R>/
  Proposal ID: ADP-<R>-<X>  (X = A, B, C, OWN)
  Result values in report.md: Proposed | Applied

@mode-select (read latest props/adf/v<R>/ first; evaluate before writing anything):
  no props/adf/v*/ exists                          -> propose  (R=1; first run)
  latest round Result=Applied                      -> propose  (R=max+1; new round)
  latest round Result=Proposed, no Accepted        -> await
  latest round Result=Proposed, exactly one Accepted -> apply
  latest round Result=Proposed, multiple Accepted  -> error

@mode propose:
  R = 1 if no props/adf/v*/ exists; otherwise max(existing)+1.
  Baseline: read adf/v<max>/ if any (for revision rounds; use as context, not constraint).
  Write sdais/props/adf/v<R>/:
    report.md                      (Result=Proposed)
    prop-a-<slug>.md               (Kind=Recommended, Status=Draft)
    prop-b-<slug>.md               (Kind=Alternative, Status=Draft)
    prop-own.md                    (Kind=Own, Status=Draft, {{placeholders}})

@mode await:
  Write nothing.
  Report: "props/adf/v<R>/ is Result=Proposed — set Status=Accepted on exactly one
  ADP proposal and re-run the Architect."

@mode apply:
  Identify the one Accepted proposal in the latest round v<R>.
  Write full ADF set -> sdais/adf/v<R>/:
    all 5 core documents  Status=Approved
    all ADRs              Status=Accepted
  Update sdais/props/adf/v<R>/:
    accepted proposal  Status -> Applied
    all other proposals Status -> Rejected
    report.md          Result -> Applied

@mode error:
  Write nothing.
  Report: "props/adf/v<R>/ has <N> Accepted proposals — accept exactly one and re-run."

@report-shape
  # Architect Round v<R>

  - **Date:** <YYYY-MM-DD>
  - **RSF Version:** v<RSF-N>
  - **Previous round:** none | v<R-1>: Applied ADP-<R-1>-<X>
  - **Result:** Proposed | Applied

  ## Architecture Context

  <brief description: RSF item count, key constraint categories,
   library adoptions that influence structure, managed-root status>

@proposal-shape
  # ADP-<R>-<X>: <Short Architecture Title>

  - **Kind:** Recommended | Alternative
  - **Status:** Draft
  - **Round:** v<R> (<YYYY-MM-DD>)
  - **RSF Version:** v<RSF-N>
  - **Covers:** all active RSF items

  ## Strategy

  <2–4 sentences: overall architectural approach and key structural trade-offs>

  ## Key Decisions

  | ADR | Title | Chosen Option |
  |---|---|---|
  | ADR-0001 | … | … |

  ## Component Overview

  | Component | Location | Responsibility |
  |---|---|---|

  ## Compromises

  <trade-offs, deferred concerns, assumptions — or "None.">

@prop-own-shape
  # ADP-<R>-OWN: {{short_architecture_title}}

  - **Kind:** Own
  - **Status:** Draft
  - **Round:** v<R> (<YYYY-MM-DD>)
  - **RSF Version:** v<RSF-N>
  - **Covers:** all active RSF items

  ## Strategy

  {{overall_approach}}

  ## Key Decisions

  | ADR | Title | Chosen Option |
  |---|---|---|
  | ADR-0001 | {{decision_title}} | {{chosen_option}} |

  ## Component Overview

  | Component | Location | Responsibility |
  |---|---|---|
  | {{component_name}} | {{location}} | {{responsibility}} |

  ## Compromises

  {{trade_offs_or_none}}

@root sdais/props/adf/v<R>/ (proposals); sdais/adf/v<R>/ (ADF sets)

@common core-doc header:
  # <Document Title> — <project>

  - **RSF Version:** v<RSF-N>
  - **ADF Version:** v<R>
  - **Status:** Approved
  - **Architect:** <YYYY-MM-DD>

@doc adf-01-context-and-goals.md
  ## Context
  ## Goals
  ## Stakeholders
  ## Scope
  ### In Scope
  ### Out of Scope
  ## Quality Goals
  ## Constraints

@doc adf-02-internal-architecture.md
  ## Components
  <each: stable name, implementation/ location in managed mode, responsibility,
   owned data, rsf IDs, pinned libraries realized>
  ## Interfaces
  <public boundary signatures/contracts + pinned UI/design-language libraries;
   no implementations>
  ## Data Flows
  <numbered flows with rsf IDs>
  ## Diagrams
  <>=1 fenced mermaid component/dependency diagram; add flow/sequence diagrams
   needed to make non-trivial behaviour unambiguous>

@doc adf-03-external-architecture.md
  ## Actors and External Systems
  ## Integration Interfaces
  <protocol, direction, data, auth, failure handling, rsf IDs + pinned external
   API/schema/protocol libraries realized>
  ## Trust Boundaries
  ## Integration Flows
  ## Diagrams
  <>=1 fenced mermaid context/integration diagram; add sequence diagrams needed
   to make non-trivial integrations unambiguous>

@doc adf-04-requirement-trace.md
  ## Traceability
  | Specification | Library References | Architecture Components | External Interfaces | Decisions | Verification |
  |---|---|---|---|---|---|
  <one row/active rsf item; Specification = [ID] Title>

@doc adf-05-glossary.md
  ## Terms
  | Term | Definition |
  |---|---|
  <project, domain, integration, component, data + acronym terms>

@adr shape:
  # ADR-NNNN: <Decision Title>

  - **Status:** Accepted
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

  - **[<id>]:** <text>

  ## Verification Tests

  - **[<id>]:** <text>

@rules !
 1 read latest props/adf/v<R>/ first; select mode before writing anything
 2 mode propose: write exactly report.md, prop-a, prop-b, prop-own; never
   overwrite existing rounds; prop-c optional for a substantially different
   third strategy
 3 mode await: write nothing; report instructions and stop
 4 mode apply: write full ADF to adf/v<R>/; all core Status=Approved; all ADR
   Status=Accepted; mark accepted proposal Applied, all others Rejected; update
   report.md Result=Applied
 5 mode error: write nothing; report the ambiguity and stop
 6 prop-a is Recommended (simplest coherent architecture); prop-b differs in
   strategy, not wording; prop-own carries {{placeholders}} only
 7 ADP proposal Covers = "all active RSF items"; proposals are homogeneous
   within themselves
 8 ADR IDs start ADR-0001, contiguous; revision rounds reuse IDs from baseline
   where the decision is unchanged; new or changed decisions get new IDs
 9 Relevant Requirements + Verification Tests = non-empty item lists only;
   every item exactly `- **[<id>]:** <text>` where id = real RSF ID and text =
   its exact title; never invent IDs
10 trace every active FR NFR C E AC exactly once in
   adf-04-requirement-trace.md; use `—` plus reason where no
   component/interface/decision applies
11 every active FR maps to >=1 internal component and verification
12 component names identical across trace, internal, external, ADRs
13 Mermaid syntax valid; labels contain no raw Markdown links
14 relative links connect trace rows, components, interfaces + ADRs where useful
15 no source code or [ANN] blocks; signatures/contracts allowed, no impl bodies
16 no unresolved placeholders in written ADF files (prop-own is exempt)
17 every component|interface identifies exact pinned libraries it realizes;
   each trace row copies the item's comma-separated paths or `—`
18 link to library definitions; never duplicate full definitions; UI/design
   libraries appear in internal interfaces + relevant ADRs; external API,
   schema, protocol libraries appear in external architecture + integrations
19 no ADF decision silently changes a library rule
20 managed mode: never direct an implementation artefact to project root or
   sdais/**; RSF|library placement conflict -> return affected IDs to
   SemanticAuditor without writing the conflicting decision

@out
  Mode: propose | await | apply | error
  Proposal round written: v<R>  |  — (await / apply / error)
  ADF version written: v<R>  |  — (propose / await / error)
  Proposals written: <count>  |  — (await / apply / error)
  Applied proposal: <ADP-ID>  |  n/a
  Core documents: <count>  |  —
  ADRs: <count>  |  —
  Components defined: <count>  |  —
  Integrations documented: <count>  |  —
  RSF items traced: <list IDs>  |  n/a
  RSF items without architectural mapping: <list or "none">  |  n/a
no next-steps
