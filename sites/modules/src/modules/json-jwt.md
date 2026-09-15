---
name: JSON::JWT
version: 1.1.2
auth: zef:raku-community-modules
kind: Distribution · crypto
summary: JSON Web Tokens signed and verified — unsigned, HMAC-SHA256 with a
  shared secret, or RSA-SHA256 with a PEM key — where decoding and
  verifying are the same call.
status: full
suite: 2 files, green
tested: 2026-09-15
license: MIT
depends: JSON::Fast, MIME::Base64, OpenSSL, Digest::HMAC
raku-land: https://raku.land/zef:raku-community-modules/JSON::JWT
source: https://github.com/raku-community-modules/JSON-JWT
---

## What it is for

A JSON Web Token is a small signed document a client can carry and a server
can check without a database lookup: some claims, base64'd, with a
signature over them. It is the shape almost every web session and API
credential has settled into.

The security of the scheme lives entirely in the verification step, and its
famous failure is the one where an attacker changes the algorithm field to
`none` and the server believes the token anyway. This distribution's answer
is to make decoding and verifying a single call: you say which algorithm
you expect, and a token claiming anything else is rejected before its
claims are handed back.

## Signing, and verifying

```raku name="round-trip"
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
```

```output
3 parts
adm=True n=1 sub=ada
Signature does not match.
Header lists signature type != 'none' (HS256)
2 parts unsigned
adm,n,sub
```

The third and fourth lines are the two attacks. A wrong secret fails the
signature check. Asking to decode a signed token as `none` fails too — the
header still says `HS256`, and the mismatch is refused rather than
believed. That is the behaviour you want and it is worth confirming in your
own tests, because it is the thing most implementations of this format have
got wrong at some point.

`decode-noverify` exists for when you genuinely want the claims without
checking anything, such as reading the key identifier to decide which key
to verify with. It is spelled clearly and it is the one call here that
hands back attacker-controlled data.

## The one thing to know

The JSON inside the token is pretty-printed, so the tokens are bloated and
not reproducible:

```raku name="bloat"
use JSON::JWT;
use MIME::Base64;

my $token = JSON::JWT.encode({ sub => 'ada' }, :alg<HS256>, :secret<s3cret>);
my @parts = $token.split('.');

say MIME::Base64.decode-str(@parts[1].trans('-_' => '+/')).raku;
say 'payload segment: ', @parts[1].chars, ' characters';
say 'compact JSON would be: ', '{"sub":"ada"}'.chars, ' characters of input';
```

```output
"\{\n  \"sub\": \"ada\"\n}"
payload segment: 24 characters
compact JSON would be: 13 characters of input
```

The encoder calls the JSON writer at its defaults, and that writer
pretty-prints by default — so every token carries newlines and indentation
inside its base64, and is roughly half again as large as the same claims
from any other library.

Worse for anything that stores or compares tokens: the JSON comes from a
hash, so the key order is hash order. The same claims produce a *different
token* on each engine, and under Rakudo a different one on each run. Never
use a token from this module as a cache key, a database identifier or a
test fixture; compare the decoded claims instead.

Two smaller things. `:alg` has no default on either `encode` or `decode`,
and because every candidate constrains it, leaving it out is a
multiple-dispatch failure rather than a helpful message — as is naming an
algorithm the module does not implement. And the signature comparison is an
ordinary string equality rather than a constant-time one, which the source
itself flags; on a public endpoint that is a timing side channel.
