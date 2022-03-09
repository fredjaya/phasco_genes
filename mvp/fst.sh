#!/bin/bash

for aqp in *.vcf; do
  name=`basename $aqp | sed 's/\.vcf\.gz$//'`
  vcftools --weir-fst-pop pop/Campbelltown.inds \
    --weir-fst-pop pop/French_Island.inds \
    --weir-fst-pop pop/Gunnedah.inds \
    --weir-fst-pop pop/Highlands.inds \
    --weir-fst-pop pop/Monaro.inds \
    --weir-fst-pop pop/Moreton_Bay.inds \
    --weir-fst-pop pop/Port_Stephens.inds \
    --weir-fst-pop pop/South_Gippsland.inds \
    --weir-fst-pop pop/Strathbogies.inds \
    --weir-fst-pop pop/Wingecaribee.inds \
    --weir-fst-pop pop/Wollondilly.inds \
    --vcf ${aqp} --out vcftools/fst/${name}
done
