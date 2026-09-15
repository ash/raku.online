#!/usr/bin/env rakupp
# Base64::Native — The URL-safe alphabet
# https://raku.online/modules/base64-native/#the-url-safe-alphabet
#
# Install what it needs, then run it:
#     rakupp install Base64::Native
#     rakupp 03-uri.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Base64::Native;

my $plus  = Blob.new(0xFB, 0xEF, 0xBE);
my $slash = Blob.new(0xFF, 0xFF, 0xFF);

say 'standard : ', base64-encode($plus, :str), '  ', base64-encode($slash, :str);
say 'uri      : ', base64-encode($plus, buf8.allocate(4), :uri).decode,
    '  ', base64-encode($slash, buf8.allocate(4), :uri).decode;
say '';
say 'note the padding is kept in both:';
say '  standard "a" : ', base64-encode('a', :str).raku;

# Output:
#     standard : ++++  ////
#     uri      : ----  ____
#     
#     note the padding is kept in both:
#       standard "a" : "YQ=="
