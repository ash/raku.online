---
title: The metaobject protocol  .^
slug: mop
status: full
order: 65
summary: Introspect types through their metaobject — MRO, parents, attributes, and signatures.
---

The `.^` operator calls a **metamethod** — a method on a type's metaobject — to ask
about its structure: its ancestors, attributes, and more.

## Method resolution order — .^mro

`.^mro` lists a type and its ancestors, in the order methods are resolved.

```raku
say Int.^mro.map(*.^name);
```
```output
(Int Cool Any Mu)
```

## Attributes — .^attributes

`.^attributes` returns a class's attributes; `.name` gives each one's `$!`-twigil
name.

```raku
class Point { has $.x; has $.y }
say Point.^attributes.map(*.name);
```
```output
($!x $!y)
```

## Introspecting a routine's signature

`&sub.signature.params` returns the parameter objects, so you can inspect a routine's
interface reflectively.

```raku
sub area($w, $h) {}
say &area.signature.params.map(*.name);
```
```output
($w $h)
```

## Notes

- `.^name` (the type's name) is fully supported — see
  [The type tower & introspection](/types/introspection/); `.^parents` gives the
  immediate superclasses.
- `.isa` tests strict **class** inheritance (`5.isa(Numeric)` is `False`, since
  `Numeric` is a role) — use `~~` for role/type membership.
- `.^methods` lists a type's methods; note it does not include the auto-generated
  bookkeeping methods (like `POPULATE`) that Rakudo also surfaces — the user-declared
  ones are all there.
