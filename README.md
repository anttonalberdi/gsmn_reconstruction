# Campylobacter GSMN analyses
Genome-scale metabolic networks of Campylobacter and related bacteria. The repository contains several bits of code.

1. Snakemake pipeline (snakefile) for generating genome-scale metabolic networks (SBML format) from MAG sequences.
2. Python script (analysis.py) to calculate interdependencies between MAGs using SBML files.
3. R script (analysis.r) to analyse interdependencies across animals, enterotypes, etc.

## 1 - Create gbk annotations and sbml networks for MAGs
Input genome files must be stored in the 'genomes' folder with .fa extension. Note that the process of sbml generation creates intermediate files in the following directory in Mjolnir:
`/maps/projects/mjolnir1/apps/pathway-tools-27.0/ptools-local/pgdbs/user/`
These are not required for the downstream analyses, so they should ideally be removed to avoid occupying unnecessary space.

### Clone this repository
```
git clone https://github.com/anttonalberdi/campylo_gsmn.git
cd campylo_gsmn
```

### Prepare MAG fasta files
Replace dots for underscores in the genome names to avoid downstream issues.
```
cd campylo_gsmn/genomes
for f in *.*;
  do pre="${f%.*}"; suf="${f##*.}"; \
  mv -i -- "$f" "${pre//./_}.${suf}";
done
cd ../
```

### Run annotation and network generation pipeline
On a screen session, launch the snakefile to generate the SBMLs
```
screen -S campylo_gsmn
module purge && module load snakemake/7.20.0 mamba/1.3.1
snakemake \
  -j 20 \
  --cluster 'sbatch -o logs/{params.jobname}-slurm-%j.out --mem {resources.mem_gb}G --time {resources.time} -c {threads} --job-name={params.jobname} -v' \
  --use-conda --conda-frontend mamba --conda-prefix conda \
  --latency-wait 600
```

### Visualise SBMLs in FLUXER
SBML files can be visualised in the online tool
https://fluxer.umbc.edu/

## 2 - Perform dependence calculations
Create conda environment with cobra installed on it.
```
module purge && module load snakemake/7.20.0 mamba/1.3.1
conda create --name gsmn python==3.7.5
conda activate gsmn
pip install cobra
python
```
Once in python use the `gsmn_analysis.py` scripts.

## 3 - Analyse interdependencies
Once in R use the `gsmn_analysis.r` scripts.


## Other stuff to be deleted

### Prepare seeds file

```
conda activate m2m
cd /Users/anttonalberdi/github/campylo_gsmn
mkdir seeds
m2m seeds --metabolites seeds/seeds_broilers.txt -o seeds/
```

Or download them from the internet

```
cd /Users/anttonalberdi/github/campylo_gsmn
mkdir seeds
cd seeds
wget https://raw.githubusercontent.com/AuReMe/metage2metabo/master/article_data/gut_microbiota/seeds_gut_final.sbml
cd ../
```

### Run metabolic network reconstructions
m2m metacom runs all analyses: individual scopes, community scopes, and minimal community selection based on the metabolic added-value of the microbiota.

**Scope**: the metabolic potential or reachable metabolites in given nutritional conditions described as seed compounds.

**indiv_scopes.json**: set of reachable metabolites for each organism organised by organisms. ***Warning: the seeds are included in the scopes, hence they will never be empty.***
**rev_iscope.json**: set of reachable metabolites for each organism organised by metabolites.
**comm_scopes.json**: set of reachable metabolites of the entire community.

**Added value**: metabolic added-value of cooperation over individual metabolism. The metabolites that can only be reached by the combined action of microorganisms.

```
conda activate m2m
cd /Users/anttonalberdi/github/campylo_gsmn
mkdir metacom
m2m metacom -n recon/sbml -s seeds/seeds.sbml  -o metacom
```
