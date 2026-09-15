#!/usr/bin/env rakupp
# HTTP::HPACK — The one thing to know
# https://raku.online/modules/http-hpack/#the-one-thing-to-know
#
# Install what it needs, then run it:
#     rakupp install HTTP::HPACK
#     rakupp 02-stateful.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTTP::HPACK;

sub headers() {
    (HTTP::HPACK::Header.new(name => ':authority', value => 'example.com'),
     HTTP::HPACK::Header.new(name => 'user-agent', value => 'demo/1'))
}

my $encoder = HTTP::HPACK::Encoder.new;
my $first  = $encoder.encode-headers(headers());
my $second = $encoder.encode-headers(headers());
say $first.elems, ' bytes then ', $second.elems, ' bytes';

my $decoder = HTTP::HPACK::Decoder.new;
say $decoder.decode-headers($first).map({ .name }).join(',');
say $decoder.decode-headers($second).map({ .value }).join(',');

my $fresh = HTTP::HPACK::Decoder.new;
say (try $fresh.decode-headers($second)) // $!.^name;

# Output:
#     21 bytes then 2 bytes
#     :authority,user-agent
#     example.com,demo/1
#     X::HTTP::HPACK::IndexOutOfRange
