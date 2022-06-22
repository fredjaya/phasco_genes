#!/bin/bash

# GIT_PATH: Where you've downloaded the repository
# OUT:		Where you want all the output data
# VCF:		Full path to .vcf.gz file
# BED:		Full path to .bed file

GIT_PATH="/home/fredjaya/GitHub/phasco_genes/"

nextflow run ${GIT_PATH}/main.nf \
	--out /home/fredjaya/Dropbox/koala/04_testing/2205_pipeline_test/example_out \
	--vcf /home/fredjaya/Dropbox/koala/04_testing/2205_pipeline_test/input/subset.vcf.gz \
	--bed ${GIT_PATH}/example/koala_MHC_exons.bed
