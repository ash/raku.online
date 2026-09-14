#!/usr/bin/env rakupp
# OpenSSL — A digest and a cipher
# https://raku.online/modules/openssl/#a-digest-and-a-cipher
#
# Install what it needs, then run it:
#     rakupp install OpenSSL
#     rakupp 01-digest-and-cipher.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use OpenSSL::Digest;
use OpenSSL::CryptTools;

say sha256-hex('abc');
say md5-hex('abc');
say sha1('abc').elems, ' ', sha512('abc').elems;

my $key = Buf.new(^32);
my $iv  = Buf.new(^16);
my $secret = 'attack at dawn'.encode;
my $sealed = encrypt($secret, :aes256, :$key, :$iv);
say $sealed.elems, ' bytes; starts like the plaintext: ', $sealed.subbuf(0, 4) eqv $secret.subbuf(0, 4);
say decrypt($sealed, :aes256, :$key, :$iv).decode;
say decrypt($sealed, :aes256, key => Buf.new((^32).map(* + 1)), :$iv).elems;

# Output:
#     ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
#     900150983cd24fb0d6963f7d28e17f72
#     20 64
#     16 bytes; starts like the plaintext: False
#     attack at dawn
#     0
