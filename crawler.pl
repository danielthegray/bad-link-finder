#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use WWW::Mechanize;

sub domain_from_url {
	my $url = shift;
	return $url =~ s/(https?\:\/\/)?([a-zA-Z0-9.]+)\/.*/$2/;
}

if (@ARGV == 0) {
	print "Usage: $0 --domain somewebsite.com --crawl-depth 5 --verbose URL\n";
	print "\n";
	print "Command line options:\n";
	print "* --domain: Restrict crawling to the specified domain only.\n";
	print "* --crawl-depth: Restricting crawling only up to the specified link depth\n";
	print "* --verbose: Print links as they are checked (marked with [OK]).\n";
	print "You MUST specify a root URL parameter. All other options are not.\n";
	print "Crawling can be limited by restricting it only to the specified domain\n";
	print "which will check links to other domains but not follow any links there.\n";
	print "It can also be limited by crawl depth, with is the number of 'hops' from\nthe root URL\n";
	print "(short options can also be used like -d, -c or -v, thanks to Getopt::Long)\n\n";
	exit 1;
}
my $crawl_depth = -1;
my $crawl_domain = "";
my $verbose = 0;
GetOptions("crawl-depth=i" => \$crawl_depth
	,"domain=s" => \$crawl_domain
	,"verbose" => \$verbose
) or die("Bad command line arguments");
my $start_url = shift @ARGV;
if (not $start_url) {
	print "No crawl root URL defined!";
	exit 2;
}

if (!($start_url =~ m/https?\:\/\//)) {
	$start_url = "http://$start_url";
}
if ($verbose > 1) {
	print "crawl-depth=$crawl_depth\n";
	print "crawl-domain=$crawl_domain\n";
	print "start_url=$start_url\n";
}
my $crawler = WWW::Mechanize->new(autocheck=>0);

my %checked_links = ();
my @url_stack = ();
push @url_stack, {$start_url, 0};

while (@url_stack > 0) {
	my $url_and_depth = pop @url_stack;
	my $current_url = (keys %$url_and_depth)[0];
	my $depth = $url_and_depth->{$current_url};
	if ($crawl_depth != -1 && $depth > $crawl_depth) {
		next;
	}
	# skip links I've already seen before
	if ($checked_links{$current_url}) {
		next;
	}
	$checked_links{$current_url}++;
	my $res = $crawler->get($current_url);
	my $html_code_group = int($res->code / 100);
	if ($html_code_group != 2 && $html_code_group != 3) {
		print "$current_url [BROKEN! - ".$res->code."]\n";
		next;
	} elsif ($verbose > 0) {
		print "$current_url [OK]\n";
	}
	if ($crawl_domain && !($current_url =~ m/$crawl_domain/)) {
		next;
	}
	my @links = $crawler->links();
	my $new_depth = $depth+1;
	foreach my $sublink (@links) {
		my $sublink_url = $sublink->url_abs();
		next if ($sublink_url =~ m/^mailto:/);
		push @url_stack, {$sublink_url, $new_depth};
	}
}
