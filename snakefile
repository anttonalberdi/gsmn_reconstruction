#List sample wildcards
samples, = glob_wildcards("mag_catalogue/{sample}.fa")

#Expand target files
rule all:
    input:
        expand("genomes/{sample}/{sample}.gbk", sample=samples)

rule prodigal:
    input:
        "mag_catalogue/{sample}.fa"
    output:
        fna=temp("genomes/{sample}/{sample}.genes.fna"),
        faa=temp("genomes/{sample}/{sample}.genes.faa")
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
        "genomes/{sample}/{sample}.genes.faa"
    output:
        ann=temp("genomes/{sample}/{sample}.emapper.annotations"),
        hit=temp("genomes/{sample}/{sample}.emapper.hits"),
        ort=temp("genomes/{sample}/{sample}.emapper.seed_orthologs")
    params:
        jobname="{sample}.eg",
        outname="{sample}",
        outdir="genomes/{sample}"
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
            -i {input} \
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
        fna="genomes/{sample}/{sample}.genes.fna",
        faa="genomes/{sample}/{sample}.genes.faa",
        ann="genomes/{sample}/{sample}.emapper.annotations"
    output:
        "genomes/{sample}/{sample}.gbk"
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
        emapper2gbk genes -fn {input.fna} -fp {input.faa} -a {input.ann} -o {output}
        """
