process GNU_SORT {
    tag "$meta.id"
    label 'process_high'

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'ubuntu:20.04' }"

    input:
    tuple val(meta), path(bed)

    output:
    tuple val(meta), path("*.sorted.bed"), emit: bed
    path "versions.yml",                   emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def mem = task.memory.giga
    """
    gnu_sort.sh "$args" ${task.cpus} ${mem}G $bed ${prefix}.sorted.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        GNU Sort: \$(echo \$(sort --version | grep sort | sed 's/.* //g'))
    END_VERSIONS
    """
}
