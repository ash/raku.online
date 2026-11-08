# Lineage at raku.online/lineage: what other languages took from the Perl 6
# design. One chapter per `## ` section of src/report.md, in the report's
# order; `starts` is the start of that section's heading, so a reordered or
# renamed section stops the build instead of landing on the wrong page.
%(
    base    => '/lineage',
    title   => 'Lineage',
    tagline => 'What other languages took from the Perl 6 design after 2000, which of its ideas they reached on their own, and what came to both from an older source. Each verdict comes from the adopting language’s own records.',
    # Shown under the title of every page.
    nb      => 'This material was collected and structured automatically, and may contain unintentional mistakes. Every claim links its source: please check it before relying on a detail.',
    repo    => 'https://github.com/ash/raku.online',
    # The report's relative links are written from src/, where it lives.
    gh-base => 'https://github.com/ash/raku.online/blob/main/sites/lineage/src/',
    gh-tree => 'https://github.com/ash/raku.online/tree/main/sites/lineage/src/',
    report  => 'https://github.com/ash/raku.online/blob/main/sites/lineage/src/report.md',
    notes   => 'https://github.com/ash/raku.online/tree/main/sites/lineage/src/notes',
    evidence => 'https://github.com/ash/raku.online/tree/main/sites/lineage/src/evidence',
    chapters => (
        %( slug => 'timeline', short => 'The timeline', starts => 'Perl 6 was years ahead in design',
           blurb => 'When Perl 6 proposed, specified and implemented each idea: the RFCs of 2000, the Apocalypses to 2004, Pugs in 2005, Rakudo to 6.c in 2015. Also the verdict scale used on every page.' ),
        %( slug => 'borrowed', short => 'Five borrowings', starts => 'Five documented borrowings',
           blurb => 'The five adoptions outside the Perl family whose own records name Perl 6: Swift’s heredoc rule, Ruby’s ->, PHP’s string increment, Swift regex at the design stage, and Joose by way of Moose.' ),
        %( slug => 'near-misses', short => 'Ideas studied', starts => 'Designers elsewhere studied',
           blurb => 'More than thirty records in which another language’s designers raised a Perl 6 idea: who proposed what, and what shipped.' ),
        %( slug => 'perl5', short => 'Perl 5', starts => 'Perl 5 took the most',
           blurb => 'The biggest importer: say, state, given/when, //, the feature pragma, smartmatch and Moose, credited in perl5-porters threads and module documentation.' ),
        %( slug => 'reinvented', short => 'Reached independently', starts => 'Other languages reached',
           blurb => 'Look-alikes whose documented origin is elsewhere: heredoc dedent, half-open ranges, implicit lambda parameters, keyword-only arguments, CLIs from signatures, gradual typing.' ),
        %( slug => 'ancestors', short => 'Shared ancestors', starts => 'Shared ancestors',
           blurb => 'Where both sides descend from an older source (the Traits paper, CLOS, APL, Unicode, Rx), what Perl 6 itself built on, and the ideas that are still Raku’s own.' ),
        %( slug => 'reach', short => 'People and Parrot', starts => 'Perl 6 also travelled',
           blurb => 'Influence through people and infrastructure: Pugs and the Haskell community, Parrot in virtual-machine research, and Perl 6 in other languages’ debates on big changes.' ),
        %( slug => 'conclusion', short => 'Conclusion', starts => 'Conclusion',
           blurb => 'Which ideas crossed, which are still Raku’s own, and what that means for an implementer.' ),
        %( slug => 'method', short => 'Method', starts => 'How this was researched',
           blurb => 'What was searched (proposal archives, forums, mailing lists, issue trackers, 228 JEPs) and what is still unsearched.' ),
    ),
)
