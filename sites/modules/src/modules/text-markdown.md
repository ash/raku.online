---
name: Text::Markdown
version: 1.1.1
auth: zef:JJMERELO
kind: Distribution · text
summary: A Markdown parser with an HTML backend — headings, emphasis, code,
  quotes and links — written as a grammar, and covering rather less of Markdown
  than its name suggests.
status: full
suite: 5 files, green
tested: 2026-09-16
license: MIT
depends: HTML::Escape
raku-land: https://raku.land/zef:JJMERELO/Text::Markdown
source: https://github.com/retupmoca/p6-markdown.git
---

## What it is for

`parse-markdown` returns a document object; `.to-html` renders it. That is the
whole surface for the common case, and it is the reason seven distributions
depend on this one rather than shelling out to a C library.

## Rendering a document

```raku name="markdown"
use Text::Markdown;

my $md = q:to/MD/;
# A heading

Some *emphasis*, some **strong**, and a `literal`.

- one
- two

> a quote

    a code block
MD

say parse-markdown($md).to-html;
```

```output
<h1>A heading</h1><p>Some <em>emphasis</em>, some <strong>strong</strong>, and a <code>literal</code>.</p><p>- one - two</p><blockquote><p>a quote</p></blockquote><pre><code>a code block</code></pre>
```

Headings, emphasis, strong, inline code, block quotes and indented code blocks
all come out as you would expect.

## What it does not do

Look closely at the list in the middle of that output. The two `-` items came
back as a single paragraph — `<p>- one - two</p>` — not a `<ul>`. Unordered
lists written with `-` are not part of what this parser recognises, and neither
is the `*` spelling.

That is worth knowing before you choose it: this is a parser for the *original*
Markdown core, and a good deal of what people now write — lists with `-`,
fenced code blocks with backticks, tables, task lists, anything from
CommonMark's later additions — passes through as literal paragraph text rather
than failing loudly. The output is valid HTML either way, which is exactly what
makes the gap easy to miss.

The document object is inspectable, so a program that needs to know whether a
construct was understood can look at the parsed structure instead of the
rendered string.

## Where the two engines differ

Nowhere. The rendered HTML is byte-identical on Raku++ and Rakudo, and all five
test files pass on both.

One note about the output format rather than the engines: `.to-html` emits no
newlines between block elements — the whole document is one line. That is fine
for a browser and awkward for a diff, so if you are snapshot-testing the result,
compare parsed structures or normalise the HTML first.
