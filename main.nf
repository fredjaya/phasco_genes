#!/usr/bin/env nextflow

bed_ch = Channel.fromPath("${params.bed}/*.bed")

process genes_from_vcf {
    
    /* For each .bed file in bed_ch, extract gene region from a 
     * joint called .vcf. Currently CDS only.
     */ 
   
    publishDir "${params.out}/genes"

    input:
        path vcf from params.vcf
        path tbi from params.tbi
        path bed from bed_ch

    output:
        path "*.vcf" into genes_het_ch, genes_raw_ch
    
    script:
    """
    tabix -R ${bed} -h ${vcf} > ${bed.simpleName}.vcf
    """
        
}

process het {
    
    /* Calculate the observed (Ho) and expected homozygosity (He), and 
     * inbreeding coefficient (F) in each gene region
     */ 
    
    publishDir "${params.out}/het"

    input:
        path gene from genes_het_ch

    output:
        path "*.het" //into het_ch
        //path "*.log" nf outputs this as the .command.log
    
    script:
    """
    vcftools --vcf ${gene} --out ${gene.simpleName} --het
    """
        
}
/*
process vis_hom {
    
    // Visualise vcftools --het output individuals on map\
    // TODO: Fix r-package conflicts

    publishDir "${params.out}/hom"

    input:
        path het from het_ch

    output:
        path "*_het.png"
    
    script:
    """
    Rscript visualise_hom.R ${metadata} ${het} ${het.simpleName}
    """
        
}
*/

process convert_raw {
    
    /* Convert vcf to .raw format to input in R
     */ 
    
    publishDir "${params.out}/genes"

    input:
        path gene from genes_raw_ch

    output:
        path "*.tped"
        path "*.tfam"
        path "*.raw"
        path "*.nosex"
        //path "*.log" nf outputs this as the .command.log
    
    script:
    """
    vcftools --vcf ${gene} --plink-tped --out ${gene.simpleName} 
    plink --tped ${gene.simpleName}.tped --tfam ${gene.simpleName}.tfam --recodeA --out ${gene.simpleName}  
    """
}
