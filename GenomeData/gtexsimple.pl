#!/usr/bin/perl -w 
use strict;
use warnings;

#set default should use our! like:
#our $opt_i
#use Getopt::Std;
#use vars qw($opt_i $opt_o);
#getopts('i:o:');

open IN, "GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt" or die;
open OUT, '>', "sample2tissue.txt" or die;

my $line1 = <IN>;
my %output;
while (<IN>) {
    chomp;
    my ($name, $tissue) = (split(/\t/, $_))[0,5];
    if (exists($output{$tissue})) {
        $output{$tissue} .= "\t$name";
    }else{
        $output{$tissue} = $name;
    }
}
my @keys = sort {$a cmp $b} keys(%output);
for my $var (@keys) {
    my @array = split(/\t/, $output{$var});
    for my $var2 (@array) {
        print OUT "$var2\t$var\n";
    }
}


close IN;
close OUT;