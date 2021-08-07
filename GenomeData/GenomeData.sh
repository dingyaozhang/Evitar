wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/GRCh38.p13.genome.fa.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_34/gencode.v34.annotation.gtf.gz
gunzip GRCh38.p13.genome.fa.gz
gunzip gencode.v34.annotation.gtf.gz
chmod 777 bin/bedtools.static.binary


perl bin/getutrs.pl -i gencode.v34.annotation.gtf -o utrs.bed
perl bin/gettranscript.pl -i gencode.v34.annotation.gtf -o transcripts.bed
bin/bedtools.static.binary getfasta -fi GRCh38.p13.genome.fa -fo transcripts0.fa -bed transcripts.bed -name
bin/bedtools.static.binary getfasta -fi GRCh38.p13.genome.fa -fo utrs0.fa -bed utrs.bed -name
perl bin/namefastabyensg.pl -i transcripts0.fa -o transcripts.fa
perl bin/namefastabyensg.pl -i utrs0.fa -o utrs.fa
rm transcripts0.fa
rm utrs0.fa


#


wget https://storage.googleapis.com/gtex_analysis_v8/rna_seq_data/GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct.gz
gunzip GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct.gz
cat GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct | sed -n '3,$p' > GTEx_tpm.gct
rm GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct
Rscript bin/weightexp.R GTEx_tpm.gct #lung.txt weightedgene.txt #lung.txt should be edited as lung-tissue in GTEx. lung_example.txt could guide the building of lung.txt.