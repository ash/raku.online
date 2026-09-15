#!/usr/bin/env rakupp
# as-cli-arguments — Quoting is not escaping
# https://raku.online/modules/as-cli-arguments/#quoting-is-not-escaping
#
# Install what it needs, then run it:
#     rakupp install as-cli-arguments
#     rakupp 04-quoting.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use as-cli-arguments;

for (msg => 'hello world'), (url => 'http://x'), (who => "it's mine"), (v => Str) -> $p {
    say sprintf('  %-22s -> %s', $p.raku, as-cli-arguments($p).raku);
}
say '';
say 'quoting triggers on whitespace or ":" only. The quote character';
say 'itself is neither checked nor doubled, so a value containing an';
say 'apostrophe renders a string no shell will parse back.';
say '';
say 'and an undefined value renders as an empty string — a Pair gives';
say '--v= and a positional gives nothing at all, a silently dropped';
say 'argument.';

# Output:
#       :msg("hello world")    -> "--msg='hello world'"
#       :url("http://x")       -> "--url='http://x'"
#       :who("it's mine")      -> "--who='it's mine'"
#       :v(Str)                -> "--v="
#     
#     quoting triggers on whitespace or ":" only. The quote character
#     itself is neither checked nor doubled, so a value containing an
#     apostrophe renders a string no shell will parse back.
#     
#     and an undefined value renders as an empty string — a Pair gives
#     --v= and a positional gives nothing at all, a silently dropped
#     argument.
