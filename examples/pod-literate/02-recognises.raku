#!/usr/bin/env rakupp
# Pod::Literate — What it recognises
# https://raku.online/modules/pod-literate/#what-it-recognises
#
# Install what it needs, then run it:
#     rakupp install Pod::Literate
#     rakupp 02-recognises.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Pod::Literate;

sub try-parse($label, $text) {
    my $m = Pod::Literate.parse($text);
    say sprintf('%-32s -> %s', $label,
        $m.defined ?? "matched ({$m<pod>.elems} pod, {$m<code>.elems} code)" !! 'Nil');
}

try-parse 'delimited =begin/=end',      "=begin pod\nhi\n=end pod\nmy \$x = 1;\n";
try-parse 'abbreviated =head1',         "=head1 NAME\n\nmy \$x = 1;\n";
try-parse '=head1 inside =begin pod',   "=begin pod\n=head1 NAME\n=end pod\nmy \$x = 1;\n";
try-parse 'paragraph =for',             "=for comment\nthis\n\nmy \$x = 1;\n";
try-parse 'code only',                  "my \$x = 1;\n";
try-parse 'code, no trailing newline',  "my \$x = 1;";
try-parse 'empty string',               "";

# Output:
#     delimited =begin/=end            -> matched (1 pod, 1 code)
#     abbreviated =head1               -> Nil
#     =head1 inside =begin pod         -> matched (1 pod, 1 code)
#     paragraph =for                   -> Nil
#     code only                        -> matched (0 pod, 1 code)
#     code, no trailing newline        -> Nil
#     empty string                     -> matched (0 pod, 0 code)
