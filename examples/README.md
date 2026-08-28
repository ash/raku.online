# Examples

Working programs from [raku.online](https://raku.online), one file each — clone
this repository and run them, rather than copying them out of a web page.

```sh
git clone https://github.com/ash/raku.online
cd raku.online/examples/app-rakus
rakupp install App::Rakus
rakupp 01-tour.raku
```

Everything here runs under **Raku++** and under **Rakudo** — these are Raku
programs, not Raku++ programs. Swap `rakupp` for `raku` and they behave the
same; where the two engines genuinely differ, the page the example comes from
says so, and so does the file.

## What is here

| Directory | From the page | What it needs |
|---|---|---|
| [`app-rakus/`](app-rakus/) | [App::Rakus](https://raku.online/modules/app-rakus/) | `rakupp install App::Rakus` |
| [`base64/`](base64/) | [Base64](https://raku.online/modules/base64/) | `rakupp install Base64` |
| [`color/`](color/) | [Color](https://raku.online/modules/color/) | `rakupp install Color` |
| [`data-dump/`](data-dump/) | [Data::Dump](https://raku.online/modules/data-dump/) | `rakupp install Data::Dump` |
| [`data-generators/`](data-generators/) | [Data::Generators](https://raku.online/modules/data-generators/) | `rakupp install Data::Generators` |
| [`datetime-format/`](datetime-format/) | [DateTime::Format](https://raku.online/modules/datetime-format/) | `rakupp install DateTime::Format` |
| [`digest-hmac/`](digest-hmac/) | [Digest::HMAC](https://raku.online/modules/digest-hmac/) | `rakupp install Digest::HMAC` |
| [`file-directory-tree/`](file-directory-tree/) | [File::Directory::Tree](https://raku.online/modules/file-directory-tree/) | `rakupp install File::Directory::Tree` |
| [`file-find/`](file-find/) | [File::Find](https://raku.online/modules/file-find/) | `rakupp install File::Find` |
| [`file-temp/`](file-temp/) | [File::Temp](https://raku.online/modules/file-temp/) | `rakupp install File::Temp` |
| [`file-which/`](file-which/) | [File::Which](https://raku.online/modules/file-which/) | `rakupp install File::Which` |
| [`http-status/`](http-status/) | [HTTP::Status](https://raku.online/modules/http-status/) | `rakupp install HTTP::Status` |
| [`json-fast/`](json-fast/) | [JSON::Fast](https://raku.online/modules/json-fast/) | `rakupp install JSON::Fast` |
| [`json-native/`](json-native/) | [JSON::Native](https://raku.online/modules/json-native/) | `rakupp install JSON::Native` |
| [`json-tiny/`](json-tiny/) | [JSON::Tiny](https://raku.online/modules/json-tiny/) | `rakupp install JSON::Tiny` |
| [`method-also/`](method-also/) | [Method::Also](https://raku.online/modules/method-also/) | `rakupp install Method::Also` |
| [`mime-base64/`](mime-base64/) | [MIME::Base64](https://raku.online/modules/mime-base64/) | `rakupp install MIME::Base64` |
| [`shell-command/`](shell-command/) | [Shell::Command](https://raku.online/modules/shell-command/) | `rakupp install Shell::Command` |
| [`statistics-distributions/`](statistics-distributions/) | [Statistics::Distributions](https://raku.online/modules/statistics-distributions/) | `rakupp install Statistics::Distributions` |
| [`tap/`](tap/) | [TAP](https://raku.online/modules/tap/) | `rakupp install TAP` |
| [`terminal-ansicolor/`](terminal-ansicolor/) | [Terminal::ANSIColor](https://raku.online/modules/terminal-ansicolor/) | `rakupp install Terminal::ANSIColor` |
| [`test-meta/`](test-meta/) | [Test::META](https://raku.online/modules/test-meta/) | `rakupp install Test::META` |
| [`uri/`](uri/) | [URI](https://raku.online/modules/uri/) | `rakupp install URI` |
| [`uri-encode/`](uri-encode/) | [URI::Encode](https://raku.online/modules/uri-encode/) | `rakupp install URI::Encode` |
| [`uuid/`](uuid/) | [UUID](https://raku.online/modules/uuid/) | `rakupp install UUID` |
| [`xml/`](xml/) | [XML](https://raku.online/modules/xml/) | `rakupp install XML` |
| [`yamlish/`](yamlish/) | [YAMLish](https://raku.online/modules/yamlish/) | `rakupp install YAMLish` |

One directory per module of [the module handbook](https://raku.online/modules/).
Each has its own README listing its files.

## Where they come from, and why they can be trusted

These files are **generated from the pages they appear on**, so a file and its
page cannot drift apart. Each one is then *run* — under both engines, twice on
each — every time the site is built, and its output compared against the
`# Output:` comment at the bottom of the file. A file whose output has moved
fails that build.

So the output in a file is what it printed, not what it was once expected to
print. The exception is the files whose comment says *One run printed* — those
draw random numbers or show a run whose formatting the engines are still
converging on, and are run to prove they still work rather than to compare
what they say.

To re-run that check yourself:

```sh
cd sites/modules
rakupp build.raku --verify --oracle=raku
```

## Editing them

Edit the page, not the file: the module pages live in
`sites/modules/src/modules/`, and `./build.sh modules` regenerates both the
page and the files here.
