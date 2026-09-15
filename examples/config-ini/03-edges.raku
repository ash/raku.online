#!/usr/bin/env rakupp
# Config::INI — What the grammar accepts
# https://raku.online/modules/config-ini/#what-the-grammar-accepts
#
# Install what it needs, then run it:
#     rakupp install Config::INI
#     rakupp 03-edges.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Config::INI;

sub show($label, $text) {
    my $r = try Config::INI::parse($text);
    say sprintf('%-32s -> %s', $label,
        $r.defined ?? 'parsed, ' ~ $r.keys.sort.join(',') !! 'Nil');
}

show 'value containing =',        "a=b=c\n";
show 'key containing a space',    "my key = v\n";
show 'bracket inside a key',      "[s]\na[0]=1\n";
show 'section name with spaces',  "[my section]\nk=v\n";
show 'indented key',              "   a = b\n";
show 'CRLF line endings',         "a=b\r\n";
show 'only comments',             "# hi\n; there\n";
show 'no equals sign at all',     "just words\n";

# Output:
#     value containing =               -> parsed, _
#     key containing a space           -> parsed, _
#     bracket inside a key             -> parsed, s
#     section name with spaces         -> parsed, my section
#     indented key                     -> parsed, _
#     CRLF line endings                -> parsed, _
#     only comments                    -> parsed, 
#     no equals sign at all            -> Nil
