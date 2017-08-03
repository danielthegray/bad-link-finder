# bad-link-finder
A small spider that crawls starting at a "root" URL and looks for broken links.

Optionally, crawling depth can be limited, as well as crawling only within the domain.

## Modules to install (dependencies)
`WWW::Mechanize` used for downloading the content & parsing the links.
`LWP::Protocol::https` needs to be installed if you want it to check `https://` links.

## Usage
`./crawler.pl --domain somewebsite.com --crawl-depth 5 --verbose URL`
Options:
* `--domain`: Restrict crawling to the specified domain only.
* `--crawl-depth`: Restricting crawling only up to the specified link depth
* `--verbose`: Print links as they are checked (marked with `[OK]`).
(short options can also be used like `-d`, `-c` or `-v`, thanks to `Getopt::Long`)
