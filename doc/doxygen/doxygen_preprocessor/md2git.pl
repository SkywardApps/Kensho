#!/opt/local/bin/perl -w
use strict;

# read in the file
#parrot it back out
# The only exceptions are (doc/NAME.md) which should get altered to (@ref NAME)

my $FILENAME = shift(@ARGV);

if($FILENAME =~ /.md$/)
{
	open(FILE, "<$FILENAME");

	while(my $line = <FILE>)
	{
		my $altered_line = $line;
		$altered_line =~ s/doc\/([A-Za-z0-9_-]+)\.md/\@ref $1/g;
		print $altered_line;
	}

	close(FILE);
}
else
{
	print `./doxygen_preprocessor/doxygen_preprocessor.py $FILENAME`;
}