#!/bin/bash

IN_VCF=$1
OUT_PREFIX=`basename ${IN_VCF} .vcf`

vcftools --vcf ${IN_VCF} --out vcftools/het/${OUT_PREFIX} --het
vcftools --vcf ${IN_VCF} --out vcftools/tstv/${OUT_PREFIX} --TsTv-summary
vcftools --vcf ${IN_VCF} --out vcftools/tajimad/${OUT_PREFIX}_1 --TajimaD 100
vcftools --vcf ${IN_VCF} --out vcftools/tajimad/${OUT_PREFIX}_10 --TajimaD 100
vcftools --vcf ${IN_VCF} --out vcftools/tajimad/${OUT_PREFIX}_100 --TajimaD 100
# Fst calculated separately
