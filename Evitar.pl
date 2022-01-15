#!/usr/bin/perl -w 
use strict;
use warnings;


use Getopt::Long;
use File::Copy;
#my ($verbose, $seq);

my $length = 24;
my $mode = 'predsi';
my $tempfile = '.temptempsi';
my $predict = 'predsi';
my $verifytype = 'perfect';
my $limitnumber = 50;
my $repeatnum = 2;
my ($offtarget, $offtargetperfect, $tranome, $input, $p3utr, $strains, $ncores, $maxgc, $mingc, $middlegc,
 $mutationrate, $offtargetwholematch, $offtargetpartmatch, $offtargetmirna,
 $RNAplfold, $output, $parameterRNAxs, $weight, $pmcuff, $umcuff, $mircuff, $range, $sumtype, $allowlist, $banlist);

GetOptions ("mode=s" => \$mode,    
              "predict=s"   => \$predict,     
              "strains=s"  => \$strains,
              "offtarget"  => \$offtarget,
              "offtargetperfect"  => \$offtargetperfect,
              "sumtype=s"  => \$sumtype,
              "p3utr=s"  => \$p3utr,
              "RNAplfold=s"  => \$RNAplfold,
              "transcriptome=s"  => \$tranome,
              "temp=s"  => \$tempfile,
              "input=s"  => \$input, 
              "output=s"  => \$output,
              "weight=s"  => \$weight,
              "allow=s"  => \$allowlist,
              "ban=s"  => \$banlist,
              "pmcuff=f"  => \$pmcuff,
              "umcuff=f"  => \$umcuff,
              "mircuff=f"  => \$mircuff,
              "verifytype=s" => \$verifytype,
              "range=i" => \$range,
              "limitnum=i" => \$limitnumber,
              "repeatnum=f" => \$repeatnum,
              "mutationrate=s" => \$mutationrate,
              "offtargetwholematch=s" => \$offtargetwholematch,
              "offtargetpartmatch=s" => \$offtargetpartmatch,
              "offtargetmirna=s" => \$offtargetmirna,
              "maxgc=f" => \$maxgc,
              "mingc=f" => \$mingc,
              "middlegc=f" => \$middlegc,
			  "ncores=i" => \$ncores)
or die("Error in command line arguments\n");

$tempfile =~ s/\/$//;

my $scriptsfolder = $0;
if ($scriptsfolder =~ s/Evitar\.pl$//) {
	$scriptsfolder = $scriptsfolder.'bin/';
}else{
	die "wrong program name\n";
}

unless ($input) {
	die "no input files\n";
}
unless ($output) {
	die "no output files\n";
}

if ($mode eq 'predsi') {
	if ($predict eq 'predsi') {
		my $addcommand = '';
		if ($RNAplfold) {
			$addcommand .= " -p $RNAplfold ";
		}
		if ($tempfile) {
			$addcommand .= " -t $tempfile ";
		}
		if ($maxgc) {
			$addcommand .= " -G $maxgc ";
		}
		if ($mingc) {
			$addcommand .= " -C $mingc ";
		}
		if ($middlegc) {
			$addcommand .= " -g $middlegc ";
		}
		run("perl ${scriptsfolder}predictsiRNA -i $input -o $output $addcommand");	
	}elsif ($predict eq 'rnaxs') {
		my $addcommand = '';
		if ($RNAplfold) {
			$addcommand .= " -p $RNAplfold ";
		}
		if ($tempfile) {
			$addcommand .= " -z $tempfile ";
		}
		if ($parameterRNAxs) {
			$addcommand .= " $parameterRNAxs ";
		}
		run("perl ${scriptsfolder}portableRNAxs -s $input -o $output $addcommand");
	}else{
		usage();
	}
	
	if ($strains) {
		if (-f $strains) {
			if ($ncores) {
				run("perl ${scriptsfolder}dividefa -i $strains -r $input -o $tempfile -t $tempfile -n $ncores");
			}else{
				run("perl ${scriptsfolder}dividefa -i $strains -r $input -o $tempfile -t $tempfile");
			}			
			run("perl ${scriptsfolder}mutforsiRNA -a $tempfile -r $input -o $tempfile/anno.temp");
			if ($mutationrate) {
				run("perl ${scriptsfolder}select_siRNA -i $output -r $tempfile/anno.temp -o $tempfile/outtemp.out -m $mutationrate");
			}else{
				run("perl ${scriptsfolder}select_siRNA -i $output -r $tempfile/anno.temp -o $tempfile/outtemp.out");
			}
			my @tempin;
			open TEMPIN, "$tempfile/outfiles.txt" or die;
			while (<TEMPIN>) {
				chomp;
				push @tempin, "$tempfile/$_";
			}
			close TEMPIN;
			unlink @tempin or print "Error:Could not unlink files!: $!\n";
			move("$tempfile/outtemp.out", $output);
			unlink "$tempfile/anno.temp";
			unlink "$tempfile/outfiles.txt";
			rmdir "$tempfile";
		}elsif (-d $strains) {
			unless (-e $tempfile) {
				run("mkdir $tempfile");
			}
			run("perl ${scriptsfolder}mutforsiRNA -a $strains -r $input -o $tempfile/anno.temp");
			if ($mutationrate) {
				run("perl ${scriptsfolder}select_siRNA -i $output -r $tempfile/anno.temp -o $tempfile/outtemp.out -m $mutationrate");
			}else{
				run("perl ${scriptsfolder}select_siRNA -i $output -r $tempfile/anno.temp -o $tempfile/outtemp.out");
			}
			move("$tempfile/outtemp.out", $output);
			unlink "$tempfile/anno.temp";
			rmdir "$tempfile";
		}else{
			die "Error: the name after the option --strains is no a file or folder\n";
		}
		
	}
	if ($offtarget) {
		mkdir "$tempfile" unless -e $tempfile;
		my $addcommand = '';
		if ($weight) {
			$addcommand .= " -w $weight ";
		}
		if ($ncores) {
			run("perl ${scriptsfolder}offtargetncore -i $output -o $tempfile/offmirtemp.txt -r $p3utr -n $ncores -m $addcommand");
			run("perl ${scriptsfolder}offtargetncore -i $output -o $tempfile/offtranstemp.txt -r $tranome -n $ncores $addcommand");
		}else{
			run("perl ${scriptsfolder}offtarget -i $output -o $tempfile/offmirtemp.txt -r $p3utr -m $addcommand");
			run("perl ${scriptsfolder}offtarget -i $output -o $tempfile/offtranstemp.txt -r $tranome $addcommand");
		}
		$addcommand = '';
		if ($pmcuff) {
			$addcommand .= " -p $pmcuff ";
		}
		if ($umcuff) {
			$addcommand .= " -u $umcuff ";
		}
		if ($mircuff) {
			$addcommand .= " -w $mircuff ";
		}
		run("perl ${scriptsfolder}evaluebyofftarget -i $output -m $tempfile/offmirtemp.txt -t $tempfile/offtranstemp.txt -o $tempfile/outtemp.out $addcommand");
		move("$tempfile/outtemp.out",$output);
		unlink "$tempfile/offmirtemp.txt";
		unlink "$tempfile/offtranstemp.txt";
		rmdir "$tempfile";
	}
	mkdir "$tempfile" unless -e $tempfile;
	run("perl ${scriptsfolder}integrateresult -i $output -o $tempfile/inteoutput.txt");
	move("$tempfile/inteoutput.txt",$output);
	unlink "$tempfile/inteoutput.txt";
	rmdir "$tempfile";

}elsif ($mode eq 'predesign') {
	if ($ncores) {
		require threads;
		require threads::shared;
		require POSIX;
		POSIX->import(qw(floor));
	}
	my $ncoresrun = sub {
		my @commands = @{$_[0]};
		my @finalouts;
		if ($ncores) {
			my $targetsnum = scalar @commands;
			my $oneblocknum = floor($targetsnum / $ncores) + 1;
			my @chunks;
			push @chunks, [splice(@commands, 0, $oneblocknum)] while @commands;
			
			my @threads;
			foreach (@chunks) {
			   push @threads, threads->new($_[1], $_);
			}
			foreach (@threads) {
			   my $out1 = $_->join();
			   push @finalouts, $out1;
			}
		}else{
			my $out1 = &{$_[1]}(\@commands);
			push @finalouts, $out1;
		}
		return \@finalouts;
	};
	my $runs = sub {
		my @array = @{$_[0]};
		for my $var (@array) {
			my $warn = `$var`;
			print "$warn";
		}
		return 1;
	};


	my $addcommand = '';
	if ($predict eq 'predsi') {
		if ($RNAplfold) {
			$addcommand .= " -p $RNAplfold ";
		}
		if ($maxgc) {
			$addcommand .= " -G $maxgc ";
		}
		if ($mingc) {
			$addcommand .= " -C $mingc ";
		}
		if ($middlegc) {
			$addcommand .= " -g $middlegc ";
		}
		$addcommand = "perl ${scriptsfolder}predictsiRNA $addcommand";	
	}elsif ($predict eq 'rnaxs') {
		if ($RNAplfold) {
			$addcommand .= " -p $RNAplfold ";
		}
		if ($parameterRNAxs) {
			$addcommand .= " $parameterRNAxs ";
		}
		$addcommand = "perl ${scriptsfolder}portableRNAxs $addcommand";
	}elsif($predict eq 'CRISPR'){
		$addcommand = "Rscript ${scriptsfolder}Cas13/scripts/cas13.R ";	
	}elsif($predict eq 'multifapredsi'){
		if ($RNAplfold) {
			$addcommand .= " -p $RNAplfold ";
		}
		$addcommand = "perl ${scriptsfolder}multifapredictsiRNA $addcommand";	
	}else{
		usage();
	}

	mkdir "$tempfile" unless -e $tempfile;
	local $/ = ">";
	open FAS, "$input" or die;
	my $line1 = <FAS>;
	my @outrelatives;
	while (<FAS>) {
		chomp;
		my @faarray = split(/\n/, $_);
		my $name = shift(@faarray);
		my $sequence = join("", @faarray);
		my $outrelative = "$tempfile/$.\.fa";
		push @outrelatives, "$outrelative";
		open OUTFA, '>', "$outrelative" or die;
		print OUTFA ">$name\n$sequence\n";
		close OUTFA;
	}
	close FAS;
	local $/ = "\n";

	my @outrelativescommands;
	my $filei = 2;
	if ($predict eq 'predsi') {
		foreach my $file (@outrelatives) {
			push @outrelativescommands, "$addcommand -i $file -o ${file}.out -t $tempfile/.temptempsi$filei";
			$filei += 1;
		}
	}elsif ($predict eq 'multifapredsi') {
		foreach my $file (@outrelatives) {
			push @outrelativescommands, "$addcommand -i $file -o ${file}.out -t $tempfile/.temptempsi$filei";
			$filei += 1;
		}
	}elsif ($predict eq 'CRISPR') {
		foreach my $file (@outrelatives) {
			push @outrelativescommands, "$addcommand $file ${file}.out";
			$filei += 1;
		}
	}elsif ($predict eq 'rnaxs') {
	foreach my $file (@outrelatives) {
		push @outrelativescommands, "$addcommand -s $file -o ${file}.out -z $tempfile/.temptempsi$filei";
		$filei += 1;
	}
	}
	&$ncoresrun(\@outrelativescommands, $runs);

	open OUTPUT, '>', "$output" or die;
	my $totaline1;
	my $totali = 0;
	my %seqhash;
	foreach my $file (@outrelatives) {
		open TEMP, "${file}.out" or die;
		my $thisi = $file;
		die "unknown wrong" unless $thisi =~ s/^$tempfile\///;
		die "unknown wrong" unless $thisi =~ s/\.fa$//;
		my $line1 = <TEMP>;
		print OUTPUT "$line1" if $totali == 0;
		$totali += 1;
		while (my $templine = <TEMP>) {
			chomp($templine);
			my @temparray = split(/\t/, $templine);
			my $pos = shift(@temparray);
			$pos = "$pos|$thisi";
			my $seqtar = $temparray[0];
			if (exists($seqhash{$seqtar})) {
				$seqhash{$seqtar} = "$seqhash{$seqtar}|$thisi";
				next;
			}else{
				$seqhash{$seqtar} = $thisi;
			}
			my $out1line = join("\t", @temparray);
			print OUTPUT "$pos\t$out1line\n";
		}
		close TEMP;
	}
	close OUTPUT;
	$totali += 1;
	
	
	for my $seqhashvar (keys(%seqhash)) {
		my @seqhasharr = split(/\|/, $seqhash{$seqhashvar});
		my %temphash;
		for my $vartemptemp (@seqhasharr) {
			$temphash{$vartemptemp} = 1;
		}
		@seqhasharr = sort {$a <=> $b} keys %temphash;
		$seqhash{$seqhashvar} = join("|", @seqhasharr);
	}
	

	foreach my $file (@outrelatives) {
		unlink $file or print "Could not unlink $file: $!";
	}
	foreach my $file (@outrelatives) {
		unlink "${file}.out" or print "Could not unlink $file: $!";
	}


	
	{
		open INPUT, "$output" or die;
		open OUTPUT, '>', "$tempfile/count.unsort" or die;
		my $line1 = <INPUT>;
		chomp($line1);
		my @line1 = split(/\t/, $line1);
		my $line11 = shift(@line1);
		my $line12 = shift(@line1);
		my $line13 = shift(@line1);
		my $line1new = join("\t", @line1);
		print OUTPUT "$line11\t$line12\t$line13\tCover_Score\tCover_Samples\t$line1new\n";
		while (<INPUT>) {
			chomp;
			my @array = split(/\t/, $_);
			my $out1 = shift(@array);
			my $out2 = shift(@array);
			my $out3 = shift(@array);
			my $rest = join("\t", @array);
			my $tempforcount = $seqhash{$out2};
			my $count = ($tempforcount =~ tr/|/|/); 
			print OUTPUT "$out1\t$out2\t$out3\t$count\t$tempforcount\t$rest\n";
		}
		close OUTPUT;
		close INPUT;
	}
	unless ($sumtype) {
		print "There is no choice of algorithm for summarization.\nThe SGAR algorithm is selected.\n";
		$sumtype = 'SGAR';
	}
	if ($sumtype && $sumtype eq 'SGAR') {
		my $addcommand = '';
		if ($offtarget||$offtargetperfect) {
			$addcommand .= "-r $tranome -m $p3utr ";
			if ($weight) {
				$addcommand .= "-w $weight ";
			}
			if ($pmcuff) {
				$addcommand .= "-P $pmcuff ";
			}
			if ($umcuff) {
				$addcommand .= "-A $umcuff ";
			}
			if ($mircuff) {
				$addcommand .= "-M $mircuff ";
			}
		}else{
			$addcommand .= "-F ";
		}

		if ($ncores) {
			$addcommand .= " -n $ncores ";
		}
		if ($banlist) {
			if ($allowlist) {
				run("perl ${scriptsfolder}SGARallowban -i $tempfile/count.unsort -o $tempfile/count.sort -c $repeatnum -l $limitnumber $addcommand -a $allowlist -b $banlist");
			}else{
				run("perl ${scriptsfolder}SGARallowban -i $tempfile/count.unsort -o $tempfile/count.sort -c $repeatnum -l $limitnumber $addcommand -b $banlist");
			}
		}else{
			run("perl ${scriptsfolder}SGAR -i $tempfile/count.unsort -o $tempfile/count.sort -c $repeatnum -l $limitnumber $addcommand");
		}
		
		unlink "$tempfile/count.unsort";
		move("$tempfile/count.sort",$output);
		rmdir "$tempfile";
	}elsif($sumtype && $sumtype eq 'greedy') {
		my $addcommand = '';
		if ($offtarget||$offtargetperfect) {
			$addcommand .= "-r $tranome -m $p3utr ";
			if ($weight) {
				$addcommand .= "-w $weight ";
			}
			if ($pmcuff) {
				$addcommand .= "-P $pmcuff ";
			}
			if ($umcuff) {
				$addcommand .= "-A $umcuff ";
			}
			if ($mircuff) {
				$addcommand .= "-M $mircuff ";
			}
		}else{
			$addcommand .= "-F ";
		}
		run("perl ${scriptsfolder}greedy -i $tempfile/count.unsort -o $tempfile/count.sort -c $repeatnum -l $limitnumber $addcommand");
		unlink "$tempfile/count.unsort";
		move("$tempfile/count.sort",$output);
		rmdir "$tempfile";
	}elsif($sumtype && $sumtype eq "depreciatedgreedy") {
		my $addcommand = '';
		if ($offtarget||$offtargetperfect) {
			$addcommand .= "-r $tranome -m $p3utr ";
			if ($weight) {
				$addcommand .= "-w $weight ";
			}
			if ($pmcuff) {
				$addcommand .= "-P $pmcuff ";
			}
			if ($umcuff) {
				$addcommand .= "-A $umcuff ";
			}
			if ($mircuff) {
				$addcommand .= "-M $mircuff ";
			}
		}else{
			$addcommand .= "-F ";
		}
		if ($ncores) {
			$addcommand .= " -n $ncores ";
		}
		run("perl ${scriptsfolder}weightedgreedyncore -i $tempfile/count.unsort -o $tempfile/count.sort -c $repeatnum -l $limitnumber $addcommand");
		unlink "$tempfile/count.unsort";
		move("$tempfile/count.sort",$output);
		rmdir "$tempfile";
	}


}elsif ($mode eq 'mapfastas') {
	if ($ncores) {
		run("perl ${scriptsfolder}dividefa -i $strains -r $input -o $output -t $output -n $ncores");
	}else{
		run("perl ${scriptsfolder}dividefa -i $strains -r $input -o $output -t $output");
	}
}else{
	usage()
}

sub usage{
die
' Usage: perl Evitar.pl --input infile --output outfile [OPTION...]
  
  infile:
    the input file
  outfile:
    the output file
  ncores:
    the threads used in the multithread mode
  strains:
    viurs strains file for consideration on 
  offtarget:
    Include  the evaluation on siRNA offtarget    effect
  p3utr:
    the fasta file of 3\'UTR regions of transcriptome
  tranome:
    the fasta file of transcriptome
  weight:
    the list including gene weighting information for evaluation of offtarget effect
  pmcuff:
    the cutoff standard for evaluating offtarget effects as siRNA perfect match.
  umcuff:
    the cutoff standard for evaluating offtarget effects as siRNA unperfect match.
  mircuff:
    the cutoff standard for evaluating offtarget effects as miRNA match.
  sumtype:
    Select the proper method to pre-design siRNAs (SGAR/greedy(GAR))
  limitnum:
    the limitation of lines of output file in pre-design mode
  repeatnum:
    the penalty factor for pre-design mode
  allow:
    List of siRNAs which are verified by the experiments
  ban:
    List of siRNAs which are excluded by the experiments
  temp: 
    the path for temporary fold for the calculation
';
}
	
sub run {
	my $runout = `$_[0]`;
	print "$runout";
	return 1;
}
