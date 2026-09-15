#!/usr/bin/env rakupp
# Cro::Core — Taking a URI apart
# https://raku.online/modules/cro-core/#taking-a-uri-apart
#
# Install what it needs, then run it:
#     rakupp install Cro::Core
#     rakupp 01-uri.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Cro::Uri;

my $u = Cro::Uri.parse('https://ash:s3cret@example.com:8443/a/b%20c/d?q=1&r=2#frag');

for <scheme userinfo user password host port authority path query fragment> -> $part {
    my $v = $u."$part"();
    say sprintf('%-10s %s', $part, $v.defined ?? $v.Str !! '(Nil)');
}
say '';
say 'path          : ', $u.path;
say 'path-segments : ', $u.path-segments.join(' | ');
say 'round-trip    : ', $u.Str;

# Output:
#     scheme     https
#     userinfo   ash:s3cret
#     user       ash
#     password   s3cret
#     host       example.com
#     port       8443
#     authority  ash:s3cret@example.com:8443
#     path       /a/b%20c/d
#     query      q=1&r=2
#     fragment   frag
#     
#     path          : /a/b%20c/d
#     path-segments : a | b c | d
#     round-trip    : https://ash:s3cret@example.com:8443/a/b%20c/d?q=1&r=2#frag
