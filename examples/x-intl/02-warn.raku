#!/usr/bin/env rakupp
# X::Intl — The warning half
# https://raku.online/modules/x-intl/#the-warning-half
#
# Install what it needs, then run it:
#     rakupp install X::Intl
#     rakupp 02-warn.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use CX::Warn::Intl;

say 'the sibling role is CX::Warn::Intl, in its own unit:';
say '  use X::Intl does NOT give it to you on Rakudo — `use` it separately.';
say '';
class CX::Locale::Fallback does CX::Warn::Intl {
    has Str $.wanted;
    has Str $.used;
    method message { "no data for $!wanted; fell back to $!used" }
}
my $w = CX::Locale::Fallback.new(wanted => 'gsw-CH', used => 'de-CH');
say 'a composed warning : ', $w.message;
say '  ~~ CX::Warn::Intl : ', $w ~~ CX::Warn::Intl;

# Output:
#     the sibling role is CX::Warn::Intl, in its own unit:
#       use X::Intl does NOT give it to you on Rakudo — `use` it separately.
#     
#     a composed warning : no data for gsw-CH; fell back to de-CH
#       ~~ CX::Warn::Intl : True
