# bad-link-finder
A small spider that crawls starting at a "root" URL and looks for broken links.

Optionally, crawling depth can be limited, as well as crawling only within the domain.

## Modules to install (dependencies)
* `WWW::Mechanize` used for downloading the content & parsing the links.
* `LWP::Protocol::https` needs to be installed if you want it to check `https://` links.

## Usage
`./crawler.pl --domain somewebsite.com --crawl-depth 5 --verbose URL`

The URL parameter is mandatory. The `--domain`, `--crawl-depth`, and `--verbose
parameters are not.

Options:
* `--domain`: Restrict crawling to the specified domain only (e.g. catb.org).
The idea is that links that point to outside the domain being crawled will be
checked, but not recursively crawled.
* `--crawl-depth`: Restrict crawling only up to the specified link depth (where
link depth is the distance from the root URL).
* `--verbose`: Print links as they are checked (marked with `[OK]`), or print the
specified configuration options.


(short options can also be used like `-d`, `-c` or `-v`, thanks to `Getopt::Long`)
