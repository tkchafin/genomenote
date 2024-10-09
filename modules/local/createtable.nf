process CREATETABLE {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.10.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10.2':
        'biocontainers/python:3.10.2' }"

    input:
    tuple val(meta), path(genome_summary), path(sequence_summary)
    tuple val(meta1), path(busco)
    tuple val(meta2), path(qv), path(completeness)
    tuple val(meta3s), path(flagstats, stageAs: "?/*")

    output:
    tuple val(meta), path("*.csv"), emit: csv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in sanger-tol/genomenote/bin/
    def prefix = task.ext.prefix ?: "${meta.id}"
    def gen = genome_summary ? "--genome ${genome_summary}" : ""
    def seq = sequence_summary ? "--sequence ${sequence_summary}" : ""
    def bus = busco ? "--busco ${busco}" : ""
    def mqv = qv ? "--qv ${qv}" : ""
    def mco = completeness ? "--completeness ${completeness}" : ""
    def hic = meta3s.collect { "--hic " + it.id } .join(' ')
    def fst = (flagstats instanceof List ? flagstats : [flagstats]).collect { "--flagstat " + it } .join(' ')
    """
    create_table.py \\
        $gen \\
        $seq \\
        $bus \\
        $mqv \\
        $mco \\
        $hic \\
        $fst \\
        --outcsv ${prefix}.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        create_table.py: \$(create_table.py --version | cut -d' ' -f2)
    END_VERSIONS
    """
}
