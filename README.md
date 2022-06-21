# phasco_genes
Pipeline for investigating genotype-environment associations (GEA) in koala genomes.

## 1. Overview  

This pipeline aims to identify koala loci likely to have adapated to various climate conditions. It largely utilises redundancy analyses (RDA) as described in [Capblancq and Forester (2021)](https://doi.org/10.1111/2041-210X.13722) and [Forester et al. (2018)](https://popgen.nescent.org/2018-03-27_RDA_GEA.html).  

It utilises R, nextflow, and a load of command-line tools to deal with the pre-processing of genome data and climatic variables for RDA.

### 1.1 Workflow  

```mermaid
graph TD
    subgraph "Genotype inputs (Explanatory variables)"
        g1[[.bed]] & g2[[.vcf]] & g3[[.tbi]]
    end

    subgraph "nextflow (main.nf)"
        g1-->split_bed-->extract_vcf_genes
        g1--> extract_vcf_whole
        g2 & g3-->extract_vcf_genes & extract_vcf_whole
        extract_vcf_genes & extract_vcf_whole-->het & pca_unpruned & linkage_pruning & convert_raw
        linkage_pruning-->pca_pruned
        convert_raw-->n4[["SNPs (.raw)"]]
    end

    subgraph Predictor variable inputs
        p1[["Koala metadata (coordinates)"]] & p2[["Population structure (PCs)"]]
    end

        p1-- Upload to ---p3["Atlas of Living Australia - spatial portal"]
        p3-- Select climate layers ---p4[Climate variables per coordinate]
        p4 & p2-->p5(00_prepare_predictor_variables.R)
        p5-->p6[[predictors.rds]]

    n4 & p6 --> r1 & r3
    subgraph Redundancy analysis
        r1["climate | (structure)"]-->r2[Identify outlier SNPs]
        r3[Partial RDA models]
    end

    subgraph LEGEND
        l1[process/script/function]
        l2[[file]]
    end
```  

## 2. Dependencies and Installation  

First, download this repo:  
```
git clone https://github.com/fredjaya/phasco_genes.git
```  

Next, [install miniconda](https://docs.conda.io/en/latest/miniconda.html). There are quite a few dependencies to install, but conda will allow you to download R, nextflow and the command-line tools easily.

Create a conda environment, install the tools using the yaml file, and activate the environment:  
```
conda env create -f env.yml
conda activate phasco-genes
```  

Install R packages:  
```
Rscript bin/install_packages.R
```

## 3. Input data

**Predictor variables**  
1. Climate variables  
2. Population structure  

**Explanatory variables (genotype)**  
3. Whole genome resequencing data `.vcf(.gz)`  
4. Annotation file `.bed`  

### 3.1 Climate variables  


### 1. Preparing the genome data  

input .vcf/gz should be bgzipped and tabixd.

`/data/*` are gene regions of the longest transcript.

### 3. Preparing the annotation file  

Then convert to .bed and retain only CDS regions
```
gff2bed < /data/*.gff | grep -P '\tCDS\t' > /data/*.bed
```

### 3. Preparing environmental variables  

- Upload metadata with lat/longs to Spatial ALA  
- Select layers or upload `data/layerList.csv`  
- Export  
- ???  
- Profit  

## Running the pipeline (nextflow)
paths currently hardcoded in `nextflow.config`
```
nextflow run main.nf
```

## Ideas, to-do, scratch

How are results impacted when conducting GEAs on individual genes (CDS) vs. combined? Also consider whether it's worth splitting .bed file to parallelise extraction.

For now, keep input regions as a single file (replace directory params.bed to single file). single file can be a .bed or .tsv, but needs to be sorted I think.

Input region file must not have overlapping regions, alternate isoforms. For example, this will occur when you have entries for both genes and exons.

Need better version control with conda packages.

Are there any other stats that can/need to be run on the .vcf alone? For example, allele frequencies `vcftools -freq` can be used as the response variable. 

Rscripts to visualise heterozygosity, allele frequency etc. Better yet, generate knitted Rmarkdown report.

Add documentation and usage CLI.

Failed to extract eigenvector(s) from GRM with exonID_MHCI-3-partial. Setting errorStrat for pca_unpruned to ignore cause not important.

When exporting nextflow project - make sure to copy hardlinks. e.g. `rsync -L`

Incorporate .R scripts in nextflow?

Add script for visualising predictor variables? i.e. map with climate variables per sample, climate variable distributions, whole-genome PCA.  

Can't match 2/308 vcf names to koalas in MHC data.

How to deal with missing SNPs in data?  

Add PCA with neutral SNPs
