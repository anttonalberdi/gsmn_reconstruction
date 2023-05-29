######
# Genome-scale metabolic network generation script
# Antton alberdi
# 2023/05/27
# Description: the pipeline creates genome-scale metabolic networks in sbml
# format from a set of bacterial genome sequences stored in a folder.
######

# 1) Copy this snakefile to the working directory
# 2) Store the genome sequences in the folder 'mag_catalogue' in the working directory with extension .fa
# 3) Launch the snakemake using the following code:
# snakemake -j 20 --cluster 'sbatch -o logs/{params.jobname}-slurm-%j.out --mem {resources.mem_gb}G --time {resources.time} -c {threads} --job-name={params.jobname} -v'   --use-conda --conda-frontend mamba --conda-prefix conda --latency-wait 600
# 4) Output files (gbk and sbml) will be produced in the genomes directory

#List sample wildcards
samples, = glob_wildcards("mag_catalogue/{sample}.fa")

#Expand target files
rule all:
    input:
        expand("genomes/{sample}.sbml", sample=samples)

rule prodigal:
    input:
        "mag_catalogue/{sample}.fa"
    output:
        fna=temp("genomes/{sample}/{sample}/{sample}.genes.fna"),
        faa=temp("genomes/{sample}/{sample}/{sample}.genes.faa")
    params:
        jobname="{sample}.pr"
    conda:
        "environment.yml"
    threads:
        1
    resources:
        mem_gb=8,
        time='01:00:00'
    shell:
        """
        prodigal -i {input} -d {output.fna} -a {output.faa}
        """

rule eggnogmapper:
    input:
        faa="genomes/{sample}/{sample}/{sample}.genes.faa"
    output:
        ann=temp("genomes/{sample}/{sample}/{sample}.emapper.annotations"),
        hit=temp("genomes/{sample}/{sample}/{sample}.emapper.hits"),
        ort=temp("genomes/{sample}/{sample}/{sample}.emapper.seed_orthologs")
    params:
        jobname="{sample}.eg",
        outname="{sample}",
        outdir="genomes/{sample}/{sample}"
    conda:
        "environment.yml"
    threads:
        8
    resources:
        mem_gb=24,
        time='06:00:00',
        tmpdir="tmp"
    shell:
        """
        emapper.py  \
            -i {input.faa} \
            --cpu {threads} \
            --data_dir /projects/mjolnir1/data/databases/eggnog-mapper/20230317/ \
            -o {params.outname} \
            --output_dir {params.outdir} \
            --temp_dir {resources.tmpdir} \
            -m diamond --dmnd_ignore_warnings \
            --itype proteins \
            --evalue 0.001 --score 60 --pident 40 --query_cover 20 --subject_cover 20 \
            --tax_scope auto --target_orthologs all --go_evidence non-electronic \
            --pfam_realign none
        """

rule emapper2gbk:
    input:
        fna="genomes/{sample}/{sample}/{sample}.genes.fna",
        faa="genomes/{sample}/{sample}/{sample}.genes.faa",
        ann="genomes/{sample}/{sample}/{sample}.emapper.annotations"
    output:
        file="genomes/{sample}/{sample}/{sample}.gbk"
    params:
        jobname="{sample}.gb"
    conda:
        "environment.yml"
    threads:
        1
    resources:
        mem_gb=1,
        time='00:20:00'
    shell:
        """
        emapper2gbk genes -fn {input.fna} -fp {input.faa} -a {input.ann} -o {output.file}
        """

rule gbk2sbml:
    input:
        file="genomes/{sample}/{sample}/{sample}.gbk"
    output:
        sbml="genomes/{sample}_recon/sbml/{sample}.sbml",
        dir=directory("genomes/{sample}_recon")
    params:
        jobname="{sample}.sb"
    threads:
        1
    resources:
        mem_gb=8,
        time='00:30:00'
    shell:
        """
        module load pathway-tools/27.0 blast/2.13.0 metage2metabo/1.5.3
        inputdir=$(echo {input.file} | awk -F'/' '{{OFS="/"; print $1,$2}}')
        m2m recon -g ${{inputdir}} -o {output.dir} -c 1
        """

rule outputfiles:
    input:
        gbk="genomes/{sample}/{sample}/{sample}.gbk",
        sbml="genomes/{sample}_recon/sbml/{sample}.sbml"
    output:
        gbk="genomes/{sample}.gbk",
        sbml="genomes/{sample}.sbml"
    params:
        jobname="{sample}.mv"
    threads:
        1
    resources:
        mem_gb=1,
        time='00:01:00'
    shell:
        """
        cp {input.gbk} {output.gbk}
        cp {input.sbml} {output.sbml}
        rm -rf genomes/{wildcards.sample}
        rm -rf genomes/{wildcards.sample}_recon
        """
