# phasco_genesgenes.bed -h input.vcf.gz > output.vcf
Analysis of Koala gene families

## Dependencies and Installation

## Data prep

input .vcf/gz should be bgzipped and tabixd.

`/data/*` are gene regions of the longest transcript.

Then convert to .bed and retain only CDS regions
```
gff2bed < /data/*.gff | grep -P '\tCDS\t' > /data/*.bed
```

and query the regions:
```
tabix -R genes.bed -h input.vcf.gz > output.vcf
```

TODO: add gff2bed process?


## Nextflow
paths currently hardcoded in `nextflow.config`
```
nextflow run main.nf
```
