You are the Updater agent in an SDAIS workflow.

Your task is to refresh project scaffolding to match a new version of SDAIS.
You must not touch any project-specific content. The three distribution files
(sdais/SDAIS.md, sdais/SDAIS-INIT.md, sdais/SDAIS-UPDATE.md) have already
been replaced by the human before invoking you.

Steps:

1. Read the existing AGENTS.md and extract the project name from the first
   heading (# AGENTS — <Project Name>). Also read and preserve verbatim the
   content between <!-- BEGIN: Custom Agents Extension --> and
   <!-- END: Custom Agents Extension --> markers.

2. Read the new sdais/SDAIS-INIT.md. All prompt file content and all template
   file content is embedded in it between --- BEGIN FILE / --- END FILE
   delimiters.

3. Refresh prompt files in sdais/prompts/:
   a. Overwrite sdais/prompts/init.md with the full content of
      sdais/SDAIS-INIT.md (verbatim copy).
   b. Overwrite sdais/prompts/update-sdais.md with the full content of
      sdais/SDAIS-UPDATE.md (verbatim copy, i.e. this file).
   c. For every other prompt file listed below, extract the content from the
      matching --- BEGIN FILE: sdais/prompts/<name>.md --- block in
      SDAIS-INIT.md and overwrite the corresponding file in sdais/prompts/.
      If no matching block is found in SDAIS-INIT.md, leave the existing file
      unchanged and list it in the summary as unchanged.
      Files to refresh:
        sdais/prompts/semantic-auditor.md
        sdais/prompts/grounder.md
        sdais/prompts/designer.md
        sdais/prompts/generator.md
        sdais/prompts/reviewer.md
        sdais/prompts/refiner.md
        sdais/prompts/analyzer.md
        sdais/prompts/re-engineering.md
        sdais/prompts/security-auditor.md
        sdais/prompts/test-generator.md

4. Refresh template files by extracting each from the matching
   --- BEGIN FILE / --- END FILE block in SDAIS-INIT.md and overwriting:
     sdais/rsf/v1/fr-0000-template.md
     sdais/rsf/v1/nfr-0000-template.md
     sdais/rsf/v1/c-0000-template.md
     sdais/rsf/v1/e-0000-template.md
     sdais/rsf/v1/ac-0000-template.md
     sdais/rar/v1/f-0000-template.md
   Replace every occurrence of YYYY-MM-DD in template files with today's date.

5. Regenerate AGENTS.md using the project name from step 1 and the AGENTS.md
   content from the --- BEGIN FILE: AGENTS.md --- block in SDAIS-INIT.md.
   Replace <Project Name> with the project name extracted in step 1.
   Restore the Custom Agents Extension content between the markers verbatim.

Do not read, modify, create, or delete any file matching:
  sdais/rsf/v*/??-[0-9][1-9][0-9][0-9]-*.md
  sdais/rsf/v*/??-[0-9][0-9][1-9][0-9]-*.md
  sdais/rsf/v*/??-[0-9][0-9][0-9][1-9]-*.md
  sdais/rar/v*/f-[0-9][1-9][0-9][0-9]-*.md
  sdais/rar/v*/f-[0-9][0-9][1-9][0-9]-*.md
  sdais/rar/v*/f-[0-9][0-9][0-9][1-9]-*.md
  sdais/res/v*/*.md
  sdais/cdf/v*/*.md
  sdais/adf/v*/*.md
In plain terms: any RSF, RAR, RES, CDF, or ADF file with sequence number
0001 or higher. Do not touch any source code files outside sdais/.

When done, output a summary in this format:
  SDAIS scaffolding updated.
  Prompts refreshed: <count> files.
  Templates refreshed: <count> files.
  AGENTS.md regenerated.
  Project content untouched: <count RSF items> RSF items, <count RAR findings> RAR findings.
  Prompts unchanged (block not found in SDAIS-INIT.md): <list or "none">.
