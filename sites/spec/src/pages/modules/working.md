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
The list below comes from a test battery of popular distributions: each module's
advertised API is exercised under Raku++ **and** Rakudo on the same pinned sources,
and counts as working only when the output is **byte-identical** on both. The
sibling pages show verified examples for many of them.

These examples can't run in the browser playground — the WebAssembly engine has no
module installation — so, like the IO pages, everything here is shown with output
verified against the real interpreter and Rakudo at build time.

## Verified working

| Module | Depends on |
|---|---|
| Base64 | — |
| Color | — |
| Config | Hash::Merge, IO::Glob, IO::Path::XDG, Log |
| Cro::Core | — |
| Data::Dump | — |
| Date::Calendar::Strftime | Date::Names |
| DateTime::Format | — |
| Digest | — |
| Digest::HMAC | — |
| File::Directory::Tree | — |
| File::Find | — |
| File::Temp | File::Directory::Tree |
| File::Which | — |
| HTTP::Status | — |
| HTTP::Tiny | — |
| JSON::Fast | — |
| JSON::Tiny | — |
| LWP::Simple | MIME::Base64, URI |
| LibraryMake | Shell::Command, File::Which |
| MIME::Base64 | — |
| Method::Also | — |
| NativeHelpers::Array | — |
| NativeHelpers::Blob | — |
| OO::Monitors | — |
| Shell::Command | File::Find |
| Sparrow6 | File::Directory::Tree, Hash::Merge, YAMLish, JSON::Fast, Data::Dump, Terminal::ANSIColor |
| Sparrowdo | Sparrow6 |
| Term::termios | Distribution::Builder::MakeFromJSON |
| Terminal::ANSIColor | — |
| Test::Output | Trap |
| Test::When | — |
| URI | — |
| URI::Encode | — |
| UUID | — |
| XML | — |
| YAMLish | MIME::Base64 |

A module's dependencies load through the same machinery, so a row like Sparrow6
means its whole tree — six other distributions — works too.

## Found while writing these pages

Writing verified examples is itself a test, and it surfaced deeper gaps in
five modules whose probed APIs pass: JSON::Tiny's `from-json` (and its
string-key escaping), XML's attribute parsing and `.elements`, UUID's string
formatting, Method::Also's `is also` aliases, and URI::Encode's `uri_decode`. Their rows stay in the table above —
what the battery exercises does work — and each gap is now a tracked
interpreter bug. The examples on the sibling pages show only what runs
byte-identically on both engines today.

## Not there yet

The battery also tracks modules that don't fully work: the Cro::HTTP stack and
HTTP::UserAgent (both blocked on the OpenSSL binding), DBIish, Test::META,
JSON::Class, PDF::Lite, Terminal::ANSI and Log::Async (both need OO::Monitors'
`unit monitor` declarator form), and a few whose native C libraries simply
aren't present on the test machine. Each is tracked with a reduced test case;
this page updates as they land.

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
