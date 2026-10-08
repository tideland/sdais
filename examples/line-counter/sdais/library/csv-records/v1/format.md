# CSV Records Format

This file defines version 1 of the line-counter fixture's input format.

## File structure

- A file is UTF-8 text using LF or CRLF line endings.
- The comma character separates fields.
- The first row is the header and is exactly
  `id,name,email,amount,created_at`.
- Every later row is a data record with exactly five fields in that order.
- A field may be enclosed in double quotes. Inside a quoted field, two
  consecutive double quotes represent one literal double quote.

## Field forms

- `id` is a positive decimal integer.
- `name` and `email` are non-empty text.
- `amount` is a decimal number with exactly two fractional digits.
- `created_at` is a UTC timestamp in `YYYY-MM-DDThh:mm:ssZ` form.

This contract defines syntax only. Requirements adopting it separately define
how valid records are counted and how malformed rows are handled.
