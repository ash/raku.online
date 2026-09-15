#!/usr/bin/env rakupp
# JSON::Marshal — Objects into documents
# https://raku.online/modules/json-marshal/#objects-into-documents
#
# Install what it needs, then run it:
#     rakupp install JSON::Marshal
#     rakupp 02-traits.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use JSON::Marshal;

class Account {
    has Str $.user;
    has Str $.token    is json-skip;
    has Str $.nickname is json-skip-null;
    has Str $.created  is marshalled-by('uc');
    has Str $.tag      is marshalled-by(-> $v { "<<$v>>" });
}

my $a = Account.new(user => 'ada', token => 'secret',
                    created => 'monday', tag => 'x');
say marshal($a, :!pretty, :sorted-keys);
say marshal($a, :!pretty, :sorted-keys, :skip-null);

# Output:
#     {"created":"MONDAY","tag":"<<x>>","user":"ada"}
#     {"created":"MONDAY","tag":"<<x>>","user":"ada"}
