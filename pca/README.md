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
`n260/prune.in` 6214588 (10.97%)

PCA time:
```
plink2 --vcf n260.vcf.gz --double-id --allow-extra-chr --set-missing-var-ids @:# --extract n260.prune.in --make-bed --pca --out n260
```

PCA on clusters (VIC vs. NSW+QLD):

## Resources
[Population structure: PCA](https://speciationgenomics.github.io/pca/)
