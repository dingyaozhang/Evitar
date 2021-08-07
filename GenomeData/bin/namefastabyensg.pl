use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o $opt_l);
getopts('i:o:l');


local $/ = ">";
open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;
my $fastanull = <IN>;


while (<IN>) {
	chomp;
	next if length $_ == 0;
	my @array = split(/\n/, $_);
	my $name = shift(@array);
	my $seq = join("", @array);
	my $purename = $name;
	if ($purename =~ m/(ENSG[^.]+)\./) {
		$purename = $1;
	}else{
		die "wrong ref name\n" unless $opt_l;
	}
	$seq =~ tr/a-z/A-Z/;
	$seq =~ s/U/T/g;
	print OUT ">$purename\n$seq\n"
}
close IN;
close OUT;