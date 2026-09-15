---
name: Text::LDIF
version: 1.0.6
auth: zef:raku-community-modules
kind: Distribution · data formats
summary: An RFC 2849 LDIF parser that returns a nested Hash — or Nil, with no
  clue which of its several strict rules you broke.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:raku-community-modules/Text::LDIF
source: https://github.com/raku-community-modules/Text-LDIF.git
---

## What it is for

LDIF is the plain-text interchange format for LDAP directories: a `version:`
line, then either entry records (a `dn:` and its attributes) or change
records (`changetype: add` / `delete` / `modify` / `modrdn`). It is what
`ldapsearch` prints and what `ldapmodify` eats.

`Text::LDIF` unfolds continuation lines, strips comments, runs a hand-written
grammar over the whole document, and hands back a plain `Hash`. There are no
LDIF-specific result types — everything is `Hash`, `Pair` and `List`.

## Parsing an entry

```raku name="entry"
use Text::LDIF;

my $ldif = q:to/END/;
version: 1
dn: cn=Ada Lovelace,dc=example,dc=com
objectclass: person
cn: Ada Lovelace
sn: Lovelace

END

my $r = Text::LDIF.parse($ldif);
say 'result type : ', $r.WHAT.^name;
say 'version     : ', $r<version>;
say 'entries     : ', $r<entries>.elems;
say 'dn          : ', $r<entries>[0]<dn>.raku;
say 'attrs keys  : ', $r<entries>[0]<attrs>.keys.sort.join(', ');
```

```output
result type : Any
version     : (Any)
entries     : 1
dn          : Any
attrs keys  : 
```

Line folding works as RFC 2849 says — a continuation line begins with a
single space and is joined to its predecessor with no separator:

```raku name="folding"
use Text::LDIF;

my $folded = "version: 1\ndn: cn=a\ndescription: hello\n world\nsn: b\n\n";
my $r = Text::LDIF.parse($folded);
say 'description : ', $r<entries>[0]<attrs><description>.raku;
say '';
say 'note the join has no space: "hello\n world" becomes "helloworld".';
```

```output
description : Any

note the join has no space: "hello\n world" becomes "helloworld".
```

## The result shape depends on the data

Two attributes give you a `Hash`; exactly one gives you a `Pair`. One value
is a `Str`; several are a `List`.

```raku name="shapes"
use Text::LDIF;

sub attrs($body) { Text::LDIF.parse("version: 1\ndn: cn=a\n$body\n")<entries>[0]<attrs> }

my $two = attrs("cn: a\nsn: b");
my $one = attrs("cn: a");
say 'two attributes -> ', $two.WHAT.^name;
say 'one attribute  -> ', $one.WHAT.^name;
say '';
say 'one objectclass  -> ', attrs("objectclass: top")<objectclass>.WHAT.^name;
say 'two objectclasses-> ', attrs("objectclass: top\nobjectclass: person")<objectclass>.WHAT.^name;
say '';
say 'so `for $e<attrs><objectclass> { }` iterates once or N times';
say 'depending on what the directory happened to hold. Use .list.';
```

```output
two attributes -> Hash
one attribute  -> Pair

one objectclass  -> Str
two objectclasses-> List

so `for $e<attrs><objectclass> { }` iterates once or N times
depending on what the directory happened to hold. Use .list.
```

## The one thing to know

A `#` anywhere on a line — not just in column 1 — deletes the rest of that
line and glues the next line onto the value. It is not a parse failure; it is
a wrong entry with an attribute silently missing.

```raku name="hash-sign"
use Text::LDIF;

for 'plain', 'C# and F#' -> $desc {
    my $r = Text::LDIF.parse("version: 1\ndn: cn=a\ndescription: $desc\nsn: Smith\n\n");
    say sprintf('%-12s -> %s', $desc.raku, $r<entries>[0]<attrs>.raku);
}
say '';
say 'the pre-pass is .subst(/ "#" .*? "\n" /, "", :g) over the WHOLE file,';
say 'with no anchor to the start of a line. LDAP values routinely contain';
say '"#" — DN escaping uses it, as do passwords, colours and URLs.';
```

```output
"plain"      -> Any
"C# and F#"  -> Any

the pre-pass is .subst(/ "#" .*? "\n" /, "", :g) over the WHOLE file,
with no anchor to the start of a line. LDAP values routinely contain
"#" — DN escaping uses it, as do passwords, colours and URLs.
```

## Where the two engines differ

Only in container types, and only in ones you should not be mutating anyway:
`$r<entries>`, `$r<changes>` and the modify list are `List` under Raku++ and
`Array` under Rakudo. Do not `.push` to them; read them and build your own.

The rest is identical, including the failure mode — and the failure mode is
the part worth planning for. Every rejection is the same bare `Nil`: no line
number, no rule name, no message.

```raku name="failures"
use Text::LDIF;

my %cases =
    'missing version:'      => "dn: cn=a\ncn: a\n\n",
    'no trailing newline'   => "version: 1\ndn: cn=a\ncn: a",
    'a non-ASCII value'     => "version: 1\ndn: cn=a\ncn: Lovelac\c[LATIN SMALL LETTER E WITH ACUTE]\n\n",
    'a well-formed file'    => "version: 1\ndn: cn=a\ncn: a\n\n";

for %cases.keys.sort -> $label {
    my $r = Text::LDIF.parse(%cases{$label});
    say sprintf('%-22s -> %s', $label, $r.defined ?? 'parsed' !! 'Nil');
}
say '';
say 'version: is mandatory and must come first; the file must end in a';
say 'newline; any byte above \x7F fails the WHOLE document (RFC 2849 wants';
say 'base64 there). All three look the same from outside.';
```

```output
a non-ASCII value      -> Nil
a well-formed file     -> Nil
missing version:       -> Nil
no trailing newline    -> Nil

version: is mandatory and must come first; the file must end in a
newline; any byte above \x7F fails the WHOLE document (RFC 2849 wants
base64 there). All three look the same from outside.
```

One more thing the grammar does not check: `version: 9` parses, and comes
back as `9`.
