#!/usr/bin/env rakupp
# System::Query — A `by-*` key hijacks its whole hash
# https://raku.online/modules/system-query/#a-by--key-hijacks-its-whole-hash
#
# Install what it needs, then run it:
#     rakupp install System::Query
#     rakupp 04-siblings.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use System::Query;

{
    my %*ENV = SPIKE_MODE => 'blue';
    my %config = %(
        keep                => 'kept?',
        also                => 'also kept?',
        'by-env.SPIKE_MODE' => %( blue => 'branch value' ),
    );
    say 'input keys  : ', %config.keys.sort.join(', ');
    say 'output      : ', system-collapse(%config).raku;
    say '';
    say 'the `when` branches RETURN from system-collapse outright, so';
    say 'sibling keys at the same level are silently discarded.';
    say '';
    say 'and with two by-* siblings, the winner is whichever key .keys';
    say 'yields first — which varies BETWEEN PROCESSES on Rakudo and is';
    say 'stable on Raku++. A config that looks deterministic in';
    say 'development is not.';
    say '';
    say 'keep a by-* key alone in its own hash.';
}

# Output:
#     input keys  : also, by-env.SPIKE_MODE, keep
#     output      : "branch value"
#     
#     the `when` branches RETURN from system-collapse outright, so
#     sibling keys at the same level are silently discarded.
#     
#     and with two by-* siblings, the winner is whichever key .keys
#     yields first — which varies BETWEEN PROCESSES on Rakudo and is
#     stable on Raku++. A config that looks deterministic in
#     development is not.
#     
#     keep a by-* key alone in its own hash.
