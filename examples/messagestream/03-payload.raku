#!/usr/bin/env rakupp
# MessageStream — The payload rules are not the option rules
# https://raku.online/modules/messagestream/#the-payload-rules-are-not-the-option-rules
#
# Install what it needs, then run it:
#     rakupp install MessageStream
#     rakupp 03-payload.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use MessageStream;

class Bus does MessageStream {
    has $.last is rw;
    method log-receive(MessageStream::Message:D $m) {
        $!last = ($m.payload, $m.options);
    }
}
my $b = Bus.new;
$b.subscribe(destination => 'log');

for 'hi', 42, 0, False, '', [1, 2, 3], [], (1, 2) -> $p {
    $b.post($p);
    my $got = $b.last[0];
    say sprintf('  post(%-12s) -> %-22s %s', $p.raku,
                ($got ~~ Positional ?? '(' ~ $got.map(*.raku).join(', ') ~ ')'
                                    !! $got.raku),
                $got.WHAT.^name);
}
say '';
say 'every FALSY payload becomes the empty string — the guard is a bare';
say '`if $payload`. Posting a zero count or an empty batch is data loss.';
say '';
say 'and a LIST payload has every element stringified while a scalar one';
say 'does not. Named options are untouched:';
$b.post([1, 2], l => [1, 2]);
say '  payload [1,2] -> ', $b.last[0].map(*.raku).join(', ');
say '  option  [1,2] -> ', $b.last[1]<l>.map(*.raku).join(', ');

# Output:
#       post("hi"        ) -> "hi"                   Str
#       post(42          ) -> 42                     Int
#       post(0           ) -> ""                     Str
#       post(Bool::False ) -> ""                     Str
#       post(""          ) -> ""                     Str
#       post($[1, 2, 3]  ) -> ("1", "2", "3")        Array
#       post($[]         ) -> ""                     Str
#       post($(1, 2)     ) -> ("1", "2")             Array
#     
#     every FALSY payload becomes the empty string — the guard is a bare
#     `if $payload`. Posting a zero count or an empty batch is data loss.
#     
#     and a LIST payload has every element stringified while a scalar one
#     does not. Named options are untouched:
#       payload [1,2] -> "1", "2"
#       option  [1,2] -> 1, 2
