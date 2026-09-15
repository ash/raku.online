---
name: HTTP::ParseParams
version: 1.0.0
auth: none stated
kind: Distribution · HTTP
summary: Parse an HTTP cookie string or an x-www-form-urlencoded body into a
  hash, with the dialect chosen by a flag.
status: partial
suite: 1 file, green
tested: 2026-09-15
license: none stated
depends: URI::Encode
raku-land: https://raku.land/?/HTTP::ParseParams
source: git://github.com/retupmoca/P6-HTTP-ParseParams.git
---

## What it is for

Two of the oldest wire formats on the web are the query string and the cookie
header, and they are almost but not quite the same: one splits on `&`, the
other on `;`, and they disagree about percent-decoding. Anything writing an
HTTP server from the socket up needs both.

This distribution is one routine that does either, told which by a flag.

## Parsing a query string

```raku name="urlencoded"
use HTTP::ParseParams;

my %p = HTTP::ParseParams::parse('name=Ada&lang=raku&year=2026', :urlencoded);
say %p.keys.sort.map({ "$_={%p{$_}.raku}" }).join(' ');
say '';
say 'percent-decoded values:';
my %d = HTTP::ParseParams::parse('n=%48%69&s=a%20b', :urlencoded);
say '  ', %d.keys.sort.map({ "$_={%d{$_}.raku}" }).join(' ');
say '';
say 'it splits on ; as well as &:';
my %s = HTTP::ParseParams::parse('a=1;b=2', :urlencoded);
say '  ', %s.keys.sort.map({ "$_={%s{$_}.raku}" }).join(' ');
```

```output
lang="raku" name="Ada" year="2026"

percent-decoded values:
  n="Hi" s="a b"

it splits on ; as well as &:
  a="1" b="2"
```

Note the qualification. `parse` is declared in a `unit module` and is **not
exported** — you must write `HTTP::ParseParams::parse`.

## Cookies

```raku name="cookies"
use HTTP::ParseParams;

my %c = HTTP::ParseParams::parse('session=abc; theme=dark', :cookie);
say %c.keys.sort.map({ "$_={%c{$_}.raku}" }).join(' ');
say '';
say 'a repeated key gives a container rather than a Str:';
my %r = HTTP::ParseParams::parse('a=1; a=2; a=3', :cookie);
say '  the value for a is a ', %r<a>.^name;
say '  and a single key is a ', %c<session>.^name;
```

```output
session="abc" theme="dark"

a repeated key gives a container rather than a Str:
  the value for a is a Seq
  and a single key is a Str
```

Every caller therefore has to handle both types for the same key, which is a
condition you cannot know in advance from the wire.

## Choosing the dialect from a header

```raku name="content-type"
use HTTP::ParseParams;

my %p = HTTP::ParseParams::parse('a=1&a=2',
    :content-type<application/x-www-form-urlencoded>);
say 'via content-type : ', %p<a>.List.raku;
say '';
my $r = try HTTP::ParseParams::parse('a=1', :content-type<text/plain>);
say 'an unknown content type : ', $! ?? $!.message !! 'accepted';
my $n = try HTTP::ParseParams::parse('a=1');
say 'no dialect at all       : ', $! ?? $!.message !! 'accepted';
```

```output
via content-type : ("1", "2")

an unknown content type : Unable to understand content type text/plain
no dialect at all       : Nothing to do!
```

There is no default dialect. `:formdata` is declared and dies with `NYI`.

## The one thing to know

A key with no `=` crashes the parser, and so does the empty string.

```raku name="no-equals-trap"
use HTTP::ParseParams;

for 'a&b=2', '', 'debug&x=1' -> $q {
    my $r = try HTTP::ParseParams::parse($q, :urlencoded);
    say sprintf('%-12s -> %s', $q.raku, $! ?? 'threw' !! 'parsed');
}
say '';
say '?debug&x=1 is ordinary on the real web, and a request with no';
say 'query string at all gives you the empty string.';
```

```output
"a\&b=2"     -> threw
""           -> threw
"debug\&x=1" -> threw

?debug&x=1 is ordinary on the real web, and a request with no
query string at all gives you the empty string.
```

The split on `=` yields an undefined second element, and `uri_decode` requires
a `Str`. So `parse($query, :urlencoded)` on a request with no query string is
fatal, and a valueless flag in a query string is fatal.

Guard both before calling, or filter out the keyless pairs yourself.

## Where the two engines differ

On whether `parse` is visible without qualification. Raku++ puts `&parse` into
the importing scope; Rakudo does not, and refuses to compile a file that calls
it unqualified. So code written under one engine fails to compile on the
other. Qualify it, as every example here does.

The repeated-cookie container is also nested differently between the engines,
which makes its exact `.raku` unportable — `.list` on it is not.

Four things that are the same on both, and each one is a correctness bug for
the format this claims to parse. **`+` is not decoded to a space**, which is
wrong for `application/x-www-form-urlencoded`. **Keys are never
percent-decoded**, only values. **Cookie values are not percent-decoded at
all**, unlike urlencoded ones. And the distribution states no licence.
