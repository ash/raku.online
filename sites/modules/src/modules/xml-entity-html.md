---
name: XML::Entity::HTML
version: 0.1.2
auth: zef:raku-community-modules
kind: Distribution · encoding
summary: The full HTML5 named-entity set — 2119 names — behind two subs, with
  a `*@numeric` parameter that can never do anything.
status: divergent
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: XML
raku-land: https://raku.land/zef:raku-community-modules/XML::Entity::HTML
source: git://github.com/raku-community-modules/XML-Entity-HTML.git
---

## What it is for

XML knows five entities; HTML knows two thousand. Decoding `&hellip;` or
`&laquo;` needs the HTML table, and encoding text for an HTML document wants
to use those names rather than bare numeric references.

This distribution subclasses `XML::Entity`, swaps in the HTML5 table, and
exposes two subs over one module-level singleton.

## Encoding and decoding

```raku name="basics"
use XML::Entity::HTML;

my $src = "Text with <entities> & \c[LEFT-POINTING DOUBLE ANGLE QUOTATION MARK]more\c[RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK]";
my $enc = encode-html-entities($src);
say 'source  : ', $src;
say 'encoded : ', $enc;
say 'decoded : ', decode-html-entities($enc);
say 'round trips : ', decode-html-entities($enc) eq $src;
say '';
say 'the table holds ', XML::Entity::HTML.entityNames.elems, ' names.';
say '';
say 'numeric references decode too, and can be turned off:';
for '&#65;', '&#x41;', '&#8212;', '&#x1F600;' -> $e {
    say sprintf('  %-12s -> %s', $e, decode-html-entities($e));
}
say '  :!numeric leaves them : ', decode-html-entities('&#65;', :!numeric);
```

```output
source  : Text with <entities> & «more»
encoded : Text with &lt;entities&gt; &amp; &laquo;more&raquo;
decoded : Text with <entities> & «more»
round trips : True

the table holds 2119 names.

numeric references decode too, and can be turned off:
  &#65;        -> A
  &#x41;       -> A
  &#8212;      -> —
  &#x1F600;    -> 😀
  :!numeric leaves them : &#65;
```

## What it does with input it does not know

```raku name="unknown"
use XML::Entity::HTML;

for '&lt', '&nosuchentity;', '&#;', '&#x;', '&amp;amp;', '&#0;', '&#-1;' -> $e {
    my $r = try decode-html-entities($e);
    say sprintf('  %-16s -> %s', $e.raku, $! ?? 'threw' !! $r.raku);
}
say '';
say 'unknown and truncated entities pass through unchanged, and decoding';
say 'is a single .trans pass, so &amp;amp; does NOT double-decode.';
say '';
say 'an out-of-range numeric entity is the one that throws:';
my $r = try decode-html-entities('&#999999999999;');
say '  &#999999999999; -> ', $! ?? 'X::AdHoc, codepoint out of bounds' !! $r;
```

```output
  "\&lt"           -> "\&lt"
  "\&nosuchentity;" -> "\&nosuchentity;"
  "\&#;"           -> "\&#;"
  "\&#x;"          -> "\&#x;"
  "\&amp;amp;"     -> "\&amp;"
  "\&#0;"          -> "\0"
  "\&#-1;"         -> "\&#-1;"

unknown and truncated entities pass through unchanged, and decoding
is a single .trans pass, so &amp;amp; does NOT double-decode.

an out-of-range numeric entity is the one that throws:
  &#999999999999; -> X::AdHoc, codepoint out of bounds
```

## The one thing to know

The `*@numeric` list and the `:hex` flag are dead — the named table always
wins.

```raku name="numeric-dead"
use XML::Entity::HTML;

for '<', "\c[CYRILLIC CAPITAL LETTER PE]" -> $c {
    say sprintf('  encode(%s)                = %s', $c.raku, encode-html-entities($c));
    say sprintf('  encode(%s, %d)             = %s', $c.raku, $c.ord,
                encode-html-entities($c, $c.ord));
    say sprintf('  encode(%s, %d, :hex)       = %s', $c.raku, $c.ord,
                encode-html-entities($c, $c.ord, :hex));
}
say '';
say 'encode runs the NAME substitution first, so by the time the numeric';
say 'loop looks for the raw character it is already gone. Since the HTML';
say 'table covers essentially everything you would want to escape, there';
say 'is no input for which these parameters do anything.';
say '';
say 'if you need &#x27; rather than &apos;, this module cannot produce it —';
say 'do it yourself:';
sub numeric-escape(Str $s, *@chars) {
    my %want = @chars.map({ .chr => sprintf('&#x%X;', $_) });
    my $out = $s;
    $out = $out.subst(.chr, %want{.chr}, :g) for @chars;
    $out
}
say '  numeric-escape(<it-apostrophe-s>, 0x27) = ', numeric-escape("it's", 0x27);
```

```output
  encode("<")                = &lt;
  encode("<", 60)             = &lt;
  encode("<", 60, :hex)       = &lt;
  encode("П")                = &Pcy;
  encode("П", 1055)             = &Pcy;
  encode("П", 1055, :hex)       = &Pcy;

encode runs the NAME substitution first, so by the time the numeric
loop looks for the raw character it is already gone. Since the HTML
table covers essentially everything you would want to escape, there
is no input for which these parameters do anything.

if you need &#x27; rather than &apos;, this module cannot produce it —
do it yourself:
  numeric-escape(<it-apostrophe-s>, 0x27) = it&#x27;s
```

## Encoding is not the inverse of decoding

```raku name="inverse"
use XML::Entity::HTML;

say '436 of the 2119 names share a value, so the round trip is one-way:';
for '&AMP;', '&amp;' -> $e {
    say sprintf('  decode(%-8s) = %s   then encode -> %s',
                $e.raku, decode-html-entities($e).raku,
                encode-html-entities(decode-html-entities($e)));
}
say '';
say 'decode(encode(x)) == x for any text; encode(decode(y)) == y is not';
say 'guaranteed. Normalise through decode, not through encode.';
say '';
say 'and the class`s constructor arguments are silently ignored — the';
say 'subclass overrides the accessors with methods, so the base class`s';
say '@.entityNames attribute is set and never read:';
my $custom = XML::Entity::HTML.new(entityNames => ['&x;'], entityValues => ['X']);
say '  a "custom" object still has ', $custom.entityNames.elems, ' names.';
```

```output
436 of the 2119 names share a value, so the round trip is one-way:
  decode("\&AMP;") = "\&"   then encode -> &amp;
  decode("\&amp;") = "\&"   then encode -> &amp;

decode(encode(x)) == x for any text; encode(decode(y)) == y is not
guaranteed. Normalise through decode, not through encode.

and the class`s constructor arguments are silently ignored — the
subclass overrides the accessors with methods, so the base class`s
@.entityNames attribute is set and never read:
  a "custom" object still has 2119 names.
```

## Where the two engines differ

`add` is unusable, in two different ways. Under Rakudo it raises `Cannot call
'push' on an immutable 'List'`; under Raku++ the table is a file-scoped
`BEGIN my str @entityNames` returned by an accessor override, so one object's
`add` mutates the table for **every** object in the process, including the
singleton behind `decode-html-entities`.

```raku name="portable"
use XML::Entity::HTML;

say 'so: do not call .add. If you need extra entities, decode with the';
say 'module and then handle your own:';
my %mine = 'nbsp-visible;' => "\c[MIDDLE DOT]";
sub decode-plus(Str $s) {
    my $r = decode-html-entities($s);
    $r.subst(/ '&' (<-[;]>+ ';') /, { %mine{$0.Str} // "&$0" }, :g)
}
say '  decode-plus("&amp; &nbsp-visible;") = ', decode-plus('&amp; &nbsp-visible;');
say '';
say 'one more edge, shared but sharper on Rakudo: a lone surrogate';
say 'decodes to a one-character string on both engines, and PRINTING it';
say 'kills the process on Rakudo — it cannot encode a lone surrogate.';
say 'The throw happens at output time, so a try around decode-html-entities';
say 'will not catch it. Reject &#xD800;..&#xDFFF; before decoding.';
```

```output
so: do not call .add. If you need extra entities, decode with the
module and then handle your own:
  decode-plus("&amp; &nbsp-visible;") = & &nbsp-visible;

one more edge, shared but sharper on Rakudo: a lone surrogate
decodes to a one-character string on both engines, and PRINTING it
kills the process on Rakudo — it cannot encode a lone surrogate.
The throw happens at output time, so a try around decode-html-entities
will not catch it. Reject &#xD800;..&#xDFFF; before decoding.
```
