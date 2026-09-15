#!/usr/bin/env rakupp
# TinyID — Where the two engines differ
# https://raku.online/modules/tinyid/#where-the-two-engines-differ
#
# Install what it needs, then run it:
#     rakupp install TinyID
#     rakupp 05-portable.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use TinyID;

# a slug helper with the canonicity check the module does not do
class Slugs {
    has TinyID $.codec;
    method new(Str :$key) { self.bless(codec => TinyID.new(:$key)) }
    method encode(UInt $n) { $!codec.encode($n) }
    method decode(Str $s) {
        my $n = $!codec.decode($s);
        die "non-canonical slug: {$s.raku}" unless $!codec.encode($n) eq $s;
        $n
    }
}
my $s = Slugs.new(key => 'cbad');
say 'encode(1000)     : ', $s.encode(1000);
say 'decode it back   : ', $s.decode($s.encode(1000));
my $r = try $s.decode('cccb');
say 'decode("cccb")   : ', $! ?? $!.message !! $r;

# Output:
#     encode(1000)     : ddaac
#     decode it back   : 1000
#     decode("cccb")   : non-canonical slug: "cccb"
