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
| [`color-names/`](color-names/) | [Color::Names](https://raku.online/modules/color-names/) | `rakupp install Color::Names` |
| [`config/`](config/) | [Config](https://raku.online/modules/config/) | `rakupp install Config` |
| [`config-ini/`](config-ini/) | [Config::INI](https://raku.online/modules/config-ini/) | `rakupp install Config::INI` |
| [`crypt-random/`](crypt-random/) | [Crypt::Random](https://raku.online/modules/crypt-random/) | `rakupp install Crypt::Random` |
| [`csv-parser/`](csv-parser/) | [CSV::Parser](https://raku.online/modules/csv-parser/) | `rakupp install CSV::Parser` |
| [`data-dump/`](data-dump/) | [Data::Dump](https://raku.online/modules/data-dump/) | `rakupp install Data::Dump` |
| [`data-generators/`](data-generators/) | [Data::Generators](https://raku.online/modules/data-generators/) | `rakupp install Data::Generators` |
| [`data-typesystem/`](data-typesystem/) | [Data::TypeSystem](https://raku.online/modules/data-typesystem/) | `rakupp install Data::TypeSystem` |
| [`date-calendar-strftime/`](date-calendar-strftime/) | [Date::Calendar::Strftime](https://raku.online/modules/date-calendar-strftime/) | `rakupp install Date::Calendar::Strftime` |
| [`date-names/`](date-names/) | [Date::Names](https://raku.online/modules/date-names/) | `rakupp install Date::Names` |
| [`datetime-format/`](datetime-format/) | [DateTime::Format](https://raku.online/modules/datetime-format/) | `rakupp install DateTime::Format` |
| [`datetime-parse/`](datetime-parse/) | [DateTime::Parse](https://raku.online/modules/datetime-parse/) | `rakupp install DateTime::Parse` |
| [`dbiish/`](dbiish/) | [DBIish](https://raku.online/modules/dbiish/) | `rakupp install DBIish` |
| [`digest/`](digest/) | [Digest](https://raku.online/modules/digest/) | `rakupp install Digest` |
| [`digest-hmac/`](digest-hmac/) | [Digest::HMAC](https://raku.online/modules/digest-hmac/) | `rakupp install Digest::HMAC` |
| [`digest-sha1-native/`](digest-sha1-native/) | [Digest::SHA1::Native](https://raku.online/modules/digest-sha1-native/) | `rakupp install Digest::SHA1::Native` |
| [`digest-sha256-native/`](digest-sha256-native/) | [Digest::SHA256::Native](https://raku.online/modules/digest-sha256-native/) | `rakupp install Digest::SHA256::Native` |
| [`file-directory-tree/`](file-directory-tree/) | [File::Directory::Tree](https://raku.online/modules/file-directory-tree/) | `rakupp install File::Directory::Tree` |
| [`file-find/`](file-find/) | [File::Find](https://raku.online/modules/file-find/) | `rakupp install File::Find` |
| [`file-temp/`](file-temp/) | [File::Temp](https://raku.online/modules/file-temp/) | `rakupp install File::Temp` |
| [`file-which/`](file-which/) | [File::Which](https://raku.online/modules/file-which/) | `rakupp install File::Which` |
| [`getopt-long/`](getopt-long/) | [Getopt::Long](https://raku.online/modules/getopt-long/) | `rakupp install Getopt::Long` |
| [`hash-merge/`](hash-merge/) | [Hash::Merge](https://raku.online/modules/hash-merge/) | `rakupp install Hash::Merge` |
| [`html-escape/`](html-escape/) | [HTML::Escape](https://raku.online/modules/html-escape/) | `rakupp install HTML::Escape` |
| [`http-status/`](http-status/) | [HTTP::Status](https://raku.online/modules/http-status/) | `rakupp install HTTP::Status` |
| [`http-tiny/`](http-tiny/) | [HTTP::Tiny](https://raku.online/modules/http-tiny/) | `rakupp install HTTP::Tiny` |
| [`io-glob/`](io-glob/) | [IO::Glob](https://raku.online/modules/io-glob/) | `rakupp install IO::Glob` |
| [`json-class/`](json-class/) | [JSON::Class](https://raku.online/modules/json-class/) | `rakupp install JSON::Class` |
| [`json-fast/`](json-fast/) | [JSON::Fast](https://raku.online/modules/json-fast/) | `rakupp install JSON::Fast` |
| [`json-native/`](json-native/) | [JSON::Native](https://raku.online/modules/json-native/) | `rakupp install JSON::Native` |
| [`json-tiny/`](json-tiny/) | [JSON::Tiny](https://raku.online/modules/json-tiny/) | `rakupp install JSON::Tiny` |
| [`meta6/`](meta6/) | [META6](https://raku.online/modules/meta6/) | `rakupp install META6` |
| [`method-also/`](method-also/) | [Method::Also](https://raku.online/modules/method-also/) | `rakupp install Method::Also` |
| [`mime-base64/`](mime-base64/) | [MIME::Base64](https://raku.online/modules/mime-base64/) | `rakupp install MIME::Base64` |
| [`mime-types/`](mime-types/) | [MIME::Types](https://raku.online/modules/mime-types/) | `rakupp install MIME::Types` |
| [`nativehelpers-array/`](nativehelpers-array/) | [NativeHelpers::Array](https://raku.online/modules/nativehelpers-array/) | `rakupp install NativeHelpers::Array` |
| [`oo-monitors/`](oo-monitors/) | [OO::Monitors](https://raku.online/modules/oo-monitors/) | `rakupp install OO::Monitors` |
| [`openssl/`](openssl/) | [OpenSSL](https://raku.online/modules/openssl/) | `rakupp install OpenSSL` |
| [`shell-command/`](shell-command/) | [Shell::Command](https://raku.online/modules/shell-command/) | `rakupp install Shell::Command` |
| [`statistics-distributions/`](statistics-distributions/) | [Statistics::Distributions](https://raku.online/modules/statistics-distributions/) | `rakupp install Statistics::Distributions` |
| [`svg/`](svg/) | [SVG](https://raku.online/modules/svg/) | `rakupp install SVG` |
| [`tap/`](tap/) | [TAP](https://raku.online/modules/tap/) | `rakupp install TAP` |
| [`terminal-ansi/`](terminal-ansi/) | [Terminal::ANSI](https://raku.online/modules/terminal-ansi/) | `rakupp install Terminal::ANSI` |
| [`terminal-ansicolor/`](terminal-ansicolor/) | [Terminal::ANSIColor](https://raku.online/modules/terminal-ansicolor/) | `rakupp install Terminal::ANSIColor` |
| [`terminal-wcwidth/`](terminal-wcwidth/) | [Terminal::WCWidth](https://raku.online/modules/terminal-wcwidth/) | `rakupp install Terminal::WCWidth` |
| [`test-meta/`](test-meta/) | [Test::META](https://raku.online/modules/test-meta/) | `rakupp install Test::META` |
| [`test-output/`](test-output/) | [Test::Output](https://raku.online/modules/test-output/) | `rakupp install Test::Output` |
| [`text-levenshtein-damerau/`](text-levenshtein-damerau/) | [Text::Levenshtein::Damerau](https://raku.online/modules/text-levenshtein-damerau/) | `rakupp install Text::Levenshtein::Damerau` |
| [`text-miscutils/`](text-miscutils/) | [Text::MiscUtils](https://raku.online/modules/text-miscutils/) | `rakupp install Text::MiscUtils` |
| [`text-utils/`](text-utils/) | [Text::Utils](https://raku.online/modules/text-utils/) | `rakupp install Text::Utils` |
| [`text-wrap/`](text-wrap/) | [Text::Wrap](https://raku.online/modules/text-wrap/) | `rakupp install Text::Wrap` |
| [`uri/`](uri/) | [URI](https://raku.online/modules/uri/) | `rakupp install URI` |
| [`uri-encode/`](uri-encode/) | [URI::Encode](https://raku.online/modules/uri-encode/) | `rakupp install URI::Encode` |
| [`uuid/`](uuid/) | [UUID](https://raku.online/modules/uuid/) | `rakupp install UUID` |
| [`uuid-v4/`](uuid-v4/) | [UUID::V4](https://raku.online/modules/uuid-v4/) | `rakupp install UUID::V4` |
| [`xdg-basedirectory/`](xdg-basedirectory/) | [XDG::BaseDirectory](https://raku.online/modules/xdg-basedirectory/) | `rakupp install XDG::BaseDirectory` |
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
rakupp build.raku --verify --oracle=rakudo
```

## Editing them

Edit the page, not the file: the module pages live in
`sites/modules/src/modules/`, and `./build.sh modules` regenerates both the
page and the files here.
