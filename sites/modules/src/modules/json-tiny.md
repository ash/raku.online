---
name: JSON::Tiny
version: 1.0
auth: cpan:MORITZ
kind: Distribution · data format
summary: The original Raku JSON module — two exported subs around a grammar
  small enough to read in one sitting, and clean enough to subclass when your
  "JSON" has comments in it.
status: full
license: Artistic-2.0
suite: 6 files, green
tested: 2026-08-28
raku-land: https://raku.land/cpan:MORITZ/JSON::Tiny
source: https://github.com/moritz/json
---

## What it is for

Reading and writing JSON, with the least possible module between you and the
data. `from-json` takes a string and gives you Raku values; `to-json` goes
the other way; strings, numbers, arrays, hashes, booleans and `null` are the
whole vocabulary, exactly as the format defines it:

```raku name="round-trip"
use JSON::Tiny;

my $config = from-json('{"name":"raku","stars":4.5,"tags":["fast","fun"],"beta":false,"next":null}');
say $config<name>;
say $config<stars> * 2;
say $config<tags>[1];
say $config<beta>.^name;
say $config<next>.defined;
say to-json(['a', 'b', 'c']);
```

```output
raku
9
fun
Bool
False
[ "a", "b", "c" ]
```

Thirty-eight other distributions depend on it, which makes it the second
most-used JSON module in the ecosystem — [JSON::Fast](/modules/json-fast/)
is the first, is faster, and has more adverbs. If all you want is JSON in
and JSON out, use JSON::Fast. What this module has that its successor does
not is a public, subclassable **grammar** — more on that below, because it
is the reason this page exists.

## Numbers come back typed

Like JSON::Fast, this module maps JSON's one number type onto the Raku
numeric that loses nothing: integers arrive as `Int`, decimal fractions as
`Rat` — so `0.6` really equals `3/5`, with none of the floating-point fuzz —
and only exponent notation becomes `Num`:

```raku name="number-types"
use JSON::Tiny;

my $data = from-json('{"count": 42, "ratio": 0.6, "big": 1e10}');
say $data<count>.^name;
say $data<ratio>.^name;
say $data<ratio> == 3/5;
say $data<big>.^name;
```

```output
Int
Rat
True
Num
```

Input that is not JSON throws a typed exception, `X::JSON::Tiny::Invalid`,
with the offending source on it:

```raku name="invalid-input"
use JSON::Tiny;

say from-json('{"unclosed": [1, 2');
CATCH {
    when X::JSON::Tiny::Invalid { say "not JSON: {.source.chars} characters rejected" }
}
```

```output
not JSON: 18 characters rejected
```

One caution on the writing side: a Raku `Hash` does not promise a key
order, so `to-json` on a multi-key hash can print its pairs in a different
order from one run to the next. The JSON is equally valid either way, but
if a test or a cache key depends on the exact string, sort upstream — or
use JSON::Fast, whose `:sorted-keys` exists for exactly this.

## The grammar is the documentation

The whole parser is [one grammar of about thirty
lines](https://github.com/moritz/json), and it reads almost like the JSON
specification's railroad diagrams:

```raku fragment
token TOP       { \s* <value> \s* }
rule object     { '{' ~ '}' <pairlist>     }
rule pairlist   { <pair> * % \,            }
rule pair       { <string> ':' <value>     }
rule array      { '[' ~ ']' <arraylist>    }
rule arraylist  {  <value> * % [ \, ]      }

proto token value {*};
token value:sym<number> { '-'? [ 0 | <[1..9]> <[0..9]>* ] [ \. <[0..9]>+ ]? … }
```

This is the module people read to learn what Raku grammars look like in
production: `'{' ~ '}'` for delimiter pairs, `* % \,` for comma-separated
lists, a `proto token` dispatching on what a value starts with. If you are
working through [the tour's grammar lessons](/tour/grammars/), this is the
graduation text.

## Subclass it: JSON with comments

Because the grammar is public, dialects are one inheritance away. Config
files that are "JSON plus `//` comments" are everywhere; here is the whole
parser for them. The `rule`-based productions skip whitespace via the
grammar's `ws` token, so teaching `ws` to also swallow comments extends
every rule at once:

```raku name="json-with-comments"
use JSON::Tiny::Grammar;
use JSON::Tiny::Actions;

grammar JSON::WithComments is JSON::Tiny::Grammar {
    token ws { [ \s | '//' \N* ]* }
}

my $config = q:to/END/;
    {
        "port": 8080,       // where to listen
        "workers": 4,       // one per core
        "debug": false
    }
    END

my $m = JSON::WithComments.parse($config, :actions(JSON::Tiny::Actions.new));
my %conf = $m.made;
say %conf<port>;
say %conf<workers>;
say %conf<debug>;
```

```output
8080
4
False
```

The stock `JSON::Tiny::Actions` still builds the data, because the shape of
the parse tree did not change — only what counts as ignorable space did.
The same trick with `%%` instead of `%` in `pairlist` and `arraylist`
tolerates trailing commas; ten minutes of grammar subclassing covers most
of what "JSON5" is for.

## Where the two engines differ

Nothing on this page. Parsing, the typed numbers, the exception, and the
subclassed grammar behave identically under Raku++ and Rakudo — including
the hash-order caveat above, which is a property of hashes on both engines
rather than of either JSON module.

## What was run to put this page here

1. **Parse** — every file of the distribution is parsed by Raku++ itself.
2. **Install** — `rakupp install JSON::Tiny`; it depends on nothing outside
   the core.
3. **Test** — the distribution's own suite: 6 files, green.
4. **Run** — every example on this page, twice under each engine, as the
   site is built.

The suite going green needed no fixes on either side — but it is worth
saying that the suite includes the grammar being exercised in both
directions over every corner case JSON has, so "6 files, green" here means
the *grammar engine* under Raku++ agrees with Rakudo's on backtracking,
`proto` token dispatch, `~` goal matching and sigspace. This module is
small; what it tests is not.
