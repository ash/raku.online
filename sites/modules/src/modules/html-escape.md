---
name: HTML::Escape
version: 0.0.1
auth: github:moznion
kind: Distribution · web
summary: One exported sub that turns the five characters HTML cares about into
  entities — the smallest correct answer to "I am about to interpolate a
  string into markup".
status: full
suite: 1 file, green
tested: 2026-09-14
license: Artistic-2.0
raku-land: https://raku.land/github:moznion/HTML::Escape
source: https://github.com/moznion/p6-HTML-Escape
---

## What it is for

Every program that builds a page by concatenation eventually interpolates
something a user typed, and the moment that string contains a `<` the markup
stops being the markup you wrote. The fix is old and boring: replace the
handful of characters that mean something to an HTML parser with their entity
forms before they reach the output.

This distribution does exactly that and stops. Seventy-nine lines, no
dependencies, one exported sub. There is nothing to configure, which is the
feature — an escaping routine with options is an escaping routine with a way
to get it wrong.

## The whole API

```raku name="escape"
use HTML::Escape;

say escape-html('<a href="x">Tom & Jerry</a>');
say escape-html("it's");
say escape-html('plain text');
```

```output
&lt;a href=&quot;x&quot;&gt;Tom &amp; Jerry&lt;/a&gt;
it&#39;s
plain text
```

Five characters are touched — `&`, `<`, `>`, `"` and `'` — and `&` is handled
first, so an already-escaped string escapes again rather than being mangled
into something that decodes differently. A string with none of them comes back
identical, so it is safe to call on everything rather than reasoning about
which values need it.

## The one thing to know

This escapes text for *element and attribute content*, and that is the only
context it is right for. The apostrophe comes back as the numeric `&#39;`
rather than `&apos;`, which is deliberate — `&apos;` is not in HTML 4 — and
attribute values must therefore be quoted, which they should be anyway.

What it does not do is make an arbitrary string safe *anywhere* in a document.
Interpolating escaped text into an unquoted attribute, into a `<script>` or
`<style>` body, or into a URL in an `href` is still an injection, because those
places are parsed by something other than the HTML parser and `&lt;` is not
what protects them. Escape for the context you are in; for a URL that means
percent-encoding, which is a different module's job.
