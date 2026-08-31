# Site configuration for the FAQ generator.
# This file is EVAL'd by build.raku and must evaluate to a Hash.
{
    base       => '/faq',                  # where this site is mounted on raku.online
    title      => 'Raku FAQ',
    tagline    => 'Short, task-shaped answers to questions people actually ask — ' ~
                  'how do I, why does this print twice, does Rakudo do the same.',

    # The articles, in reading order. Anything in src/pages that is not listed
    # here is still built, but appears after these; a name listed with no file
    # is skipped, so removing an article upstream does not break the build.
    order => <shell buffering background-processes containers modules compiling performance garbage-collection debugging differences 6e>,

    # A line of context under each entry on the index. The articles open with a
    # summary of their own, but on an index you want the difference between two
    # of them in one line rather than a paragraph each.
    blurbs => {
        shell       => 'Running external commands: run vs shell, capturing output, feeding input, exit codes.',
        buffering   => 'Why output does not appear when you expect it: out-buffer and flush, the three places output can sit, and the child\'s own buffer you cannot set from outside.',
        'background-processes' => 'Proc::Async: fire-and-forget processes that outlive the program, bind-stdin pipelines, kill — and where Raku\'s own docs stand on the survival.',
        containers  => 'Why does my list have one element? Itemisation, $(…) vs […], and passing lists to routines.',
        modules     => 'Getting a module and being able to use it: rakupp install, zef, and where both engines look.',
        compiling   => 'Turning a program into a binary: --exe vs --aot vs --bundle, and what -O buys.',
        performance => 'My program is slow: what compiling does and does not speed up, with measured numbers.',
        'garbage-collection' => 'There isn\'t one: what reference counting buys, what a cycle costs, and when DESTROY actually runs.',
        debugging   => 'When something goes wrong: --lint, --ast, --cpp, and telling your bug from ours.',
        differences => 'Where Raku++ and Rakudo differ, in both directions, and the few you will actually meet.',
        '6e'        => 'What the 6.e language revision adds to 6.d, and what use v6.e.PREVIEW actually turns on.',
        'hand-written' => 'Is "hand-written" honest for an AI-built project? The term of art it invokes, and the authorship answer behind it.',
        optimizer   => 'Why the optimising code generator is opt-in: what a default owes every program, and where -O loses.',
    },

    # ../SOMETHING.md in an article points at a doc that lives in the rakupp
    # repo, not here, so those links go to GitHub.
    docs-base  => 'https://github.com/ash/rakupp/blob/main/docs/',
    repo       => 'https://github.com/ash/rakupp',
}
