rule all:
    input:
        expand("{sample}/{sample}.gbk")

rule prodigal:
    input:
        "{sample}.fa"
    output:
        fna="{sample}/{sample}.genes.fna",
        faa="{sample}/{sample}.genes.faa"
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
        "{sample}/{sample}.genes.faa"
    output:
        ann="{sample}/{sample}.emapper.annotations",
        hit="{sample}/{sample}.emapper.hits"
    params:
        jobname="{sample}.eg",
        outname="{sample}",
        outdir="{sample}"
    conda:
        "environment.yml"
    threads:
        8
    resources:
        mem_gb=24,
        time='02:00:00',
        tmpdir="{sample}/tmp"
    shell:
        """
        emapper.py  \
            -i {input} \
            --cpu 8 \
            --data_dir /projects/mjolnir1/data/databases/eggnog-mapper/20230317/ \
            -o {params.outname} \
            --output_dir {params.outdir} \
            --temp_dir /projects/mjolnir1/people/jpl786/eggnog/campylobacter_jejuni/tmp \
            -m diamond --dmnd_ignore_warnings \
            --itype proteins \
            --evalue 0.001 --score 60 --pident 40 --query_cover 20 --subject_cover 20 \
            --tax_scope auto --target_orthologs all --go_evidence non-electronic \
            --pfam_realign none
        """

rule emapper2gbk:
    input:
        fna="{sample}/{sample}.genes.fna",
        faa="{sample}/{sample}.genes.faa",
        ann="{sample}/{sample}.emapper.annotations"
    output:
        "{sample}/{sample}.gbk"
    params:
        jobname="{sample}.gb",
        samplename="{sample}"
    conda:
        "environment.yml"
    threads:
        1
    resources:
        mem_gb=1,
        time='00:20:00'
    shell:
        """
        emapper2gbk genes \
            -fn {input.fna} \
            -fp {input.faa} \
            -a {input.ann} \
            -n {params.samplename} \
            -o {output}
        """
