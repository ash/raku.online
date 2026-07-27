# Site configuration for the Raku++ spec generator.
# This file is EVAL'd by build.raku and must evaluate to a Hash.
{
    title      => 'Raku++ Specification',
    tagline    => 'How Raku++ behaves — every feature explained, with runnable, verified examples.',
    engine     => 'https://raku.online/raku.js',
    playground => 'https://raku.online/',
    repo       => 'https://github.com/ash/raku-spec',
    rakupp     => 'https://github.com/ash/rakupp',   # the interpreter's own repo/docs

    # Order and display titles for the categories under src/pages/.
    # (Categories with no pages yet are simply hidden until filled in.)
    categories => [
        { slug => 'literals',  title => 'Literals & quoting'      },
        { slug => 'variables', title => 'Variables & sigils'      },
        { slug => 'operators', title => 'Operators'               },
        { slug => 'control',   title => 'Control flow'            },
        { slug => 'subs',      title => 'Subroutines & signatures' },
        { slug => 'types',       title => 'Types, classes & roles'  },
        { slug => 'phasers',     title => 'Phasers'                 },
        { slug => 'concurrency', title => 'Concurrency'             },
        { slug => 'regexes',     title => 'Regexes & grammars'      },
        { slug => 'builtins',    title => 'Built-in routines'       },
        { slug => 'methods',     title => 'Methods by type'        },
    ],
}
