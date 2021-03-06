#!/opt/local/bin/perl -w
use strict;

# read in the file
#parrot it back out
# The only exceptions are (doc/NAME.md) which should get altered to (@ref NAME)

my $FILENAME = shift(@ARGV);

if($FILENAME =~ /.md$/)
{
	open(FILE, "<$FILENAME");

	my $cond = undef;
	my $inCode = undef;
	
	while(my $line = <FILE>)
	{
		my $altered_line = $line;
		
		# The below would handle code fences
		if(my ($filetype) = $altered_line =~ /^\s*```\s*([a-zA-Z]*)\s*$/)
		{
			if($filetype eq "objc")
			{
				$filetype = ".m"
			}
			
			if(not(defined($filetype)) or $filetype eq "")
			{
				$altered_line = "\\endcode";
			}
			else
			{
				$altered_line = "\\code{$filetype}";
			}
		}
		
		#patch up hyperlink references
		$altered_line =~ s/doc\/([A-Za-z0-9_-]+)\.md/\@ref $1/g;
		
		#remove lines hidden from doxygen
		$altered_line =~ s/^.*\(!doxygen\)\s*$//;
		
		#patch up image references
		$altered_line =~ s/!\[(.+)\]\(..\/(.+)\)/![$1]($2)/; 
		
		#fix up any code and endcode references where we want to hide the /** and */
		$altered_line =~ s/^\s*(\\code[{}.a-zA-Z0-9]*)\s+\*\/\s*$/$1/;
		$altered_line =~ s/^\s*\/\*\*\s*\\endcode\s*$/\\endcode/;
		
		#remove any code within a conditional
		if($line =~ /^\\cond\s*$/)
		{
			$cond = 1;
		}
		if($cond)
		{
			$altered_line = "";
		}
		if($line =~ /^\\endcond\s*$/)
		{
			$cond = undef;
		}
		print $altered_line;
	}

	close(FILE);
}
else
{
	print `./doxygen_preprocessor/doxygen_preprocessor.py $FILENAME`;
}