#!/usr/bin/env rakupp
# Text::LDIF — The result shape depends on the data
# https://raku.online/modules/text-ldif/#the-result-shape-depends-on-the-data
#
# Install what it needs, then run it:
#     rakupp install Text::LDIF
#     rakupp 03-shapes.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::LDIF;

sub attrs($body) { Text::LDIF.parse("version: 1\ndn: cn=a\n$body\n")<entries>[0]<attrs> }

my $two = attrs("cn: a\nsn: b");
my $one = attrs("cn: a");
say 'two attributes -> ', $two.WHAT.^name;
say 'one attribute  -> ', $one.WHAT.^name;
say '';
say 'one objectclass  -> ', attrs("objectclass: top")<objectclass>.WHAT.^name;
say 'two objectclasses-> ', attrs("objectclass: top\nobjectclass: person")<objectclass>.WHAT.^name;
say '';
say 'so `for $e<attrs><objectclass> { }` iterates once or N times';
say 'depending on what the directory happened to hold. Use .list.';

# Output:
#     two attributes -> Hash
#     one attribute  -> Pair
#     
#     one objectclass  -> Str
#     two objectclasses-> List
#     
#     so `for $e<attrs><objectclass> { }` iterates once or N times
#     depending on what the directory happened to hold. Use .list.
