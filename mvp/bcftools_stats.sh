#!/bin/bash

IN_VCF=$1
OUT_PREFIX=`basename ${IN_VCF} .vcf.gz`

bcftools stats ${IN_VCF} > ${OUT_PREFIX}.stats

