#!/usr/bin/env rakupp
# Sys::Hostname — Using it
# https://raku.online/modules/sys-hostname/#using-it
#
# Install what it needs, then run it:
#     rakupp install Sys::Hostname
#     rakupp 02-arity.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Sys::Hostname;

say 'arity / count : ', &hostname.arity, ' / ', &hostname.count;
say 'signature     : ', &hostname.signature.gist;
say '';
my $r = try &hostname('x');
say 'calling it with an argument -> ', $! ?? 'refused' !! $r;
say '';
say 'a direct hostname("x") is a COMPILE-time error on Rakudo ("Calling';
say 'hostname(Str) will never work with declared signature ()") and only';
say 'a run-time one on Raku++, so `try` helps on one engine and not the';
say 'other. The refusal is the same either way.';

# Output:
#     arity / count : 0 / 0
#     signature     : ()
#     
#     calling it with an argument -> refused
#     
#     a direct hostname("x") is a COMPILE-time error on Rakudo ("Calling
#     hostname(Str) will never work with declared signature ()") and only
#     a run-time one on Raku++, so `try` helps on one engine and not the
#     other. The refusal is the same either way.
