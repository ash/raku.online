---
name: Algorithm::ZobristHashing
version: 0.0.6
auth: zef:titsuki
kind: Distribution · algorithms
summary: Zobrist hashing — a random value per (position, piece) pair, XORed
  together — so a one-square change costs two more XORs rather than a rehash.
status: full
suite: 1 file, green
tested: 2026-09-15
license: Artistic-2.0
depends: none beyond the core
raku-land: https://raku.land/zef:titsuki/Algorithm::ZobristHashing
source: https://github.com/titsuki/raku-Algorithm-ZobristHashing.git
---

## What it is for

A chess engine looks at millions of positions a second and needs to know
whether it has seen each one before. Rehashing a whole board per node is the
wrong shape of work, because consecutive positions differ by one move.

Zobrist hashing fixes that. Give every `(square, piece)` pair a random number,
XOR one per square to hash the board, and then a single move is
`hash ^ old ^ new` — two XORs, regardless of board size. That incremental
property is the entire point.

## Hashing a board

Every value here is drawn at random, so what an example can show is the
**property**:

```raku name="zobrist"
use Algorithm::ZobristHashing;

my $z = Algorithm::ZobristHashing.new;

my $h = $z.encode('abc');
my $x = $z.get(0, 'a') +^ $z.get(1, 'b') +^ $z.get(2, 'c');
say 'a hash is the XOR of its per-(position,piece) keys : ', $h == $x;

say 'stable within one instance    : ', $z.encode('abc') == $z.encode('abc');
say 'different across instances    : ',
    Algorithm::ZobristHashing.new.encode('abc') != Algorithm::ZobristHashing.new.encode('abc');
say 'position matters, not just content : ', $z.encode('ab') != $z.encode('ba');
```

```output
a hash is the XOR of its per-(position,piece) keys : True
stable within one instance    : True
different across instances    : True
position matters, not just content : True
```

Two instances disagree because each draws its own table. That is correct for
Zobrist hashing and worth planning around: the table is per-object, drawn
lazily, and **not persistable** — there is no seed parameter and no way to
serialise `$!table`, so a transposition table cannot be written to disk and
read back.

## The incremental update

```raku name="incremental"
use Algorithm::ZobristHashing;

my $z = Algorithm::ZobristHashing.new;

my @board = <r n b q k b n r>;
my $before = $z.encode(@board);

my @after = @board.clone;
@after[3] = 'Q';

my $incremental = $before +^ $z.get(3, 'q') +^ $z.get(3, 'Q');

say 'full rehash of the new board equals the incremental update : ',
    $z.encode(@after) == $incremental;
```

```output
full rehash of the new board equals the incremental update : True
```

That identity is the one property that actually matters for the intended use,
and it holds exactly.

## What counts as input

```raku name="input"
use Algorithm::ZobristHashing;

my $z = Algorithm::ZobristHashing.new;

say 'a Str is split into characters : ', $z.encode('ab') == $z.encode(['a', 'b']);
say 'elements are stringified       : ', $z.encode('12') == $z.encode([1, 2]);
say 'so "ab" is not ["ab"]          : ', $z.encode('ab') != $z.encode(['ab']);
say '';
say 'nested arrays are FLATTENED, so structure is lost:';
say '  [[1,2],[3,4]] == [1,2,3,4] : ', $z.encode([[1,2],[3,4]]) == $z.encode([1,2,3,4]);
say '  [[1],[2,3,4]] == [1,2,3,4] : ', $z.encode([[1],[2,3,4]]) == $z.encode([1,2,3,4]);
```

```output
a Str is split into characters : True
elements are stringified       : True
so "ab" is not ["ab"]          : True

nested arrays are FLATTENED, so structure is lost:
  [[1,2],[3,4]] == [1,2,3,4] : True
  [[1],[2,3,4]] == [1,2,3,4] : True
```

A two-dimensional board must be flattened by you if you care which flattening
was used, because the module will flatten it either way and the two are
indistinguishable afterwards.

## The one thing to know

The default hash is **30 bits wide**, not 64. The table entries are drawn from
`0 ..^ 1e9`, and XOR cannot widen them.

```raku name="width-trap"
use Algorithm::ZobristHashing;

my $z = Algorithm::ZobristHashing.new;               # default rand-max = 1e9
my @h = (^500).map({ $z.encode([$_, 'x', $_ * 7]) });
say 'default rand-max 1e9';
say '  widest hash seen over 500 inputs : ', @h.map(*.base(2).chars).max, ' bits';
say '  any hash >= 2**30                : ', ?@h.grep(* >= 2**30);

my $w = Algorithm::ZobristHashing.new(rand-max => 2**64);
my @w = (^500).map({ $w.encode([$_, 'x', $_ * 7]) });
say '';
say 'rand-max => 2**64';
say '  widest hash seen over 500 inputs : ', @w.map(*.base(2).chars).max, ' bits';
say '';
say '2**30 is ', 2**30, ', so the birthday bound is around ', (2**30).sqrt.round;
```

```output
default rand-max 1e9
  widest hash seen over 500 inputs : 30 bits
  any hash >= 2**30                : False

rand-max => 2**64
  widest hash seen over 500 inputs : 64 bits

2**30 is 1073741824, so the birthday bound is around 32768
```

A real 64-bit Zobrist needs on the order of five billion positions before a
collision. At 30 bits the birthday bound is near 32,000, and in practice the
first collision turned up between twenty and a hundred thousand distinct
inputs across several runs. For a transposition table that is not a lot of
positions.

Nothing in the API hints at it — `rand-max` looks like a tuning knob rather
than a correctness one. The fix is one named argument:
`Algorithm::ZobristHashing.new(rand-max => 2**64)`.

## Where the two engines differ

Nowhere in behaviour. Every property in this page held identically on Raku++
and Rakudo; the numbers themselves are random and differ per object, per run
and per engine, as they must.

One more thing, and it is the shape of a bug you will not see coming.
`encode` on **empty input returns the `Int` type object**, not `0` and not a
failure. `if $hash { … }` and `$hash // $default` both treat it as absent,
`$hash == 0` warns, and storing it in a `my Int $h` succeeds. Guard with
`.defined`.
