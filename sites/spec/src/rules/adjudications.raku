# Hand-written rulings on examples where the three sources disagree.
#
# The automated verdicts (tools/typerun.raku) say WHO disagrees. They cannot say
# who is RIGHT, and for one class in particular — `rakudo-differs`, where the
# documentation and Raku++ agree and Rakudo does not — assuming Rakudo is correct
# is unsafe. Those cases are where Raku++ may be right and Rakudo may have a bug,
# and following Rakudo blindly would make Raku++ worse.
#
# So each such case gets examined and the finding recorded here, keyed by type
# and the first line of the example. The site shows the ruling on the example
# itself; anything absent is shown as "not yet examined" rather than silently
# resolved in either direction.
#
#   ruling => 'raku++'    Raku++ (and the doc) is correct; Rakudo has the bug
#             'rakudo'    Rakudo is correct; Raku++ and the doc are both wrong
#             'flaky'     the example is not deterministic; no verdict possible
#             'undecided' examined, still unclear — say why in the note
{
    'Cool|say 1.asinh;' => {
        ruling => 'raku++',
        note   => 'asinh(1) is ln(1+√2) = 0.88137358701954302523…. The correctly '
                ~ 'rounded double has 0.881373587019543 as its shortest '
                ~ 'round-tripping representation, which is what the documentation '
                ~ 'states and what Raku++ prints. Rakudo prints '
                ~ '0.8813735870195429 — one ulp low, and eighteen significant '
                ~ 'characters where seventeen suffice. Raku++ should NOT be '
                ~ 'changed to match Rakudo here.',
    },
    'Baggy|my $breakfast = bag <eggs bacon>;' => {
        ruling => 'flaky',
        note   => 'The example picks an element from an unordered collection, so '
                ~ 'the two engines can legitimately print different members. '
                ~ 'Not a divergence; the example is simply not deterministic.',
    },
}
