# CSV line counter

I want a small command line tool that tells me how many records are in a CSV
file. You give it a path, it prints a number. If the file has a header row that
row should not be counted as a record.

The record-counting and malformed-row behavior in this file adopts
`sdais/library/csv-records/v1/format.md` for the input format and definition of
a CSV record.

It needs to be fast even on big files.

The tool has to be written in Go and must not pull in any third-party
dependencies — standard library only.

When it runs it picks up the directory to look in from the SDAIS_DEMO_INPUT
environment variable, so you can pass a bare filename rather than a full path.

Malformed rows should be handled gracefully rather than crashing the whole run.

The output should follow our usual CLI conventions.
