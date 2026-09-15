#!/usr/bin/env rakupp
# Pod::Literate — The one thing to know
# https://raku.online/modules/pod-literate/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install Pod::Literate
#     rakupp 03-guard.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Pod::Literate;

my $awkward = "=head1 NAME\n\nmy \$x = 1;\n";
with Pod::Literate.parse($awkward) -> $m {
    say 'parsed, pod chunks: ', $m<pod>.elems;
}
else {
    say 'did not parse — check for abbreviated pod or a missing trailing newline';
}

# Output:
#     did not parse — check for abbreviated pod or a missing trailing newline
