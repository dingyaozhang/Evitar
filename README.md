# Evitar
Evitar incorporates considerations on siRNA properties, target RNA structure, off-target effects and genetic variations in viral genomes and designs multiple siRNAs to target viral genome; Evitar also supports a second mode for pre-designing siRNAs against emerging viruses based on existing viral sequences.

## Quick Start
Basic function to design antiviral siRNAs (Transcript_3primer_utr_sequence.fa and transcriptome_sequence.fa could be gotten by running GenomeData/GenomeData.sh.)
```
perl bin/Evitar.pl --input virus_reference_genome.fa --output designed_siRNAs.txt --strains virus_strains_genomes.fa --offtarget --p3utr transcript_3primer_utr_sequence.fa --transcriptome transcriptome_sequence.fa --weight weighted_of_gene.txt
```
Step to evaluate genetic variations is time-consuming. So design of antiviral siRNAs could be divided into two steps.
```
perl bin/Evitar.pl --mode mapfastas --input virus_reference_genome.fa --strains virus_strains_genomes.fa --output strains_ref/ --ncores 6
perl bin/Evitar.pl --input virus_reference_genome.fa --output designed_siRNAs.txt --strains strains_ref/ --offtarget --p3utr transcript_3primer_utr_sequence.fa --transcriptome transcriptome_sequence.fa --weight weighted_of_gene.txt
```
Function to design siRNAs targeting potentially emerging viruses in the future
```
perl bin/Evitar.pl --mode predesign --input strains_genomes_of_a_viral_class.fa  --output predesigned_siRNAs.txt
perl bin/Evitar.pl --mode predesign --input strains_genomes_of_a_viral_class.fa  --output predesigned_siRNAs.txt --offtarget --p3utr transcript_3primer_utr_sequence.fa --transcriptome transcriptome_sequence.fa --weight weighted_of_gene.txt --sumtype SGAR
```
Function to design siRNAs considering experiment results
```
perl bin/Evitar.pl --mode predesign --input strains_genomes_of_a_viral_class.fa  --output predesigned_siRNAs.txt
perl bin/Evitar.pl --mode predesign --input strains_genomes_of_a_viral_class.fa  --output predesigned_siRNAs.txt --offtarget --p3utr transcript_3primer_utr_sequence.fa --transcriptome transcriptome_sequence.fa --weight weighted_of_gene.txt --sumtype SGAR --allow experiment_verified_siRNAs.txt --ban experiment_excluded_siRNAs.txt
```
## Option Explanation
```
--input
(Required) the input file for the program
--output
(Required) the output file for the program
--temp
the path for temporary fold for the calculation, it will be set to avoid the conflict when you want to run several Evitar together.
--ncores
the threads used in the multithread mode
--RNAplfold
the path for customized RNAplfold program, normally there is no needs for set.
--strains
viurs strains file for consideration on 
--offtarget
Include  the evaluation on siRNA offtarget effect
--p3utr
the fasta file of 3'UTR regions of transcriptome
--tranome
the fasta file of transcriptome
--weight
the list including gene weighting information for evaluation of offtarget effect
--parameterRNAxs
the parameter list for RNAxs predict method
--pmcuff
the cutoff standard for evaluating offtarget effects as siRNA perfect match.
--umcuff
the cutoff standard for evaluating offtarget effects as siRNA unperfect match.
--mircuff
the cutoff standard for evaluating offtarget effects as miRNA match.
--sumtype
Select the proper method to pre-design siRNAs (SGAR/greedy(GAR))
--limitnum
the limitation of lines of output file in pre-design mode
--repeatnum
the penalty factor for pre-design mode
--offtargetperfect
Include a perfect instead of faster evaluation on siRNA offtarget effect in mode Predesign without greedy algorithm
--allow 
List of siRNAs which are verified by the experiments
--ban
List of siRNAs which are excluded by the experiments
```
## Dependencies
Perl5 is needed. All the other packages which are needed are put in the bin/. No other packages are required for the program. The ViennaRNA Package is needed for all functions.

> Lorenz, Ronny and Bernhart, Stephan H. and Höner zu Siederdissen, Christian and Tafer, Hakim and Flamm, Christoph and Stadler, Peter F. and Hofacker, Ivo L.
ViennaRNA Package 2.0
Algorithms for Molecular Biology, 6:1 26, 2011, doi:10.1186/1748-7188-6-26

Basic function to design antiviral siRNAs targeting a known viral genome needs MUSCLE when considering genetic variations:


> Edgar, Robert C. (2004), MUSCLE: multiple sequence alignment with high accuracy and high throughput, Nucleic Acids Research 32(5), 1792-97.
