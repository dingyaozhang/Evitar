use strict;
use warnings;


use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts('i:o:');

open IN, "$opt_i" or die;
open OUT, '>', "$opt_o" or die;

my %transcripts;
my %stop_codons;

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
    }
    if ($anno =~ m/gene_id "([^"]+)";/) {
        $geneid = $1;
    }
    #$tranid =~ s/\.(.+)//;
    if (exists($transcripts{$tranid})) {
        die "1 double tranid $tranid\n";
    }else{
        $transcripts{$tranid} = "$reflist[0]\t$reflist[3]\t$reflist[4]\t$reflist[6]\t$geneid";
    }
}
close IN;


open IN, "$opt_i" or die;
while (<IN>) {  
    next if $_ =~ m/^#/;
    chomp;
    my @reflist = split(/\t/, $_);
    next unless $reflist[2] eq 'stop_codon';
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
    if (exists($stop_codons{$tranid})) {
        my @smalltemp = split(/\t/, $stop_codons{$tranid});
        if ($reflist[6] eq '+') {
            $stop_codons{$tranid} = "$reflist[0]\t$reflist[3]\t$reflist[4]\t$reflist[6]\t$geneid" if $reflist[4] > $smalltemp[2];
        }else{
            $stop_codons{$tranid} = "$reflist[0]\t$reflist[3]\t$reflist[4]\t$reflist[6]\t$geneid" if $reflist[3] < $smalltemp[1];
        }
    }else{
        $stop_codons{$tranid} = "$reflist[0]\t$reflist[3]\t$reflist[4]\t$reflist[6]\t$geneid";
    }
}
close IN;

my %repeatareas;
my @sortedkeys = sort {$a cmp $b} keys(%stop_codons);
for my $tranid (@sortedkeys) {
    my $trandata = $transcripts{$tranid};
    my @trandata = split(/\t/, $trandata);
    my $codondata = $stop_codons{$tranid};
    my @codondata = split(/\t/, $codondata);

    if ($trandata[3] eq '+') {
        if (exists($repeatareas{$trandata[4]})) {
            $repeatareas{$trandata[4]} = "$repeatareas{$trandata[4]}\n$trandata[0]\t$codondata[2]\t$trandata[2]\t+";
        }else{
            $repeatareas{$trandata[4]} = "$trandata[0]\t$codondata[2]\t$trandata[2]\t+";
        }
        
    }else{
        if (exists($repeatareas{$trandata[4]})) {
            $repeatareas{$trandata[4]} = "$repeatareas{$trandata[4]}\n$trandata[0]\t$trandata[1]\t$codondata[1]\t-";
        }else{
            $repeatareas{$trandata[4]} = "$trandata[0]\t$trandata[1]\t$codondata[1]\t-";
        }
    }
        
}


my @sortedgenes = sort {$a cmp $b} keys(%repeatareas);
for my $genevar (@sortedgenes) {
    my $mergekey = mergeranges($repeatareas{$genevar});
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
