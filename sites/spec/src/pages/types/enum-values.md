---
title: Enums with explicit values
slug: enum-values
status: full
order: 45
summary: Assign chosen underlying values to enum names instead of the 0,1,2 default.
---

Beyond the counting-from-zero default ([Enums](/types/enums/)), an enum can pin
each name to a **chosen** value with a list of pairs — ideal for codes like HTTP
statuses or bit flags.

## Assigning values

```raku
enum HttpStatus (OK => 200, NotFound => 404);
say OK;
say OK.value;
say NotFound.value;
```
```output
OK
200
404
```

`OK` stringifies to its name but carries `200` as its value — so it reads well *and*
compares numerically.

## Comparing and listing

An enum value compares against its underlying number, and `.enums` gives back the
whole name-to-value map.

```raku
enum HttpStatus (OK => 200, NotFound => 404);
my $code = 404;
say $code == NotFound;
say HttpStatus.enums.sort;
```
```output
True
(NotFound => 404 OK => 200)
```

## Notes

- Names still work as bare terms and smartmatch in `when`; `$code == NotFound` is
  `True` when `$code` is `404`.
- Mixed forms are allowed: unlisted names continue counting from the previous value.
- Enum values are `Int`-based here, but any type works — `enum Size (S => "small", …)`
  makes string-valued constants.
