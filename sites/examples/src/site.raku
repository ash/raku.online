# Site configuration for the examples generator.
# This file is EVAL'd by build.raku and must evaluate to a Hash.
{
    base    => '/examples',                # where this site is mounted on raku.online
    title   => 'Raku by example',
    tagline => 'Twenty-four self-contained programs, each a page: the source in a ' ~
               'live editor, what it prints, and the language features it leans on.',

    # Where the programs live upstream; every page links to its source.
    repo    => 'https://github.com/ash/rakupp',
    gh-base => 'https://github.com/ash/rakupp/blob/main/',
    gh-dir  => 'https://github.com/ash/rakupp/tree/main/examples',

    # Programs that cannot run in the browser editor, and the one-line reason
    # shown in place of the Run button. Mirrors rakujs/gen-examples.raku, which
    # omits the same three from the playground: the single-threaded WASM build
    # has no real threads and no sockets.
    native-only => {
        'parallel'    => 'real threads, which the single-threaded WebAssembly build does not have',
        'sleep-sort'  => 'real threads and timers, which the single-threaded WebAssembly build does not have',
        'echo-server' => 'TCP sockets, which the browser sandbox does not have',
    },

    # Extra arguments passed when --capture runs a program natively.
    # life animates with a per-frame sleep; for a text capture we want it flat out.
    capture-args => {
        'life' => ['--delay=0'],
    },

    # How many output lines a page shows before folding the rest into a count.
    # life prints a hundred 16-row frames; two of them make the point.
    output-cap => {
        'life' => 36,
    },

    # Programs whose output is different on every run (a random seed somewhere),
    # so --capture --oracle cannot diff them against Rakudo, and the page says
    # the output shown is from one run.
    nondeterministic => <life>,
}
