use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my %transcripts;
my %stop_codons;
my %range;

while (<IN>) {
    next if $_ =~ m/^#/;
    chomp;
    my @reflist = split(/\t/, $_);
    next unless $reflist[2] eq 'transcript';
    my $anno = $reflist[8];
    my $tranid;
    my $geneid;
    if ($anno =~ m/transcript_id "([^"]+)";/) {
        $tranid = $1;
    }else{
        die "wrong anno\n";
    }
    if ($anno =~ m/gene_id "([^"]+)";/) {
        $geneid = $1;
    }else{
        die "wrong anno\n";
    }

    #$tranid =~ s/\.(.+)//;
    if (exists($range{$geneid})) {
        my $ranges1 = (split(/\n/, $range{$geneid}))[0];
        my @formerinf = split(/\t/, $ranges1);
        die "wrong gene infor" if $reflist[0] ne $formerinf[0];
        die "wrong gene infor" if $reflist[6] ne $formerinf[3];
    }
    
    if (exists($transcripts{$tranid})) {
        die "1 double tranid $tranid\n";
    }else{
        #print OUT "$reflist[0]\$tranid\n";
        if (exists($range{$geneid})) {
            $range{$geneid} = "$range{$geneid}\n"."$reflist[0]\t$reflist[3]\t$reflist[4]\t$reflist[6]";
        }else{
            $range{$geneid} = "$reflist[0]\t$reflist[3]\t$reflist[4]\t$reflist[6]";
        }
        
    }

}
close IN;

my @sortedgenes = sort {$a cmp $b} keys(%range);
for my $genevar (@sortedgenes) {
    my $mergekey = mergeranges($range{$genevar});
    my @outrange = @{$mergekey};
    for my $varout (@outrange) {
        my @outarr = split(/\t/, $varout);
        my $bedbegin = $outarr[1]-1;
        print OUT "$outarr[0]\t$bedbegin\t$outarr[2]\t$genevar\t0\t$outarr[3]\n";
    }
}

close OUT;

sub mergeranges {
    my @ranges = split(/\n/, $_[0]);
    my @sortedranges = sort { (split(/\t/, $a))[1] <=> (split(/\t/, $b))[1] } @ranges;
    my $beginrange = shift(@sortedranges);
    my @outrange;
    for my $var (@sortedranges) {
        my @begininf = split(/\t/, $beginrange);
        my @nowinf = split(/\t/, $var);
        my $nowbegin = $begininf[1];
        my $nowend = $begininf[2];
        my $thisbegin = $nowinf[1];
        my $thisend = $nowinf[2];
        if ($nowend < $thisbegin - 1) {
            push @outrange, $beginrange;
            $beginrange = $var;
        }else{
            if ($nowend <= $thisend) {
                $beginrange = "$begininf[0]\t$nowbegin\t$thisend\t$begininf[3]";
            }else{
                $beginrange = "$begininf[0]\t$nowbegin\t$nowend\t$begininf[3]";
            }
        }
    
    }
    push @outrange, "$beginrange";
    #my $outrange = join("\n", @outrange);
    return \@outrange;
   
}