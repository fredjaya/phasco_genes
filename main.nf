#!/usr/bin/env nextflow

bed_ch = Channel.fromPath("${params.bed}/*.bed")

process genes_from_vcf {

    publishDir "${params.out}/genes"

    input:
        // Joint called .vcf
        path vcf from params.vcf
        path tbi from params.tbi
        path bed from bed_ch

    output:
        path "*.vcf"
    
    script:
    """
    tabix -R ${bed} -h ${vcf} > ${bed.simpleName}.vcf
    """
        
}
