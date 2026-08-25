{
    title    => 'Rakugrid',
    tagline  => 'The behavioural grid of the Raku language — every recorded test, on every engine on record.',
    base     => '/grid',

    # Where the Rakugrid checkout lives on the machine that refreshes the data.
    # The built pages are committed, so serving the site never needs this.
    grid-src => '/Users/ash/rakugrid',

    repo     => 'https://github.com/ash/rakugrid',
    play     => '/play/',

    # The sweep log kept in the raku++ repo; charted on the home page when present.
    history  => '/Users/ash/raku++/docs/dev/rakugrid-history.tsv',

    # Families in the order the home page walks them: the generated grids first,
    # largest story first, then the curated corpus. Anything new lands at the end.
    families => <operators methods regexes signatures syntax spelling laws types molecules regression numeric unicode io hangs>,
}
