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

