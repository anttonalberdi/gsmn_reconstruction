# campylo_gsmn
Genome-scale metabolic networks of Campylobacter and related bacteria

### Download annotated genomes
Annotated genomes (gbff format) can be downloaded from the NCBI, and each genome must be stored inside a folder inside the genomes folder.

```
mkdir /Users/anttonalberdi/github/campylo_gsmn/genomes
cd /Users/anttonalberdi/github/campylo_gsmn/genomes

mkdir Bacteroides_fragilis_A
cd Bacteroides_fragilis_A
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/724/805/GCF_000724805.2_ASM72480v2/GCF_000724805.2_ASM72480v2_genomic.gbff.gz
gunzip GCF_000724805.2_ASM72480v2_genomic.gbff.gz
mv GCF_000724805.2_ASM72480v2_genomic.gbff Bacteroides_fragilis_A.gbff
cd ..

mkdir Campylobacter_jejuni
cd Campylobacter_jejuni
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/457/695/GCF_001457695.1_NCTC11351/GCF_001457695.1_NCTC11351_genomic.gbff.gz
gunzip GCF_001457695.1_NCTC11351_genomic.gbff.gz
mv GCF_001457695.1_NCTC11351_genomic.gbff Campylobacter_jejuni.gbff
cd ..

mkdir Campylobacter_coli
cd Campylobacter_coli
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/730/395/GCF_009730395.1_ASM973039v1/GCF_009730395.1_ASM973039v1_genomic.gbff.gz
gunzip GCF_009730395.1_ASM973039v1_genomic.gbff.gz
mv GCF_009730395.1_ASM973039v1_genomic.gbff Campylobacter_coli.gbff
cd ..

cd ..
```

### Download eggnog-annotated genomes and convert to gbk
```
conda activate m2m
cd /Users/anttonalberdi/github/campylo_gsmn/

#Fix formatting issue of the GFF file
sed '/^#/d' eggnog/cje.emapper.decorated.gff | awk -F'\t' -v OFS='\t' '{$1=$1 "_" (++count[$1])}1' | sed 's/\(ID=[^;]*\);partial[^;]*;//g' | awk '$0 = "ID=" $0' |  awk -F  '\t' ' { printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s;%s\n",$1,$2,$3,$4,$5,$6,$7,$8,$1,$9; }' | sed 's/^ID=//g' > eggnog/cje.emapper.decorated2.gff

#Not working (it seems that it requires circular genomes)
emapper2gbk genomes -fn eggnog/campylobacter_jejuni.fa -fp eggnog/cje.emapper.genepred.fasta -g eggnog/cje.emapper.decorated2.gff -n "Campylobacter jejuni" -o eggnog/cje.gbk -a eggnog/cje.emapper.annotations

emapper2gbk genes -fn eggnog/campylobacter_jejuni.fna -fp eggnog/campylobacter_jejuni.faa -n "Campylobacter jejuni" -o eggnog/cje.gbk -a eggnog/campylobacter_jejuni.emapper.annotations

```

Prodigal > emapper > emapper2gbk

### Run metabolic network reconstructions
m2m recon runs metabolic network reconstruction for all annotated genomes, using Pathway Tools.
```
cd /Users/anttonalberdi/github/campylo_gsmn
mkdir recon
m2m recon -g genomes -o recon -c 2
```

### Run metabolic network reconstructions
m2m metacom runs all analyses: individual scopes, community scopes, and minimal community selection based on the metabolic added-value of the microbiota.


**Scope**: the metabolic potential or reachable metabolites in given nutritional conditions described as seed compounds.

**indiv_scopes.json**: set of reachable metabolites for each organism organised by organisms. ***Warning: the seeds are included in the scopes, hence they will never be empty.***
**rev_iscope.json**: set of reachable metabolites for each organism organised by metabolites.
**comm_scopes.json**: set of reachable metabolites of the entire community.

**Added value**: metabolic added-value of cooperation over individual metabolism. The metabolites that can only be reached by the combined action of microorganisms.

```
cd /Users/anttonalberdi/github/campylo_gsmn
mkdir seeds
cd seeds
wget https://raw.githubusercontent.com/AuReMe/metage2metabo/master/article_data/gut_microbiota/seeds_gut_final.sbml
cd ../
mkdir metacom
m2m metacom -n recon/sbml -s seeds/seeds_gut_final.sbml  -o metacom
```

Campylobacter jejuni
ERR4836918_bin.11

Campylobacter coli
ERR4836965_bin.9.fa

Bacteroides fragilis_A
ERR4968581_bin.26
