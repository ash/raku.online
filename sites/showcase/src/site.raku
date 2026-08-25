# Site configuration for the showcase generator (which also builds /live).
# This file is EVAL'd by build.raku and must evaluate to a Hash.
{
    base      => '/showcase',            # where the showcase is mounted
    live-base => '/live',                # where the live entries are mounted
    title     => 'The showcase',
    tagline   => 'Mid-size programs that each stress a different part of Raku++ — ' ~
                 'together they answer "what can it actually build?"',

    live-title => 'Software that already existed',

    repo    => 'https://github.com/ash/rakupp',
    gh-base => 'https://github.com/ash/rakupp/blob/main/',
    gh-tree => 'https://github.com/ash/rakupp/tree/main/',

    # Projects that also run in the playground, and where. These are the five
    # interpreters that rakujs/gen-examples.raku ships as playground examples.
    play => {
        lisp   => '/play/?ex=lisp-interpreter',
        js     => '/play/?ex=javascript-typescript',
        forth  => '/play/?ex=forth-interpreter',
        perl   => '/play/?ex=perl-interpreter',
        python => '/play/?ex=python-interpreter',
    },

    # web/ has no row in the showcase README's table (it sits in its own
    # section there), so its index entry is spelled out here.
    extras => [
        {
            slug  => 'web',
            shelf => 'In the browser',
            axis  => 'the pure showcases running client-side on the WebAssembly build',
            how   => 'three little apps — a live Markdown editor, a JSON beautifier, a regex tester',
        },
    ],
}
