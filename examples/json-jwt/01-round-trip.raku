#!/usr/bin/env rakupp
# JSON::JWT — Signing, and verifying
# https://raku.online/modules/json-jwt/#signing-and-verifying
#
# Install what it needs, then run it:
#     rakupp install JSON::JWT
#     rakupp 01-round-trip.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::JWT;

my %claims = sub => 'ada', adm => True, n => 1;

my $token = JSON::JWT.encode(%claims, :alg<HS256>, :secret<s3cret>);
say $token.split('.').elems, ' parts';

my %back = JSON::JWT.decode($token, :alg<HS256>, :secret<s3cret>);
say %back.sort.map({ .key ~ '=' ~ .value }).join(' ');

say (try JSON::JWT.decode($token, :alg<HS256>, :secret<wrong>)) // $!.message;
say (try JSON::JWT.decode($token, :alg<none>)) // $!.message;

my $unsigned = JSON::JWT.encode(%claims, :alg<none>);
say $unsigned.split('.').elems, ' parts unsigned';
say JSON::JWT.decode($unsigned, :alg<none>).sort.map({ .key }).join(',');

# Output:
#     3 parts
#     adm=True n=1 sub=ada
#     Signature does not match.
#     Header lists signature type != 'none' (HS256)
#     2 parts unsigned
#     adm,n,sub
