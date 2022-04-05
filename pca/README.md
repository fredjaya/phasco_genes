# PCA

Aim to identify genes associated with environmental variables.

Using n = 260 koalas.

First, merge individual vcfs:
```
ls vcf/*.vcf.gz | xargs -I {} -n 1 -P 12 sh -c "tabix {}"
bcftools merge vcf/*.vcf.gz -Oz -o n260.vcf.gz 
```

Get general vcf stats:
```
bcftools stats n260.vcf.gz > n260_stats.txt
```

Perform linkage pruning to ensure sites used for PCA are indepdendent:
```
# ~ 40 mins
plink2 --vcf n260.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 50 10 0.1 --out n260
```

`n260.prune.out` 50432395 (89.03%)
`n260.prune.in` 6214588 (10.97%)

PCA time:
```
plink2 --vcf n260.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --extract n260.prune.in --pca --out n260
```

PCA on clusters (VIC vs. NSW+QLD):
```
# Subset vcf
bcftools view -S vic_samples.txt -o vic_n49.vcf.gz -Oz n260.vcf.gz 
bcftools view -S nsw_qld_samples.txt -o nsw_qld_n210.vcf.gz -Oz n260.vcf.gz 

# Prune
plink2 --vcf vic_n49.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 50 10 0.1 --out vic_n49 
plink2 --vcf nsw_qld_n210.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --indep-pairwise 50 10 0.1 --out nsw_qld_n210

# Generate allele frequency files 
plink2 --vcf vic_n49.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --extract vic_n49.prune.in --freq --max-alleles 2 --out vic_n49 
plink2 --vcf nsw_qld_n210.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --extract nsw_qld_n210.prune.in --freq --max-alleles 2 --out nsw_qld_n210

# Run PCAs
plink2 --vcf vic_n49.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --extract vic_n49.prune.in --pca --read-freq vic_n49.afreq --rm-dup list --out vic_n49 
plink3 --vcf nsw_qld_n210.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --extract vic_n49.prune.in --pca --read-freq vic_n49.afreq --rm-dup list --out vic_n49 
```

Only ran NSW-QLD PCA so far, recurring issues with VIC

## Resources
[Population structure: PCA](https://speciationgenomics.github.io/pca/)
