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
	print "Usage: $0";
}
my $crawl_depth = -1;
my $crawl_domain = "";
my $verbose = 0;
GetOptions("crawl-depth=i" => \$crawl_depth
	,"domain=s" => \$crawl_domain
	,"verbose" => \$verbose
) or die("Bad command line arguments");
my $start_url = shift @ARGV;

if (!($start_url =~ m/https?\:\/\//)) {
	$start_url = "http://$start_url";
}
if ($verbose > 1) {
	print "crawl-depth=$crawl_depth\n";
	print "crawl-domain=$crawl_domain\n";
	print "start_url=$start_url\n";
}
my $mech = WWW::Mechanize->new(autocheck=>0);

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
	my $res = $mech->get($current_url);
	if ($res->code % 100 == 4) {
		print "$current_url is broken!\n";
		next;
	} elsif ($verbose > 0) {
		print "$current_url [OK]\n";
	}
	if ($crawl_domain && !($current_url =~ m/$crawl_domain/)) {
		next;
	}
	my @links = $mech->links();
	my $new_depth = $depth+1;
	foreach my $sublink (@links) {
		my $sublink_url = $sublink->url_abs();
		next if ($sublink_url =~ m/^mailto:/);
		push @url_stack, {$sublink_url, $new_depth};
	}
}
