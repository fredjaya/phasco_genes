## Prepare sample data

### Get AQP annotations

.gff (n = 8096 scaffolds) 

```
# filter .gff for AQP regions only
grep AQP Phascolarctos_cinereus.phaCin_unsw_v5.1.98.gff3 | \
	grep -P '\tgene\t' | \
	cut -f1,4,5,9 | \
	perl -pe 's/;biotype.+$//;' \
	-pe 's/ID.+=//;'
	> aqp_genes.regions
```

Get annotations for cds, introns etc: "AQP" not present in exons or cds, so manually curate from `Phascolarctos_cinereus.phaCin_unsw_v4.1.98.gff3` --> `AQP_complete.gff`

Only AQP2,3,4,6,8,9,10,11

- [ ] How to get annotations from other AQPs? Such as AQP5 which was shown to be positively expanding in Koala genome paper.

Get regions from test samples:
```
tabix SIL9218_96samples.hard-filtered.vcf.gz
qsub extract_aqp.sh
```

## vcftools stats

First generate `pop/*.inds` in `aqp.Rmd`
```
for i in *.vcf; do vcftools.sh $i; done
fst.sh
```

## Gene trees

conda conflicts with vcfkit - download via pip
```
cd ~/Dropbox/koala/02_working/2202_aqp
for i in *.vcf; do vk phylo tree nj ${i} > vk_tree/${i}.tre; vk phylo fasta ${i} > vk_tree/${i}.fa; done
```
