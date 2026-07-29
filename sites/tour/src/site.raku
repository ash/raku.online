# Site configuration for the Raku++ tour generator.
# This file is EVAL'd by build.raku and must evaluate to a Hash.
{
    base       => '/tour',                 # where this site is mounted on raku.online
    theme-out  => False,                   # the root build places the shared theme
    theme-dir  => '../../theme',           # the shared theme, one copy for the whole site
    title      => 'A Tour of Raku',
    tagline    => 'Learn Raku in your browser — short lessons, live code, no installation.',
    engine     => 'https://raku.online/raku.js',
    playground => 'https://raku.online/play',
    spec       => '/spec/',
    repo       => 'https://github.com/ash/raku.online/tree/main/sites/tour',
    rakupp     => 'https://github.com/ash/rakupp',
}
