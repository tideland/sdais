# CSV line counter

I want a small command line tool that tells me how many records are in a CSV file. You give it a path, it prints a number of valid and a number of invalid rows. The file has to have a header line and adopt `sdais/library/csv-records/v1/format.md` for the input format and definition of a CSV record.

It needs to be fast with at least 50,000 records per second linear even for files larger 1 GB.

The tool has to be written in Go and must not pull in any third-party dependencies — standard library only. The package structure should using a small main package running functions and types matching their individual tasks to realize this work. Goal is a separation of concerns.

When it runs it picks up the directory to look in from the SDAIS_DEMO_INPUT environment variable, so you can pass a bare filename or a relative filame rather than a full path. In case of an absulute path this will be taken.

Malformed rows should be handled gracefully rather than crashing the whole run. They shall be counted in parallel of the wellformed records to print both counters in the end.

The output should follow our usual CLI conventions with the filename or --help printing a help message. A correct runnung ends process with return code 0, otherwise with 1. Successful messages are printed on stdout, errors on stderr. First message is telling what the programming is doing, every 10,000 lines a small message tells "Processed <number> ...".

Errors are

- ERR 1 Invalid call - <detail>
- ERR 2 File not found
- ERR 3 File contains no headline
- ERR 4 Headline does not match definition
