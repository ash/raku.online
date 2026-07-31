---
title: Modules that work today
slug: working
status: partial
browser: false
browser-why: needs installed module distributions
rakulib: battery
order: 10
summary: The ecosystem modules verified to run under Raku++ — same code, same output as Rakudo — with what each depends on.
---

Raku++ runs real ecosystem modules from [raku.land](https://raku.land/), unmodified.
The measure here is the one `zef` itself applies: every file in a distribution's
`t/` directory is run at install time, and a module counts as working only when
**Raku++ passes every test file Rakudo passes**, on the same pinned sources. Not
an API probe — the distribution's own suite.

Of the 59 distributions in the battery, **18 clear that bar today**.

These examples can't run in the browser playground — the WebAssembly engine has no
module installation — so, like the IO pages, everything here is shown with output
verified against the real interpreter and Rakudo at build time.

## Passes its own test suite

Test *files*, not assertions: a file counts only when every assertion in it
passes. The sibling pages show verified examples for many of these.

| Module | Test files | Depends on |
|---|---:|---|
| Digest::SHA256::Native | 1 / 8 * | LibraryMake |
| Encode | 7 / 7 | — |
| File::Directory::Tree | 1 / 1 | — |
| File::Find | 1 / 1 | — |
| File::Temp | 3 / 3 | — |
| HTTP::Status | 3 / 3 | — |
| IO::Socket::SSL | 1 / 1 | OpenSSL |
| LibraryMake | 1 / 1 | File::Which, Shell::Command |
| OO::Monitors | 5 / 5 | — |
| Sparrow6 | 4 / 4 | Data::Dump, File::Directory::Tree, Hash::Merge, JSON::Fast, Terminal::ANSIColor, YAMLish |
| Sparrowdo | 1 / 1 | Sparrow6 |
| Terminal::ANSI | 8 / 8 | OO::Monitors |
| Terminal::ANSIColor | 1 / 1 | — |
| Test::When | 1 / 2 * | — |
| Text::Utils | 1 / 18 * | AlgorithmsIT, File::Temp, Font::AFM |
| Trap | 2 / 2 | — |
| URI::Encode | 2 / 2 | — |
| UUID | 1 / 1 | — |

A module's dependencies load through the same machinery, so a row like Sparrow6
means its whole tree — six other distributions — loads and runs well enough for
Sparrow6's own suite. Several of those dependencies have gaps in *their* suites,
and appear in the next table on their own account.

\* Rakudo does not pass every file here either, usually for want of a native
library or a network. Raku++ matches it file for file; the denominator is what
the distribution ships, not what either engine manages.

## Partly working

These load and do real work — several are only one or two files short — but at
least one file that passes under Rakudo does not yet pass here.

| Module | Raku++ | Rakudo | Depends on |
|---|---:|---:|---|
| Abbreviations | 2 / 9 | 9 / 9 | — |
| AttrX::Mooish | 9 / 35 | 35 / 35 | — |
| Base64 | 1 / 2 | 2 / 2 | — |
| Color | 1 / 8 | 8 / 8 | — |
| Config | 0 / 9 | 9 / 9 | Hash::Merge, IO::Glob, IO::Path::XDG, Log |
| Cro::Core | 1 / 9 | 9 / 9 | — |
| Cro::HTTP | 1 / 29 | 4 / 29 | Base64, Cro::Core, Cro::TLS, Crypt::Random, DateTime::Parse, HTTP::HPACK, IO::Path::ChildSecure, IO::Socket::Async::SSL, JSON::Fast, JSON::JWT, Log::Timeline, OO::Monitors |
| DBIish | 2 / 37 | 14 / 37 | — |
| Data::Dump | 1 / 9 | 9 / 9 | — |
| Date::Calendar::Strftime | 1 / 4 | 3 / 4 | Date::Names |
| Date::Names | 4 / 19 | 19 / 19 | Abbreviations |
| DateTime::Format | 2 / 3 | 2 / 3 | — |
| Digest | 1 / 4 | 4 / 4 | — |
| Digest::HMAC | 1 / 2 | 2 / 2 | — |
| File::Which | 4 / 6 | 6 / 6 | — |
| HTTP::Tiny | 2 / 10 | 10 / 10 | — |
| HTTP::UserAgent | 2 / 27 | 8 / 27 | DateTime::Parse, Encode, File::Temp, HTTP::Status, IO::Socket::SSL:ver:<0.0.4+>, MIME::Base64, URI |
| Hash::Merge | 1 / 3 | 3 / 3 | — |
| IO::Glob | 1 / 8 | 7 / 8 | Test, Test::META |
| JSON::Fast | 5 / 14 | 13 / 14 | — |
| JSON::Tiny | 5 / 6 | 5 / 6 | — |
| LWP::Simple | 7 / 18 | 18 / 18 | MIME::Base64, URI |
| Log | 3 / 4 | 4 / 4 | — |
| Log::Async | 3 / 17 | 17 / 17 | Terminal::ANSI |
| MIME::Base64 | 3 / 4 | 4 / 4 | — |
| Method::Also | 0 / 1 | 1 / 1 | — |
| NativeHelpers::Array | 2 / 3 | 2 / 3 | — |
| NativeHelpers::Blob | 1 / 4 | 4 / 4 | — |
| OpenSSL | 6 / 7 | 7 / 7 | — |
| Shell::Command | 0 / 1 | 1 / 1 | File::Find |
| Test::Output | 0 / 2 | 2 / 2 | — |
| URI | 3 / 14 | 14 / 14 | — |
| XML | 6 / 15 | 15 / 15 | — |
| YAMLish | 1 / 5 | 5 / 5 | MIME::Base64 |

## Not measurable here

Neither engine can run these on this machine, so they say nothing either way —
a missing C library, a missing toolchain, or no test files at all:

- Distribution::Builder::MakeFromJSON (ENV)
- IO::Path::XDG (NOTESTS)
- JSON::Class (ENV)
- Math::Libgsl::Constants (ENV)
- PDF::Lite (ENV)
- Term::termios (ENV)
- Test::META (ENV)

## Found while writing these pages

Writing verified examples is itself a test, and it surfaced deeper gaps in
five modules whose probed APIs pass: JSON::Tiny's `from-json` (and its
string escaping), XML's attribute parsing and `.elements`, UUID's string
formatting, Method::Also's `is also` aliases, and URI::Encode's `uri_decode`.
Each reduced to a general interpreter bug — sigspace quantifiers, the inline
`:ignoremark` adverb, `\cNN` escapes, UTF-16 code units, class assertions
with quote members, rule parameter defaults, list-assignment through `@`-attr
accessors, big-integer radix lists, list-valued named captures, and
method-trait dispatch with a workable `.HOW` — and all of them are fixed;
the richer examples are back on the sibling pages, verified byte-identical
on both engines.

## What is still blocking

The largest remaining gaps, counted in test files Rakudo passes and Raku++ does
not: AttrX::Mooish (26), Date::Names (15), Log::Async (14), DBIish (12), URI and
LWP::Simple (11 each), XML and Config (9 each). The Cro::HTTP stack and
HTTP::UserAgent are further out — both exercise the OpenSSL binding heavily.
Each is tracked with a reduced test case; this page updates as they land.

## Try one

A taste of what "just works" looks like — JSON round-tripping through
[JSON::Fast](https://raku.land/cpan:TIMOTIMO/JSON::Fast):

```raku
use JSON::Fast;
my %data = from-json('{"name":"Raku++","versions":[1,2]}');
say %data<name>;
say %data<versions>[*-1];
say to-json(%data, :sorted-keys, :!pretty);
```
```output
Raku++
2
{"name":"Raku++","versions":[1,2]}
```
