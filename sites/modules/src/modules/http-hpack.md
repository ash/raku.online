---
name: HTTP::HPACK
version: 1.0.3
auth: zef:raku-community-modules
kind: Distribution · web
summary: HTTP/2 header compression — the static and dynamic index tables,
  the integer and string primitives, and the Huffman code — as an encoder
  and a decoder you pair per connection.
status: full
suite: 2 files, green
tested: 2026-09-15
license: Artistic-2.0
raku-land: https://raku.land/zef:raku-community-modules/HTTP::HPACK
source: https://github.com/raku-community-modules/HTTP-HPACK
---

## What it is for

HTTP/2 sends the same headers on every request of a connection, and sending
`user-agent: …` in full each time would undo much of what the protocol
gained. HPACK is the answer: a table of the sixty-one commonest headers
known to both ends, a dynamic table of the ones this connection has
actually used, and an integer index in place of a repeated string. The
second request on a connection can be two bytes.

This distribution is that layer and nothing around it. There are no
sockets, no frames and no streams — you hand it headers and get the packed
bytes that go inside a HEADERS frame.

## Packing a header block

```raku name="pack"
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
```

```output
24 bytes packed
85 bytes of plain text
82 87 84 41 0b 65
  :method      GET
  :scheme      https
  :path        /
  :authority   example.com
  user-agent   demo/1
dynamic table: 101 of 4096
```

The four pseudo-headers cost one byte each because they are in the static
table; only the two values that are not — the host and the user agent —
carry their text. Huffman coding is off by default and turned on with
`:huffman` on the encoder, which shrinks the strings further.

## The one thing to know

The encoder and decoder are stateful, and they are stateful *together*.
Encoding the same headers twice does not give the same bytes:

```raku name="stateful"
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
```

```output
21 bytes then 2 bytes
:authority,user-agent
example.com,demo/1
X::HTTP::HPACK::IndexOutOfRange
```

The second block is two bytes because both headers are now in the dynamic
table, and it is *only* decodable by a decoder that saw the first one. A
fresh decoder fails outright, which is the last line.

So: one encoder and one decoder per connection, for the life of the
connection, and the blocks must be decoded in the order they were encoded.
A block cannot be cached, replayed, reordered or decoded in isolation, and
a dropped block corrupts everything after it. That is inherent to HPACK
rather than a choice this module made, and it is the thing that catches
people who reach for it expecting a stateless codec.

Catch failures as `X::HTTP::HPACK`, with the `X::` prefix: the bare name
resolves to a role on one engine and a plain package on the other, so
matching against it works only on Raku++.
