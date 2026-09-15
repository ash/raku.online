#!/usr/bin/env rakupp
# HTTP::HPACK — Packing a header block
# https://raku.online/modules/http-hpack/#packing-a-header-block
#
# Install what it needs, then run it:
#     rakupp install HTTP::HPACK
#     rakupp 01-pack.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use HTTP::HPACK;

my $encoder = HTTP::HPACK::Encoder.new;
my @headers =
    HTTP::HPACK::Header.new(name => ':method',    value => 'GET'),
    HTTP::HPACK::Header.new(name => ':scheme',    value => 'https'),
    HTTP::HPACK::Header.new(name => ':path',      value => '/'),
    HTTP::HPACK::Header.new(name => ':authority', value => 'example.com'),
    HTTP::HPACK::Header.new(name => 'user-agent', value => 'demo/1');

my $packed = $encoder.encode-headers(@headers);
say $packed.elems, ' bytes packed';
say @headers.map({ .name.chars + .value.chars + 4 }).sum, ' bytes of plain text';
say $packed.list.head(6).map({ .fmt('%02x') }).join(' ');

my $decoder = HTTP::HPACK::Decoder.new;
for $decoder.decode-headers($packed) -> $h {
    say sprintf('  %-12s %s', $h.name, $h.value);
}
say 'dynamic table: ', $encoder.dynamic-table-size, ' of ', $encoder.dynamic-table-limit;

# Output:
#     24 bytes packed
#     85 bytes of plain text
#     82 87 84 41 0b 65
#       :method      GET
#       :scheme      https
#       :path        /
#       :authority   example.com
#       user-agent   demo/1
#     dynamic table: 101 of 4096
