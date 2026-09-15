---
name: Digest::FNV
version: 0.1.1
auth: zef:tony-o
kind: Distribution · hashing
summary: The Fowler–Noll–Vo non-cryptographic hash in its three historical
  variants, at any of six widths from 32 to 1024 bits.
status: full
suite: 1 file, green
tested: 2026-09-15
license: none stated
depends: none beyond the core
raku-land: https://raku.land/zef:tony-o/Digest::FNV
source: git://github.com/tony-o/perl6-digest-fnv.git
---

## What it is for

FNV is the hash you reach for when you want speed and distribution and do not
care about an adversary: hash-table bucketing, bloom filters, checksum-ish
deduplication, cache keys. It is a multiply-and-xor over the input bytes with
a published offset basis, so implementations across languages agree — which
is the point, when the same key has to hash the same way in two systems.

## Hashing

```raku name="fnv"
use Digest::FNV :DEFAULT, :DEPRECATED;

my @v32 = '' => 0x811c9dc5, 'a' => 0xe40c292c, 'foobar' => 0xbf9cf968;
my @v64 = '' => 0xcbf29ce484222325, 'a' => 0xaf63dc4c8601ec8c,
          'foobar' => 0x85944171f73967e8;

say 'FNV-1a against the published reference vectors:';
for @v32 -> $p {
    my $g = fnv1a($p.key, :bits(32));
    say sprintf('  fnv1a(%-8s :bits(32)) = 0x%08x  expect 0x%08x  %s',
        "'{$p.key}'", $g, $p.value, $g == $p.value ?? 'ok' !! 'MISMATCH');
}
for @v64 -> $p {
    my $g = fnv1a($p.key, :bits(64));
    say sprintf('  fnv1a(%-8s :bits(64)) = 0x%016x  %s',
        "'{$p.key}'", $g, $g == $p.value ?? 'ok' !! 'MISMATCH');
}
```

```output
FNV-1a against the published reference vectors:
  fnv1a(''       :bits(32)) = 0x811c9dc5  expect 0x811c9dc5  ok
  fnv1a('a'      :bits(32)) = 0xe40c292c  expect 0xe40c292c  ok
  fnv1a('foobar' :bits(32)) = 0xbf9cf968  expect 0xbf9cf968  ok
  fnv1a(''       :bits(64)) = 0xcbf29ce484222325  ok
  fnv1a('a'      :bits(64)) = 0xaf63dc4c8601ec8c  ok
  fnv1a('foobar' :bits(64)) = 0x85944171f73967e8  ok
```

Both the 32- and 64-bit reference vectors pass, including the empty-string
offset basis.

## Widths and variants

```raku name="widths"
use Digest::FNV :DEFAULT, :DEPRECATED;

say 'default width  : ', fnv1a('foobar') == fnv1a('foobar', :bits(64)) ?? '64' !! '?';
say '';
for 32, 64, 128, 256 -> $b {
    say sprintf('  :bits(%-4d) -> %s', $b, fnv1a('foobar', :bits($b)).base(16).lc);
}
say '';
say 'fnv1  vs fnv1a differ by the order of xor and multiply:';
say '  fnv1  : ', fnv1('foobar');
say '  fnv1a : ', fnv1a('foobar');
say '  fnv0  : ', fnv0('foobar');
```

```output
default width  : 64

  :bits(32  ) -> bf9cf968
  :bits(64  ) -> 85944171f73967e8
  :bits(128 ) -> 343e1662793c64bf6f0d3597ba446f18
  :bits(256 ) -> b055ea2f306cadad4f0f81c02d3889dc32453dad5ae35b753ba1a91084af3428

fnv1  vs fnv1a differ by the order of xor and multiply:
  fnv1  : 3750802935296928194
  fnv1a : 9625390261332436968
  fnv0  : 833638993740285423
```

`:bits` accepts 32, 64, 128, 256, 512 and 1024; anything else fails the
parameter's `where` clause. Results are deterministic within a run, across
runs and across engines — there is no seeding and no randomisation.

## The import tags

`fnv0` sits behind the `:DEPRECATED` tag, and Raku's tag system **replaces**
rather than adds:

| you write | you get |
|---|---|
| `use Digest::FNV;` | `fnv1`, `fnv1a` |
| `use Digest::FNV :DEPRECATED;` | `fnv0` only — the other two are gone |
| `use Digest::FNV :DEFAULT, :DEPRECATED;` | all three |

That is why every example on this page names both tags.

## The one thing to know

The hash is computed over **codepoints masked to eight bits**, not over bytes,
so any two characters exactly 256 codepoints apart hash identically — and the
results do not match any other FNV implementation for non-ASCII input.

```raku name="mask-trap"
use Digest::FNV :DEFAULT, :DEPRECATED;

my ($a, $b) = "\x[00E9]", "\x[01E9]";     # é and ǩ
say 'codepoints    : ', $a.ords, ' and ', $b.ords;
say '489 +& 0xff   : ', 489 +& 0xff;
say 'fnv1a of each : ', fnv1a($a), ' and ', fnv1a($b);
say 'they collide  : ', fnv1a($a) == fnv1a($b);
say '';
my $h = 0xcbf29ce484222325;
for $a.encode('utf8').list { $h = (($h +^ $_) * 0x100000001B3) +& 0xffffffffffffffff }
say 'byte-oriented FNV-1a of the UTF-8 bytes : ', $h;
say 'this module agrees with it              : ', $h == fnv1a($a);
```

```output
codepoints    : (233) and (489)
489 +& 0xff   : 233
fnv1a of each : 12638336734137078692 and 12638336734137078692
they collide  : True

byte-oriented FNV-1a of the UTF-8 bytes : 775207407765167617
this module agrees with it              : False
```

Two lines of ordinary accented text produce a collision against a hash
function. The masking throws away the high bits of every codepoint above 255,
and because the 32- and 64-bit reference vectors are pure ASCII, the defect is
invisible to the very tests that would be written to check it.

For anything interoperable, encode first and hash the bytes — but note the
next section before you reach for `.encode`.

## Where the two engines differ

On a `Buf`. `Buf.new(102,111,111).^can('ords')` is `True` under Raku++ and
`False` under Rakudo, and the module guards with `return 0 unless
$data.^can('ords')` — so hashing binary data gives the correct hash on one
engine and a silent **`0`** on the other. That makes
`fnv1a($str.encode('utf8'))` an unportable workaround for the masking problem
above.

Two more things, identical on both. Any non-`Str` argument is accepted
silently: `fnv1a(42)` equals `fnv1a('42')` — numbers are stringified, not
hashed as numbers — and `fnv1a(Any)` returns **`0`**, which is a quiet way to
collapse a whole keyspace. And the unit name `Digest::FNV` does not exist as a
package: the file declares `Digest::FNV1` and the subs are plain lexicals, so
neither `Digest::FNV::fnv1a` nor `Digest::FNV1::fnv1a` is reachable. Only the
imported names work.

The distribution states no licence in its metadata.
