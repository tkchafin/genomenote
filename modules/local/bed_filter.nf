process BED_FILTER {
    tag "$meta.id"
    label 'process_samtools'

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'ubuntu:20.04' }"

    input:
    tuple val(meta), path(bed)

    output:
    tuple val(meta), path("*pairs"), emit: pairs
    path "versions.yml",             emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bed_filter.sh $bed ${prefix}.filtered.pairs

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        GNU Awk: \$(echo \$(awk --version 2>&1) | grep -i awk | sed 's/GNU Awk //; s/,.*//')
    END_VERSIONS
    """
}
