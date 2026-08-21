# Examples

Working programs from [raku.online](https://raku.online), one file each — clone
this repository and run them, rather than copying them out of a web page.

```sh
git clone https://github.com/ash/raku.online
cd raku.online/examples/statistics-distributions
rakupp install Statistics::Distributions
rakupp 01-catalogue.raku
```

Everything here runs under **Raku++** and under **Rakudo** — these are Raku
programs, not Raku++ programs. Swap `rakupp` for `raku` and they behave the
same; where the two engines genuinely differ, the page the example comes from
says so, and so does the file.

## What is here

| Directory | From | What it needs |
|---|---|---|
| [`statistics-distributions/`](statistics-distributions/) | [The module handbook](https://raku.online/ecosystem/statistics-distributions/) | `rakupp install Statistics::Distributions` |

One directory per module of the [ecosystem handbook](https://raku.online/ecosystem/).
Each has its own README listing its files.

## Where they come from, and why they can be trusted

These files are **generated from the pages they appear on**, so a file and its
page cannot drift apart. Each one is then *run* — under both engines, twice on
each — every time the site is built, and its output compared against the
`# Output:` comment at the bottom of the file. A file whose output has moved
fails that build.

So the output in a file is what it printed, not what it was once expected to
print. The exception is the files whose comment says *One run printed* — those
draw random numbers, and are run to prove they still work rather than to
compare what they say.

To re-run that check yourself:

```sh
cd sites/ecosystem
rakupp build.raku --verify --oracle=raku
```

## Editing them

Edit the page, not the file: the module pages live in
`sites/ecosystem/src/modules/`, and `./build.sh ecosystem` regenerates both the
page and the files here.
