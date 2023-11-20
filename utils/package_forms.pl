#!/usr/bin/perl

# package_forms.pl - create a zip with index and all pknet forms for distribution
#
# 20231106 kn4lqn

use strict;

use Mojo::File;


my $online_location = "http://vden.org/pktnet";

if (!-d "pktnet/src") { `mkdir -p "pktnet/src"`; }

my $save_as = "pktnet-forms.zip";

my @files = `ls *.html`; chomp @files;
foreach my $file (@files) {
	if ($file eq "index.html" || $file eq "blank.html") { next; }
	if ($file eq "local_wx.html" || $file eq "blank.html") { next; }

	my $online_link = qq{<a href="$online_location/$file">Use the latest version of this form online</a>};

	my $contents = Mojo::File->new($file)->slurp();

	while ($contents =~ /<script src="(http.*?)"/) {
		my $src = $1;

		my $src_filename = $src;
		$src_filename =~ s/^.*\///g;

		if (!-e "pktnet/src/$src_filename") {
			`curl "$src" -o "pktnet/src/$src_filename"`;
		}

		$contents =~ s/src="$src"/src="src\/$src_filename"/g;
	}
	while ($contents =~ /<link.*?href="((http:)?\/\/.*?)"/) {
		my $src = $1;

		my $src_filename = $src;
		$src_filename =~ s/^.*\///g;

		if (!-e "pktnet/src/$src_filename") {
			if ($src !~ /^http/) {
				`curl "https:$src" -o "pktnet/src/$src_filename"`;
			} else {
				`curl "$src" -o "pktnet/src/$src_filename"`;
			}
		}

		$contents =~ s/href="$src"/href="src\/$src_filename"/g;
	}

	$contents =~ s/<a href="\/pktnet\/pktnet-forms.zip".*?<\/a>/$online_link/;

	Mojo::File->new("pktnet/$file")->spurt($contents);
}


my $contents = Mojo::File->new("index.html")->slurp();
my $online_link = qq{<a href="$online_location/">Use the latest version of these forms online</a>};
$contents =~ s/<a href="pktnet-forms.zip".*?<\/a>/$online_link/;
Mojo::File->new("pktnet/index.html")->spurt($contents);


unlink($save_as);
`zip -r $save_as pktnet`;

foreach my $file (@files) {
	unlink("pktnet/$file");
}


__END__

directory structure:

pktnet/
 ics213.html
 src/
  jquery-3.7.1.min.js
  jquery-ui.css
  jquery-ui.js
  
