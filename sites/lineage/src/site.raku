# Lineage at raku.online/lineage: what other languages took from the Perl 6
# design. One chapter per `## ` section of src/report.md, in the report's
# order; `starts` is the start of that section's heading, so a reordered or
# renamed section stops the build instead of landing on the wrong page.
%(
    base    => '/lineage',
    title   => 'Lineage',
    tagline => 'What other languages took from the Perl 6 design after 2000, what they reinvented on their own, and what came to both from an older source — each verdict taken from the adopting language’s own records.',
    repo    => 'https://github.com/ash/rakupp',
    # The report's relative links are written from rakupp/docs/dev/.
    gh-base => 'https://github.com/ash/rakupp/blob/main/docs/dev/',
    gh-tree => 'https://github.com/ash/rakupp/tree/main/docs/dev/',
    report  => 'https://github.com/ash/rakupp/blob/main/docs/dev/PERL6-FEATURES-IN-OTHER-LANGUAGES.md',
    notes   => 'https://github.com/ash/rakupp/tree/main/docs/dev/perl6-influence-notes',
    evidence => 'https://github.com/ash/raku.online/tree/main/sites/lineage/src/evidence',
    chapters => (
        %( slug => 'timeline', short => 'The timeline', starts => 'Perl 6 led on paper',
           blurb => 'When Perl 6 proposed, specified and implemented each idea: the RFCs of 2000, the Apocalypses to 2004, Pugs in 2005, no stable release until 2015. Also the verdict scale used on every page.' ),
        %( slug => 'borrowed', short => 'Five borrowings', starts => 'Only five borrowings',
           blurb => 'The five adoptions outside the Perl family whose own records name Perl 6: Swift’s heredoc rule, Ruby’s ->, PHP’s string increment, Swift regex at the design stage, and Joose by way of Moose.' ),
        %( slug => 'near-misses', short => 'Near-misses', starts => 'Near-misses',
           blurb => 'Thirty-odd records in which another language’s designers raised Perl 6 and passed: who proposed what, and what shipped instead.' ),
        %( slug => 'perl5', short => 'Perl 5', starts => 'Perl 5 imported',
           blurb => 'The one real importer: say, state, given/when, //, the feature pragma and Moose, credited in perl5-porters threads rather than release notes, and smartmatch, the import it regretted.' ),
        %( slug => 'reinvented', short => 'Reinvented', starts => 'Convergent reinvention',
           blurb => 'Look-alikes whose documented origin is elsewhere: heredoc dedent, half-open ranges, implicit lambda parameters, keyword-only arguments, CLIs from signatures, null-coalescing.' ),
        %( slug => 'ancestors', short => 'Common ancestors', starts => 'Common ancestors',
           blurb => 'Where both sides descend from an older source (the Traits paper, CLOS, APL, CLU generators, Unix pipes, Rx), what Perl 6 itself imported, and what nobody adopted.' ),
        %( slug => 'warning', short => 'People, a VM, a warning', starts => 'Perl 6 traveled further',
           blurb => 'Influence through people and infrastructure: Pugs and the Haskell community, Parrot in virtual-machine research, and Perl 6 as other languages’ cautionary tale.' ),
        %( slug => 'conclusion', short => 'Conclusion', starts => 'Conclusion',
           blurb => 'What separates the few ideas that crossed from the many that did not.' ),
        %( slug => 'method', short => 'Method', starts => 'How this was researched',
           blurb => 'What was searched (proposal archives, forums, mailing lists, issue trackers, 228 JEPs) and what is still unsearched.' ),
    ),
)
