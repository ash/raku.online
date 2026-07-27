# Configuration for the Rules site (spec 2.0) — EVAL'd by rules.raku.
#
# Topics are the top level of the menu. Symbol-bearing constructs are filed
# under them automatically from the extracted inventory (see tools/inventory.raku);
# everything else is a hand-written page whose frontmatter names its topic.
{
    title    => 'Raku Rules',
    tagline  => 'The exhaustive rulebook: every construct, every rule, every trap — each one runnable.',
    base     => '/spec/rules',   # URL
    out-dir  => '/rules',        # path inside out/, which is mounted at /spec
    spec-base  => '/spec',
    theme-out  => False,                 # the parent spec site
    theme-dir  => '../../../theme',
    engine     => 'https://raku.online/raku.js',
    playground => 'https://raku.online/play',
    spec       => '/spec/',
    repo       => 'https://github.com/ash/raku-spec',
    rakupp     => 'https://github.com/ash/rakupp',

    topics => [
        { slug => 'reading',   title => 'How to read these rules',
          blurb => 'What a rule is, how it is verified, and what the badges mean.' },
        { slug => 'lexical',   title => 'Lexical structure',
          blurb => 'How source text becomes tokens: whitespace, comments, identifiers, statement boundaries.' },
        { slug => 'terms',     title => 'Terms & literals',
          blurb => 'The things that stand alone as a value: numbers, strings, quoting forms, named terms.' },
        { slug => 'variables', title => 'Variables & containers',
          blurb => 'Sigils, twigils, binding versus assignment, and what a container actually is.' },
        { slug => 'operators', title => 'Operators',
          blurb => 'Every operator, filed by its precedence level — tightest first.' },
        { slug => 'control',   title => 'Control flow',
          blurb => 'Conditionals, loops, statement prefixes and modifiers, and how they yield values.' },
        { slug => 'routines',  title => 'Routines & signatures',
          blurb => 'Declaring, dispatching, binding parameters, returning, and traits.' },
        { slug => 'types',     title => 'Types, classes & roles',
          blurb => 'The type tower, definedness, composition, and the metaobject protocol.' },
        { slug => 'regex',     title => 'Regexes & grammars',
          blurb => 'Matching, capturing, adverbs, and grammar dispatch.' },
        { slug => 'phasers',   title => 'Phasers',
          blurb => 'Blocks that run at a point in a program\'s life rather than in sequence.' },
        { slug => 'builtins',  title => 'Built-in routines',
          blurb => 'The subroutines and methods the interpreter provides.' },
    ],

    # The precedence ladder, tightest first. These are the level names used by
    # the precedence table in the official documentation (doc/Language/
    # operators.rakudoc), which is also what files each operator under a level —
    # so the menu is the ladder as the language documents it.
    ladder => [
        'term', 'method call', 'autoincrement', 'exponentiation',
        'symbolic unary', 'dotty infix', 'multiplicative', 'additive',
        'replication', 'concatenation', 'junctive and', 'junctive or',
        'named unary', 'structural', 'chaining', 'tight and', 'tight or',
        'conditional', 'item assignment', 'loose unary', 'comma',
        'list infix', 'list prefix', 'loose and', 'loose or', 'sequencer',
        'terminator', 'metaoperators',
    ],
}
