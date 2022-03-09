#! /bin/bash
#PBS -P awggdata
#PBS -l select=1:ncpus=1:mem=64GB
#PBS -l walltime=00:02:00

module load tabix

cd /scratch/awggdata/koala_fj
tabix -h SIL9218_96samples.hard-filtered.vcf.gz MSTS01000001.1:27914856-27974282 > AQP9.vcf
tabix -h SIL9218_96samples.hard-filtered.vcf.gz MSTS01000036.1:613404-628624 > AQP11.vcf
tabix -h SIL9218_96samples.hard-filtered.vcf.gz MSTS01000043.1:4098415-4104788 > AQP10.vcf
tabix -h SIL9218_96samples.hard-filtered.vcf.gz MSTS01000060.1:9799684-9810722 > AQP8.vcf
tabix -h SIL9218_96samples.hard-filtered.vcf.gz MSTS01000166.1:1280454-1291217 > AQP2.vcf
tabix -h SIL9218_96samples.hard-filtered.vcf.gz MSTS01000166.1:1318199-1322350 > AQP6.vcf
tabix -h SIL9218_96samples.hard-filtered.vcf.gz MSTS01000185.1:429667-438186 > AQP4.vcf
tabix -h SIL9218_96samples.hard-filtered.vcf.gz MSTS01000358.1:117585-125635 > AQP3.vcf
