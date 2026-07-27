---
title: say / print / put
slug: output
status: full
order: 10
summary: The three ways to write to standard output, and how each formats its argument.
---

Raku has three output routines that differ in how they format their argument and
whether they add a newline: `say` (human-readable + newline), `put` (string + newline),
and `print` (string, no newline).

## say vs put

`say` prints the **gist** — a readable summary — so a list shows in parentheses.
`put` prints the plain string form, which for a list joins the elements with
spaces. Both add a trailing newline.

```raku
say (1, 2, 3);
put (1, 2, 3);
```
```output
(1 2 3)
1 2 3
```

## print — no newline

`print` writes its argument with no trailing newline and no gist formatting, so you
control line breaks yourself.

```raku
print "a";
print "b";
print "\n";
```
```output
ab
```

## Notes

- `say $x` is `put $x.gist`; the gist is designed for people (it may truncate huge
  structures), whereas `.Str`/`put` gives the plain string.
- For debugging use `note`, which is exactly `say` but writes to **standard error**
  instead of standard output.
- `dd` (the "data dumper") prints a value's `.raku` representation to stderr — handy
  when you need to see exact structure and types.
