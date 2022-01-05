
> # Evitar
>
> Evitar pre-designs siRNAs against future viruses based on existing viral sequences. It also supports a mode for designing multiple siRNAs to target input viral genomes. 
>
> Perl5 and Linux are required. Some functions also required R (>= 3.4). The software should run in Linux command line.
>
> ## Installation
>
> The software can be downloaded from Github using:
>
> ```
> git clone https://github.com/dingyaozhang/Evitar.git
> cd Evitar
> ```
>
> ## Quick Start
>
> After installation and enter into Evitar folder, Evitar could be directly used. The data in ***test/*** folder could be used to test whether the installation is successful. 
>
> ***The <font color = red>bin/</font> folder is required for successful execution of the program, don't change it unless you want to modify the software.***
>
> To design siRNAs targeting **future** viruses: 
>
> ```
> perl Evitar.pl --mode predesign --input test/exist_viruses.fa  --output test/future_siRNAs.txt
> ```
>
> To design siRNAs targeting **input** viruses: 
>
> ```
> perl Evitar.pl --input test/genome.fa --strains test/strains.fa --output test/siRNAs.txt
> ```
>
> ## Usage
>
> ```
> Usage: perl Evitar.pl --input infile --output outfile [OPTION...]
>   
>   infile:
>     the input file
>   outfile:
>     the output file
>   ncores:
>     the threads used in the multithread mode
>   strains:
>     viurs strains file for consideration on 
>   offtarget:
>     Include  the evaluation on siRNA offtarget    effect
>   p3utr:
>     the fasta file of 3'UTR regions of transcriptome
>   tranome:
>     the fasta file of transcriptome
>   weight:
>     the list including gene weighting information for evaluation of offtarget effect
>   pmcuff:
>     the cutoff standard for evaluating offtarget effects as siRNA perfect match.
>   umcuff:
>     the cutoff standard for evaluating offtarget effects as siRNA unperfect match.
>   mircuff:
>     the cutoff standard for evaluating offtarget effects as miRNA match.
>   sumtype:
>     Select the proper method to pre-design siRNAs (SGAR/greedy(GAR))
>   limitnum:
>     the limitation of lines of output file in pre-design mode
>   repeatnum:
>     the penalty factor for pre-design mode
>   allow:
>     List of siRNAs which are verified by the experiments
>   ban:
>     List of siRNAs which are excluded by the experiments
>   temp: 
>     the path for temporary fold for the calculation
> ```
>
> ## Advanced usage:
>
> For pre-designing model, some Evitar-designed siRNAs could be removed based on users' own standard (like experimental results). Therefore, we have a function to either remove user-removed siRNAs or keep  user-preferred siRNAs to get a new Evitar-designed siRNA set. 
>
> ```
> perl Evitar.pl --mode predesign --input test/exist_viruses.fa  --output test/future_siRNAs2.txt --allow test/allow.txt --ban test/ban.txt
> #### Compare test/future_siRNAs2.txt with test/future_siRNAs0.txt
> ```
>
> Users may evaluate siRNA off-target effects of Evitar output based on their own criterions. While Evitar also has functions about off-target effects.
>
> Firstly, we need download human genome data for off-target analysis. The folder ***GenomeData/weightedgene/*** contains human tissue-specific gene expression weight files. (Those files are calculated by weightedgene.sh, users could modify weightedgene.sh and get custom files.)
>
> ```
> cd GenomeData/
> bash GenomeData.sh
> cd ../
> ```
>
> To design siRNAs targeting **future** viruses:
>
> ```
> perl Evitar.pl --mode predesign --input test/exist_viruses.fa  --output test/future_siRNAs.txt --offtarget --p3utr GenomeData/utrs.fa --transcriptome GenomeData/transcripts.fa --weight GenomeData/weightedgene/Lung.txt
> ```
>
> To design siRNAs targeting **input** viruses: 
>
> ```
> perl Evitar.pl --input test/genome.fa --strains test/strains.fa --output test/siRNAs.txt --offtarget --p3utr GenomeData/utrs.fa --transcriptome GenomeData/transcripts.fa --weight GenomeData/weightedgene/Lung.txt
> ```
>
> ## Reference
>
> The ViennaRNA package is used in this software.
>
> > Lorenz, Ronny and Bernhart, Stephan H. and Höner zu Siederdissen, Christian and Tafer, Hakim and Flamm, Christoph and Stadler, Peter F. and Hofacker, Ivo L.
> > ViennaRNA Package 2.0
> > Algorithms for Molecular Biology, 6:1 26, 2011, doi:10.1186/1748-7188-6-26
>
> Designing antiviral siRNAs targeting input genomes needs MUSCLE:
>
>
> > Edgar, Robert C. (2004), MUSCLE: multiple sequence alignment with high accuracy and high throughput, Nucleic Acids Research 32(5), 1792-97.
>
> The RNAxs algorithm in the software is an alternative for siRNA designing, it comes from:
>
>
> > Tafer, H., Ameres, S.L., Obernosterer, G., Gebeshuber, C.A., Schroeder, R., Martinez, J., and Hofacker, I.L. (2008). The impact of target site accessibility on the design of effective siRNAs. Nature Biotechnology *26*, 578–583.
>
> The algorithms for Cas13 designing comes from :
>
>
> > Wessels, H.-H., Méndez-Mancilla, A., Guo, X., Legut, M., Daniloski, Z., and Sanjana, N.E. (2020). Massively parallel Cas13 screens reveal principles for guide RNA design. Nature Biotechnology 2020 38:6 *38*, 722–727.
