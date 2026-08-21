# Site configuration for the ecosystem handbook generator.
# This file is EVAL'd by build.raku and must evaluate to a Hash.
{
    base    => '/ecosystem',               # where this site is mounted on raku.online
    title   => 'The Raku Ecosystem, Working',
    tagline => 'One page per module from raku.land — installed, tested and run ' ~
               'under Raku++, with examples you can copy straight into a file.',

    # The pages, in reading order. Anything in src/modules that is not listed
    # here is still built and sorts after these, so adding a module is one file.
    order => <statistics-distributions>,

    # Where a module page's links point when it names its own home.
    land-base => 'https://raku.land/',
    repo      => 'https://github.com/ash/rakupp',

    # Named in the footer of every page: what "verified" on this site means.
    # Bump `engine` at every release — a page can say "3.5.1 answers this
    # wrongly" and be verified on a build that fixes it, and then the footer
    # has to say which build that was.
    engine    => 'Raku++ 3.5.1 (dev build)',
    oracle    => 'Rakudo 2026.06',
}
