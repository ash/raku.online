# Site configuration for the 6.e page generator.
# This file is EVAL'd by build.raku and must evaluate to a Hash.
{
    base     => '/6e',                    # where this page is mounted on raku.online
    title    => 'Raku 6.e — what it adds to 6.d',
    source   => 'src/page.md',            # synced in by ./sync.sh

    # ../SOMETHING.md and docs/ links in the article point at files in the
    # rakupp repo, not here, so they go to GitHub.
    docs-base => 'https://github.com/ash/rakupp/blob/main/docs/',
    repo      => 'https://github.com/ash/rakupp',
}
