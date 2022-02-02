
> # Evitar
>
> Evitar (Emerging-Virus-Targeting RNA) is a program for (1) pre-designing siRNAs/Cas13a guide RNAs against future viruses based on existing viral sequences, and (2) designing siRNAs/Cas13a guide RNAs against a single virus based on sequences of multiple strains of this virus.
>
> Perl5 and Linux are required. Some functions also required R (version 3.4 or later). The software should be run using the Linux command line environment.
>
> ## Installation
>
> The software can be downloaded from Github using the following commands:
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
> ***The <font color = red>bin/</font> folder is required for successful execution of the program. Please do not change it unless you want to modify the software.***
>
> To design siRNAs targeting **future** viruses: 
>
> ```
> perl Evitar.pl --mode predesign --input test/exist_viruses.fa --output test/future_siRNAs.txt
> ```
>
> To design siRNAs targeting an **existing** virus: 
>
> ```
> perl Evitar.pl --input test/genome.fa --strains test/strains.fa --output test/siRNAs.txt
> ```
>
> ## Usage, Options and Switches
>
> ```
> Usage: perl Evitar.pl --input infile --output outfile [OPTION...]
> 
> infile:
>   The name of input file. For the mode of designing against future viruses, the input file is a fasta file containing sequences of existing viruses. For the mode of designing against an existing virus, the input file is a fasta file that contains a single sequence (such as the reference genome of the virus).
> outfile:
>  The name of output file. Output will be in text file format. The output fields are described in the first line of the file. 
> 
> Options (need to include values after the option switches):
> --predict:
>   A text string defining whether to design siRNAs or Cas13a gRNAs, and for siRNAs, which designing algorithm to be used. Allowed values are “predsi” for using the GPP-Portal-like siRNA-designing algorithm, or “rnaxs” for using the RNAxs siRNA-designing algorithm, or “CRISPR” for designing Cas13a gRNA. 
> --ncores:
>   The number of threads used in the multithread mode. Default is 1.
> --strains:
>   A fasta file containing sequences of viral strains for a virus of interest(used for the mode of designing against an existing virus)  
> --p3utr:
>   A fasta file containing the 3'UTR regions of the transcriptome
> --tranome:
>   A fasta file containing the sequences of the transcriptome
> --weight:
>   A text file used to evaluate the off-target effect of siRNAs. The file contains three columns with a single header line. First column is for ENSEMBL Gene ID. Second column contains Gene Symbol. Third column contains a numerical value for the weight of the corresponding gene. Each row contains information for one gene.
> --pmcuff:
>   An integer value defining the maximum cutoff when evaluating off-target effects of siRNAs on perfect match with the transcriptome. Any siRNAs with the number of perfect matches larger or equal to this cutoff will be removed from consideration. Default is 1.
> --umcuff:
>   A numerical value defining the maximum cutoff when evaluating off-target effects of siRNAs on imperfect match with the transcriptome. Imperfect match are those with extensive matches but not complete match between siRNA and a transcript. An off-target score is calculated based on this cutoff. Default: 20.
> --mircuff:
>   A numerical value defining the maximum cutoff when evaluating off-target effects of siRNAs on miRNA-like off-target effects. miRNA-like off-target effects are evaluated based on the match between the seed sequence of the siRNA and a transcript. An off-target score is calculated based on this cutoff. Default: 20000.
> --sumtype:
>   A text string input of either “SGAR” or “greedy”. SGAR means running the SGAR algorithm when selecting siRNAs into a collection. Greedy means running the GAR algorithm when selecting siRNAs into a collection. The default is SGAR. This option is only used when running in the mode of predesigning against future viruses.
> --limitnum:
>   An integer value defining the number of siRNAs/Cas13a gRNAs to be output into a collection. Default is 30. This option is only used when running in the mode of predesigning against future viruses.
> --repeatnum:
>   An integer value defining the Multi-siRNA parameter, which is used to increase the robustness of identifying more than one siRNA/Cas13 gRNA in a collection against a future virus. Default is 3. This option is only used when running in the mode of predesigning against future viruses. Note that to run Evitar with the conventional greedy algorithm, set –-repeatnum to 1 and –-sumtype to greedy.
> --allow:
>   A text file containing a single column without header lines. Each line contains the sequence of an siRNA that user can explicitly define as allowed in the output. 
> --ban:
>   A text file containing a single column without header lines. Each line contains the sequence of an siRNA that user can force the program to eliminate during the evaluation and from the output.
> --temp: 
>   The path for a temporary fold containing temporary files during the run of the program. This folder will be deleted upon completion of the run. This option is particularly useful if multiple incidences of the program are run at the same time. A default path is used if this option is omitted. 
> --maxgc:
>   A numerical value defining the maximal cutoff of GC content when predicting effective siRNAs. Default: 0.6.
> --mingc:
>   A numerical value defining the minimal cutoff of GC content when predicting effective siRNAs. Default: 0.25.
> --middlegc:
>   A numerical value defining the cutoff between optimal GC content and suboptimal GC content when predicting effective siRNAs. If the GC content is between this value and maximal content, the GC content is thought as suboptimal GC content, and the evaluation score will be decreased. Default: 0.55.
> 
> Switches (no values needed after the switch)
> --offtarget:
>   This switch informs the program to run off-target evaluation.
> ```
>
> ## Advanced usage:
>
> In the pre-designing mode of Evitar, some Evitar-designed siRNAs could be undesirable based on users' criteria (such as poor experimental knockdown efficiency). Therefore, we enabled a function for users to define whether they want to remove and redesign certain siRNAs and whether they want to force certain siRNAs in the designed list. The Options of –-allow and –-ban are detailed above.
>
> ```
> Usage: 
>  perl Evitar.pl --mode predesign --input test/exist_viruses.fa  --output test/future_siRNAs2.txt --allow test/allow.txt --ban test/ban.txt
> 
> #### Compare test/future_siRNAs2.txt with test/future_siRNAs0.txt
> 
> ```
>
> 
>
> Additional Notes on Off-target Analysis:
>
> ​    The Evitar program uses GTEx transcriptomes of normal human tissues when evaluating off-target effects of siRNAs. If users wish to use their own custom transcriptomic data to evaluate off-target effects, we provide an example bash file below that can serve as a template for users to modify. 
>
> ​    The bash program GenomeData.sh is used to calculate tissue-specific gene expression weights that are used by the Evitar program. To use the GenomeData.sh, please follow the following example of commands. Output of the GenomeData.sh will be stored in the folder ***GenomeData/ ***.  The folder ***GenomeData/weightedgene/*** contains text files used to evaluate the human tissue-specific off-target effect of siRNAs.
>
> ```
> cd GenomeData/
> bash GenomeData.sh
> cd ../
> ```
>
> An example of running Evitar for designing siRNAs targeting **future** viruses, with Off-target analysis on the human lung tissue, is provided below:
>
> ```
> perl Evitar.pl --mode predesign --input test/exist_viruses.fa  --output test/future_siRNAs.txt --offtarget --p3utr GenomeData/utrs.fa --transcriptome GenomeData/transcripts.fa --weight GenomeData/weightedgene/Lung.txt
> ```
>
> An example of running Evitar for designing siRNAs targeting an **existing** virus, with Off-target analysis on the human lung tissue, is provided below: 
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
> The algorithms for Cas13 designing comes from:
>
>
> > Wessels, H.-H., Méndez-Mancilla, A., Guo, X., Legut, M., Daniloski, Z., and Sanjana, N.E. (2020). Massively parallel Cas13 screens reveal principles for guide RNA design. Nature Biotechnology 2020 38:6 *38*, 722–727.
