# Author: Michiel Voskuil 

# Date: 2017/10/31

1. Load tools in HPC environment
--------------------------------

```
module load plink
module load opticall
module load Perl
module load Python
```

2. Convert GS output into optiCall input file
--------------------------------

IDAT files are read by GS and converted into normalised intensities per variant. We use opticall for the genotype calling so we first need to convert the file.

# s => column containing snps name
# a => column containing allele, p.e [A/G]
# c => column containing snp position
# x => column containing chromosome 
# A => column containing illumina norm. intensity for allele 1
# B => column containing illumina norm. intensity for allele 2

```
bash GS_to_OptiCall.sh -i $input -s 1 -a 23 -c 20 -x 19 -A 30 -B 31
```

3. 