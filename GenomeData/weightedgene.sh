wget https://storage.googleapis.com/gtex_analysis_v8/annotations/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt
wget https://storage.googleapis.com/gtex_analysis_v8/rna_seq_data/GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct.gz
gunzip GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct.gz
cat GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct | sed -n '3,$p' > GTEx_tpm.gct
rm GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct
perl gtexsimple.pl
Rscript weightedgeneall.R GTEx_tpm.gct sample2tissue.txt weightedgene
mv weightedgene/*logtpm.txt weightedgene/logtpm/
