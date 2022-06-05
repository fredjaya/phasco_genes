# phasco_genes
Analysis of Koala gene families

## Overview  

*What does this pipeline do?*  

## Dependencies and Installation  

First, download this repo:  
```
git clone https://github.com/fredjaya/phasco_genes.git
```  

This pipeline utilises nextflow, R, and a load of command-line tools. There are quite a few dependencies to install, but conda lets you download them in one go. [install miniconda](https://docs.conda.io/en/latest/miniconda.html).  

Next, create a conda environment and install the command-line tools:  
```
conda env create -f env.yml
conda activate phasco-genes
```  

*TODO: add R and nextflow to conda env*  

You will need to manually install several R packages:  
```
bin/install_packages.R
```

## Input data

1. Genome data with all individuals (joint-called) `.vcf(.gz)`  
2. Annotation file of CDS regions to extract `.gff`  
3. Environmental variables i.e. rasters `.tif`  

### 1. Preparing the genome data  

input .vcf/gz should be bgzipped and tabixd.

`/data/*` are gene regions of the longest transcript.

### 2. Preparing the annotation file  

Then convert to .bed and retain only CDS regions
```
gff2bed < /data/*.gff | grep -P '\tCDS\t' > /data/*.bed
```

and query the regions:
```
tabix -R genes.bed -h input.vcf.gz > output.vcf
```

TODO: add gff2bed process?
TODO: discuss with others regarding long-term inputs - always joint-called? single-sample would be better to run in parallel

### 3. Preparing environmental variables  

Need to do some manual work here/hardcoding to prepare your environmental variables (e.g. remove collinear variables), but once that's done you're set!  
```

```

## Running the pipeline (nextflow)
paths currently hardcoded in `nextflow.config`
```
nextflow run main.nf
```

TODO: How are results impacted when conducting GEAs on individual genes (CDS) vs. combined?
