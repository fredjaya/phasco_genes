#!/usr/bin/env nextflow

bed_ch = Channel.fromPath("${params.bed}/*.bed")

process genes_from_vcf {
    
    /* For each .bed file in bed_ch, extract gene region from a 
     * joint called .vcf. Currently CDS only.
     */ 
   
    publishDir "${params.out}/extracted_genes"

    input:
        path vcf from params.vcf
        path tbi from params.tbi
        path bed from bed_ch

    output:
        path "*.vcf" into genes_het_ch, genes_raw_ch, genes_prune_ch, genes_pca_pruned_ch, genes_pca_unpruned_ch
    
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
    
    publishDir "${params.out}/convert_raw"

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

process linkage_pruning {
    
    /* Prune linked sites for PCA
     * 
     * WARNING: unclear what the optimal parameters for --indep-pairwise are,
     * particularly for single gene CDS'
     * 
     * Setting r^2 > 0.05 to be conservative.
     */ 
    
    publishDir "${params.out}/pca_pruned"

    input:
        path gene from genes_prune_ch

    output:
        path "*.prune.in" into pruned_sites_ch
        path "*.prune.out"
        //path "*.log" nf outputs this as the .command.log
    
    script:
    """
    plink2 --vcf ${gene} \
        --double-id \
        --allow-extra-chr \
        --set-missing-var-ids @:# \
        --out ${gene.simpleName} \
        --indep-pairwise 50 10 0.05
    """
}

process pca_pruned {
    
    /* Run PCA with linked sites pruned
     */ 
    
    publishDir "${params.out}/pca_pruned"

    input:
        path gene from genes_pca_pruned_ch
        path pruned_sites from pruned_sites_ch

    output:
        path "*.eigenval" optional true
        path "*.eigenvec" optional true
        //path "*.log" nf outputs this as the .command.log
    
    script:
    """
    plink2 --vcf ${gene} \
        --double-id \
        --allow-extra-chr \
        --set-missing-var-ids @:# \
        --out ${gene.simpleName} \
        --extract ${pruned_sites} \
        --pca
    """
}

process pca_unpruned {
    
    /* Run PCA without linkage pruning
     *
     * Including this as all sites are likely to be thrown out in gene CDS
     */ 
    
    publishDir "${params.out}/pca_unpruned"

    input:
        path gene from genes_pca_unpruned_ch

    output:
        path "*.eigenval"
        path "*.eigenvec"
        //path "*.log" nf outputs this as the .command.log
    
    script:
    """
    plink2 --vcf ${gene} \
        --double-id \
        --allow-extra-chr \
        --set-missing-var-ids @:# \
        --out ${gene.simpleName} \
        --pca
    """
}
