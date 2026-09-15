---
name: HTML::Lazy
version: 0.0.1
auth: cpan:SAMGWISE
kind: Distribution · markup
summary: A lazy HTML builder where every constructor returns a thunk and
  nothing is rendered until the outermost one is passed to render.
status: partial
suite: no test files, so trivially green
tested: 2026-09-15
license: Artistic-2.0
depends: HTML::Escape
raku-land: https://raku.land/?/HTML::Lazy
source: https://github.com/samgwise/html-lazy.git
---

## What it is for

Building HTML as a tree of Raku values rather than as a string gets the nesting
and the escaping right by construction. Building it **lazily** adds a second
property: a document can be assembled, passed around and composed without
anything being rendered, so the expensive parts run only if the page is
actually asked for.

This distribution does both. Every constructor returns a `Callable`.

## Building a document

```raku name="build"
use HTML::Lazy;

print render(html-en(
    :attributes({ :lang<en> }),
    node('h1', {}, text('Totals')),
    node('p', {}, text('Rows: 3')),
));
```

```output
<!DOCTYPE html>
<html lang="en">
    <h1>
        Totals
    </h1>
    <p>
        Rows: 3
    </p>
</html>
```

`node`, `text` and `html-en` all return thunks; `render` is what forces them.
Nothing above touched a string until the last line.

## Tag helpers

```raku name="tags"
use HTML::Lazy (:DEFAULT, :tags);

print render(html-en(
    :attributes({ :lang<en> }),
    head({}, title({}, text('A page'))),
    body({}, div({}, text('content'))),
));
```

```output
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>
            A page
        </title>
    </head>
    <body>
        <div>
            content
        </div>
    </body>
</html>
```

The `:tags` and `:ALL` import tags bring in about forty ready-made per-tag
subs, each taking an attribute hash and children. `tag-factory` mints one for
a tag they missed.

## Composition

```raku name="compose"
use HTML::Lazy;

my $row = -> $label, $value {
    node('tr', {}, node('td', {}, text($label)), node('td', {}, text($value)))
};

print render(node('table', {},
    $row('alpha', '1'),
    $row('beta',  '2'),
));
```

```output
<table>
    <tr>
        <td>
            alpha
        </td>
        <td>
            1
        </td>
    </tr>
    <tr>
        <td>
            beta
        </td>
        <td>
            2
        </td>
    </tr>
</table>
```

Because the pieces are thunks, a helper that builds a row is an ordinary
closure and composes without any template machinery.

## The one thing to know

`text()` escapes. **Attribute values are not escaped at all.**

```raku name="escape-trap"
use HTML::Lazy;

my $evil = q{<script>alert("x&y")</script>};

say 'in a text node, escaped:';
print render(node('p', {}, text($evil)));
say '';
say 'in an attribute, NOT escaped:';
print render(node('a', { :title($evil) }));
say '';
say 'which means an attacker can close the quote:';
print render(node('a', { :title(q{" onmouseover=alert(1) x="}) }));
```

```output
in a text node, escaped:
<p>
    &lt;script&gt;alert(&quot;x&amp;y&quot;)&lt;/script&gt;
</p>
in an attribute, NOT escaped:
<a title="<script>alert("x&y")</script>"></a>
which means an attacker can close the quote:
<a title="" onmouseover=alert(1) x=""></a>
```

That last line emits `<a title="" onmouseover=alert(1) x=""></a>` — the
attribute is closed and a new one injected. Tag **names** are interpolated raw
as well.

The module pulls in `HTML::Escape` and applies it only to text nodes, which is
exactly the half of the job that makes the other half look safe. Escape
attribute values yourself before they reach `node`.

## Where the two engines differ

On attribute order, and it makes byte-comparing the output impossible.

Attributes come out of an unordered `Hash`, so the order differs between
engines and — under Rakudo — **between calls in the same process**. Five
renders of the same three-attribute element produced three different orders in
one Rakudo run and five identical ones under Raku++.

That rules out snapshot-testing HTML::Lazy output. Compare parsed documents,
or emit one attribute per element.

There is also a compile-time divergence on the most natural way to write a
nested document. `node` is declared `--> Callable`, and Rakudo's compile-time
arity check rejects `html-en(node(...))` with `Calling html-en(Callable) will
never work` because the first positional does not match the signature's
`Associative :$attributes`. Raku++ compiles and runs it. Passing
`:attributes(…)` explicitly — as every example on this page does — works on
both.

One typo worth knowing: the `footer` helper is registered under the misspelled
tag name `foorter`.
