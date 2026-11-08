# Evidence: what each source says

One JSON file per page, named by the page's slug: `timeline.json`, `borrowed.json` and so on. Each file is an object keyed by a link target exactly as it appears in the report's Markdown (`[text](URL)`). `build.raku` adds a numbered marker after every link that has an entry. It then lists the entries under the paragraph or table that cites them, so the reader sees who said what without leaving the page.

```json
{
  "https://example.org/thread/123": {
    "who":   "Jane Doe, Swift core team",
    "where": "swift-evolution mailing list",
    "when":  "25 Apr 2016",
    "says":  "Proposes taking a heredoc's base indentation from its closing delimiter, the rule Perl 6 settled on.",
    "quote": "",
    "rest":  "",
    "note":  "beyond-proposals/design_forums.md"
  }
}
```

| Field | Required | What it holds |
|---|---|---|
| `who` | yes | The person or body speaking, with the role that makes it matter (core team, PEP author, pumpking). For a document with no single author, its owner (the PHP RFC, Rakudo's ChangeLog). |
| `where` | yes | The venue or document: a list and message number, an issue number, a proposal, a commit. |
| `when` | yes | The date as the source gives it (`25 Apr 2016`, `Jul 2005`). |
| `says` | yes | What the source says or does that bears on the report's claim, **in our own words**: one sentence, at most about 35 words. Paraphrase; never copy the source's wording. |
| `quote` | no | The source's exact words, added by hand. When set, the page shows it as a quotation instead of `says`, on every page that cites the source (fill it in one file; the others pick it up). When the passage is long, quote the main part and put the rest in `rest`. Code is written in backticks, as in `says`; the source's own markup (reStructuredText's double backticks, emphasis, footnote markers) is left out, words left out of the middle are marked `…`, and a footnote taken into the quote is introduced by `[Footnote:]`. |
| `rest` | no | A short summary, in our words, of what the quoted passage leaves out. It is shown under the quotation, and only when there is one. |
| `note` | no | Which research note holds the original wording, relative to `rakupp/docs/dev/perl6-influence-notes/`. Use it to find a quote to paste into `quote`. |

## Filling in quotes

```
cd sites/lineage
rakupp quotes.raku                 # every entry still without a quote
rakupp quotes.raku --page=borrowed # one page
rakupp quotes.raku --all           # quoted ones too, marked ✓
```

Each entry is listed with the lines of the research notes that mention its source, as `file:line` relative to `rakupp/docs/dev/perl6-influence-notes/`. Most notes record the source's wording there. An entry the notes do not mention says so, and its words have to come from the source itself. After editing, `./build.sh lineage` from the repository root shows the quotes.

## What gets an entry

Only links that carry a claim get an entry: a statement, a credit, a citation, a proposal, a rejection, a decision. A link that only supports a date or names a release can go without one. An entry whose URL no longer appears in the report is reported by the build as stale.
