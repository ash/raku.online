# Site configuration for the Cookbook generator.
# This file is EVAL'd by build.raku and must evaluate to a Hash.
{
    base       => '/cookbook',             # where this site is mounted on raku.online
    title      => 'Raku Cookbook',
    tagline    => 'Whole tasks, worked end to end — one page per task, built ' ~
                  'around programs that were run for it.',

    # The recipes, in reading order. Anything in src/pages that is not listed
    # here is still built, but appears after these; a name listed with no file
    # is skipped, so removing a recipe upstream does not break the build.
    order => <dbiish>,

    # A line of context under each entry on the index. A recipe opens with a
    # summary of its own, but on an index you want the difference between two
    # of them in one line rather than a paragraph each.
    blurbs => {
        dbiish => 'Reading and writing a table with DBIish: the same program against SQLite, MySQL and PostgreSQL, what differs between them, and the five things that bite.',
    },

    # A recipe that was renamed keeps its old address working: the page is
    # linked from outside this repo, and a static host answers a directory that
    # moved with a 404 rather than a hint. Old slug => the recipe it is now.
    redirects => { databases => 'dbiish' },

    # ../SOMETHING.md in a recipe points at a doc that lives in the rakupp
    # repo, not here, so those links go to GitHub — and so do the programs
    # themselves, which are not copied onto this site at all.
    docs-base  => 'https://github.com/ash/rakupp/blob/main/docs/',
    repo       => 'https://github.com/ash/rakupp',
}
