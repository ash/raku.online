#!/usr/bin/env rakupp
# as-cli-arguments — The one thing to know
# https://raku.online/modules/as-cli-arguments/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install as-cli-arguments
#     rakupp 03-strings.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use as-cli-arguments;

my $r = try as-cli-arguments(\(1, 2));
say 'as-cli-arguments(\(1, 2))        -> ', $! ?? 'threw ' ~ $!.^name !! $r.raku;
my $p = count => 42;
my $r2 = try as-cli-arguments($p);
say 'a Pair with an Int value         -> ', $! ?? 'threw ' ~ $!.^name !! $r2.raku;
say '';
say 'the private stringify is declared --> Str:D and returns its argument';
say 'UNCHANGED whenever it is defined and holds no whitespace or colon —';
say 'so for anything that is not a Str the RETURN type-check fires.';
say '';
say 'stringify your own values first:';
say '  ', as-cli-arguments(\('1', '2')).raku;
my $ok = count => '42';
say '  ', as-cli-arguments($ok).raku;
say '';
say 'the failure happens on the most ordinary input imaginable — a numeric';
say 'option value — and the API gives no hint that .Str is needed.';

# Output:
#     as-cli-arguments(\(1, 2))        -> threw X::TypeCheck::Return
#     a Pair with an Int value         -> threw X::TypeCheck::Return
#     
#     the private stringify is declared --> Str:D and returns its argument
#     UNCHANGED whenever it is defined and holds no whitespace or colon —
#     so for anything that is not a Str the RETURN type-check fires.
#     
#     stringify your own values first:
#       "1 2"
#       "--count=42"
#     
#     the failure happens on the most ordinary input imaginable — a numeric
#     option value — and the API gives no hint that .Str is needed.
