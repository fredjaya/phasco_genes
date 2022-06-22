#!/usr/bin/env nextflow

nextflow.enable.dsl = 1

Channel
    .fromPath(params.bed)
    .splitText(each: { it.split()[6] } )
    .unique()
    .set { gene_list_ch }

process split_bed {
    // Split input .bed into multiple files according to gene
    publishDir "${params.out}/split_bed"
    input: 
        path bed from params.bed
        val gene from gene_list_ch

    output:
        path "*.bed" into regions_ch

    script:
    """
    grep ${gene} ${bed} > ${gene}.bed
    """
}

process extract_vcf_genes {
    // Extract separate .vcf from individual .bed for per-gene analyses
    publishDir "${params.out}/extracted_genes"
    input:
        path vcf from params.vcf
        path tbi from params.tbi
        path regions from regions_ch

    output:
        path "*.vcf" into vcf_genes_ch
    
    script:
    """
    tabix -R ${regions} -h ${vcf} > ${regions.simpleName}.vcf
    """
        
}

process extract_vcf_whole {
    // Extract a single .vcf containing all gene regions for RDA
    publishDir "${params.out}" 
    input:
        path vcf from params.vcf
        path tbi from params.tbi
        path bed from params.bed

    output:
        path "combined.vcf" into vcf_whole_ch, vcf_whole_raw
    
    script:
    """
    tabix -R ${bed} -h ${vcf} > combined.vcf
    """
}

vcf_genes_ch
    .mix(vcf_whole_ch)
    .into { genes_het_ch; genes_prune_ch; genes_pca_pruned_ch; genes_pca_unpruned_ch }

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
        path gene from vcf_whole_raw

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
    errorStrategy { task.exitstatus = 7 ? 'ignore' : 'terminate' }
    // Error: No variants on --vcf file

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
    errorStrategy { task.exitstatus = 13 ? 'ignore' : 'terminate' }
    // 13: No variants remaining after main filters
    
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
        --out ${gene.simpleName}_pruned \
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
    errorStrategy { task.exitstatus = 13 ? 'ignore' : 'terminate' }
    // 13: Failed to extract eigenvector(s) from GRM

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
