# Examples

Working programs from [raku.online](https://raku.online), one file each — clone
this repository and run them, rather than copying them out of a web page.

```sh
git clone https://github.com/ash/raku.online
cd raku.online/examples/abbreviations
rakupp install Abbreviations
rakupp 01-shapes.raku
```

Everything here runs under **Raku++** and under **Rakudo** — these are Raku
programs, not Raku++ programs. Swap `rakupp` for `raku` and they behave the
same; where the two engines genuinely differ, the page the example comes from
says so, and so does the file.

## What is here

| Directory | From the page | What it needs |
|---|---|---|
| [`abbreviations/`](abbreviations/) | [Abbreviations](https://raku.online/modules/abbreviations/) | `rakupp install Abbreviations` |
| [`app-rakus/`](app-rakus/) | [App::Rakus](https://raku.online/modules/app-rakus/) | `rakupp install App::Rakus` |
| [`base64/`](base64/) | [Base64](https://raku.online/modules/base64/) | `rakupp install Base64` |
| [`color/`](color/) | [Color](https://raku.online/modules/color/) | `rakupp install Color` |
| [`color-names/`](color-names/) | [Color::Names](https://raku.online/modules/color-names/) | `rakupp install Color::Names` |
| [`compress-zlib-raw/`](compress-zlib-raw/) | [Compress::Zlib::Raw](https://raku.online/modules/compress-zlib-raw/) | `rakupp install Compress::Zlib::Raw` |
| [`config/`](config/) | [Config](https://raku.online/modules/config/) | `rakupp install Config` |
| [`config-clever/`](config-clever/) | [Config::Clever](https://raku.online/modules/config-clever/) | `rakupp install Config::Clever` |
| [`config-ini/`](config-ini/) | [Config::INI](https://raku.online/modules/config-ini/) | `rakupp install Config::INI` |
| [`crypt-random/`](crypt-random/) | [Crypt::Random](https://raku.online/modules/crypt-random/) | `rakupp install Crypt::Random` |
| [`csv-parser/`](csv-parser/) | [CSV::Parser](https://raku.online/modules/csv-parser/) | `rakupp install CSV::Parser` |
| [`data-dump/`](data-dump/) | [Data::Dump](https://raku.online/modules/data-dump/) | `rakupp install Data::Dump` |
| [`data-generators/`](data-generators/) | [Data::Generators](https://raku.online/modules/data-generators/) | `rakupp install Data::Generators` |
| [`data-typesystem/`](data-typesystem/) | [Data::TypeSystem](https://raku.online/modules/data-typesystem/) | `rakupp install Data::TypeSystem` |
| [`date-calendar-strftime/`](date-calendar-strftime/) | [Date::Calendar::Strftime](https://raku.online/modules/date-calendar-strftime/) | `rakupp install Date::Calendar::Strftime` |
| [`date-event/`](date-event/) | [Date::Event](https://raku.online/modules/date-event/) | `rakupp install Date::Event` |
| [`date-names/`](date-names/) | [Date::Names](https://raku.online/modules/date-names/) | `rakupp install Date::Names` |
| [`date-utils/`](date-utils/) | [Date::Utils](https://raku.online/modules/date-utils/) | `rakupp install Date::Utils` |
| [`datetime-format/`](datetime-format/) | [DateTime::Format](https://raku.online/modules/datetime-format/) | `rakupp install DateTime::Format` |
| [`datetime-grammar/`](datetime-grammar/) | [DateTime::Grammar](https://raku.online/modules/datetime-grammar/) | `rakupp install DateTime::Grammar` |
| [`datetime-parse/`](datetime-parse/) | [DateTime::Parse](https://raku.online/modules/datetime-parse/) | `rakupp install DateTime::Parse` |
| [`dbiish/`](dbiish/) | [DBIish](https://raku.online/modules/dbiish/) | `rakupp install DBIish` |
| [`digest/`](digest/) | [Digest](https://raku.online/modules/digest/) | `rakupp install Digest` |
| [`digest-hmac/`](digest-hmac/) | [Digest::HMAC](https://raku.online/modules/digest-hmac/) | `rakupp install Digest::HMAC` |
| [`digest-md5/`](digest-md5/) | [Digest::MD5](https://raku.online/modules/digest-md5/) | `rakupp install Digest::MD5` |
| [`digest-sha1-native/`](digest-sha1-native/) | [Digest::SHA1::Native](https://raku.online/modules/digest-sha1-native/) | `rakupp install Digest::SHA1::Native` |
| [`digest-sha256-native/`](digest-sha256-native/) | [Digest::SHA256::Native](https://raku.online/modules/digest-sha256-native/) | `rakupp install Digest::SHA256::Native` |
| [`encode/`](encode/) | [Encode](https://raku.online/modules/encode/) | `rakupp install Encode` |
| [`file-directory-tree/`](file-directory-tree/) | [File::Directory::Tree](https://raku.online/modules/file-directory-tree/) | `rakupp install File::Directory::Tree` |
| [`file-find/`](file-find/) | [File::Find](https://raku.online/modules/file-find/) | `rakupp install File::Find` |
| [`file-path-resolve/`](file-path-resolve/) | [File::Path::Resolve](https://raku.online/modules/file-path-resolve/) | `rakupp install File::Path::Resolve` |
| [`file-presence/`](file-presence/) | [File::Presence](https://raku.online/modules/file-presence/) | `rakupp install File::Presence` |
| [`file-stat/`](file-stat/) | [File::Stat](https://raku.online/modules/file-stat/) | `rakupp install File::Stat` |
| [`file-temp/`](file-temp/) | [File::Temp](https://raku.online/modules/file-temp/) | `rakupp install File::Temp` |
| [`file-which/`](file-which/) | [File::Which](https://raku.online/modules/file-which/) | `rakupp install File::Which` |
| [`game-stats/`](game-stats/) | [Game::Stats](https://raku.online/modules/game-stats/) | `rakupp install Game::Stats` |
| [`geo-geometry/`](geo-geometry/) | [Geo::Geometry](https://raku.online/modules/geo-geometry/) | `rakupp install Geo::Geometry` |
| [`getopt-long/`](getopt-long/) | [Getopt::Long](https://raku.online/modules/getopt-long/) | `rakupp install Getopt::Long` |
| [`glob-grammar/`](glob-grammar/) | [Glob::Grammar](https://raku.online/modules/glob-grammar/) | `rakupp install Glob::Grammar` |
| [`hash-merge/`](hash-merge/) | [Hash::Merge](https://raku.online/modules/hash-merge/) | `rakupp install Hash::Merge` |
| [`hash-ordered/`](hash-ordered/) | [Hash::Ordered](https://raku.online/modules/hash-ordered/) | `rakupp install Hash::Ordered` |
| [`html-escape/`](html-escape/) | [HTML::Escape](https://raku.online/modules/html-escape/) | `rakupp install HTML::Escape` |
| [`http-hpack/`](http-hpack/) | [HTTP::HPACK](https://raku.online/modules/http-hpack/) | `rakupp install HTTP::HPACK` |
| [`http-status/`](http-status/) | [HTTP::Status](https://raku.online/modules/http-status/) | `rakupp install HTTP::Status` |
| [`http-tiny/`](http-tiny/) | [HTTP::Tiny](https://raku.online/modules/http-tiny/) | `rakupp install HTTP::Tiny` |
| [`i18n-simple/`](i18n-simple/) | [I18n::Simple](https://raku.online/modules/i18n-simple/) | `rakupp install I18n::Simple` |
| [`idna-punycode/`](idna-punycode/) | [IDNA::Punycode](https://raku.online/modules/idna-punycode/) | `rakupp install IDNA::Punycode` |
| [`intl-languagetaggish/`](intl-languagetaggish/) | [Intl::LanguageTaggish](https://raku.online/modules/intl-languagetaggish/) | `rakupp install Intl::LanguageTaggish` |
| [`io-glob/`](io-glob/) | [IO::Glob](https://raku.online/modules/io-glob/) | `rakupp install IO::Glob` |
| [`io-path-xdg/`](io-path-xdg/) | [IO::Path::XDG](https://raku.online/modules/io-path-xdg/) | `rakupp install IO::Path::XDG` |
| [`irc-textcolor/`](irc-textcolor/) | [IRC::TextColor](https://raku.online/modules/irc-textcolor/) | `rakupp install IRC::TextColor` |
| [`json-class/`](json-class/) | [JSON::Class](https://raku.online/modules/json-class/) | `rakupp install JSON::Class` |
| [`json-fast/`](json-fast/) | [JSON::Fast](https://raku.online/modules/json-fast/) | `rakupp install JSON::Fast` |
| [`json-jwt/`](json-jwt/) | [JSON::JWT](https://raku.online/modules/json-jwt/) | `rakupp install JSON::JWT` |
| [`json-marshal/`](json-marshal/) | [JSON::Marshal](https://raku.online/modules/json-marshal/) | `rakupp install JSON::Marshal` |
| [`json-name/`](json-name/) | [JSON::Name](https://raku.online/modules/json-name/) | `rakupp install JSON::Name` |
| [`json-native/`](json-native/) | [JSON::Native](https://raku.online/modules/json-native/) | `rakupp install JSON::Native` |
| [`json-optin/`](json-optin/) | [JSON::OptIn](https://raku.online/modules/json-optin/) | `rakupp install JSON::OptIn` |
| [`json-pretty/`](json-pretty/) | [JSON::Pretty](https://raku.online/modules/json-pretty/) | `rakupp install JSON::Pretty` |
| [`json-tiny/`](json-tiny/) | [JSON::Tiny](https://raku.online/modules/json-tiny/) | `rakupp install JSON::Tiny` |
| [`json-unmarshal/`](json-unmarshal/) | [JSON::Unmarshal](https://raku.online/modules/json-unmarshal/) | `rakupp install JSON::Unmarshal` |
| [`lingua-numericwordforms/`](lingua-numericwordforms/) | [Lingua::NumericWordForms](https://raku.online/modules/lingua-numericwordforms/) | `rakupp install Lingua::NumericWordForms` |
| [`log/`](log/) | [Log](https://raku.online/modules/log/) | `rakupp install Log` |
| [`logger/`](logger/) | [Logger](https://raku.online/modules/logger/) | `rakupp install Logger` |
| [`math-distancefunctions/`](math-distancefunctions/) | [Math::DistanceFunctions](https://raku.online/modules/math-distancefunctions/) | `rakupp install Math::DistanceFunctions` |
| [`math-distancefunctions-edit/`](math-distancefunctions-edit/) | [Math::DistanceFunctions::Edit](https://raku.online/modules/math-distancefunctions-edit/) | `rakupp install Math::DistanceFunctions::Edit` |
| [`math-nearest/`](math-nearest/) | [Math::Nearest](https://raku.online/modules/math-nearest/) | `rakupp install Math::Nearest` |
| [`math-random/`](math-random/) | [Math::Random](https://raku.online/modules/math-random/) | `rakupp install Math::Random` |
| [`math-specialfunctions/`](math-specialfunctions/) | [Math::SpecialFunctions](https://raku.online/modules/math-specialfunctions/) | `rakupp install Math::SpecialFunctions` |
| [`meta6/`](meta6/) | [META6](https://raku.online/modules/meta6/) | `rakupp install META6` |
| [`method-also/`](method-also/) | [Method::Also](https://raku.online/modules/method-also/) | `rakupp install Method::Also` |
| [`mime-base64/`](mime-base64/) | [MIME::Base64](https://raku.online/modules/mime-base64/) | `rakupp install MIME::Base64` |
| [`mime-types/`](mime-types/) | [MIME::Types](https://raku.online/modules/mime-types/) | `rakupp install MIME::Types` |
| [`nativehelpers-array/`](nativehelpers-array/) | [NativeHelpers::Array](https://raku.online/modules/nativehelpers-array/) | `rakupp install NativeHelpers::Array` |
| [`oo-monitors/`](oo-monitors/) | [OO::Monitors](https://raku.online/modules/oo-monitors/) | `rakupp install OO::Monitors` |
| [`openssl/`](openssl/) | [OpenSSL](https://raku.online/modules/openssl/) | `rakupp install OpenSSL` |
| [`p5localtime/`](p5localtime/) | [P5localtime](https://raku.online/modules/p5localtime/) | `rakupp install P5localtime` |
| [`path-finder/`](path-finder/) | [Path::Finder](https://raku.online/modules/path-finder/) | `rakupp install Path::Finder` |
| [`shell-command/`](shell-command/) | [Shell::Command](https://raku.online/modules/shell-command/) | `rakupp install Shell::Command` |
| [`statistics-distributions/`](statistics-distributions/) | [Statistics::Distributions](https://raku.online/modules/statistics-distributions/) | `rakupp install Statistics::Distributions` |
| [`svg/`](svg/) | [SVG](https://raku.online/modules/svg/) | `rakupp install SVG` |
| [`tap/`](tap/) | [TAP](https://raku.online/modules/tap/) | `rakupp install TAP` |
| [`terminal-ansi/`](terminal-ansi/) | [Terminal::ANSI](https://raku.online/modules/terminal-ansi/) | `rakupp install Terminal::ANSI` |
| [`terminal-ansicolor/`](terminal-ansicolor/) | [Terminal::ANSIColor](https://raku.online/modules/terminal-ansicolor/) | `rakupp install Terminal::ANSIColor` |
| [`terminal-getpass/`](terminal-getpass/) | [Terminal::Getpass](https://raku.online/modules/terminal-getpass/) | `rakupp install Terminal::Getpass` |
| [`terminal-spinners/`](terminal-spinners/) | [Terminal::Spinners](https://raku.online/modules/terminal-spinners/) | `rakupp install Terminal::Spinners` |
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
