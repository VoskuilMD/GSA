#!/bin/bash

#########################################################################
# GSA to Opticall (08/2017)                                             #
#                                                                       #
# Arnau Vich: arnauvich@gmail.com                                       #
#########################################################################

## USAGE ##

# bash opticall_format_GSA_v2.sh -i $input -s 1 -a 23 -c 20 -x 19 -A 30 -B 31
# s => column containing snps name
# a => column containing allele, p.e [A/G]
# c => column containing snp position
# x => column containing chromosome 
# A => column containing illumina norm. intensity for allele 1
# B => column containing illumina norm. intensity for allele 2

#Get command line options
while getopts ":i:s:a:c:x:A:B:" opt; do
  case "$opt" in
    i) input=$OPTARG ;;
    s) my_snp=$OPTARG ;;
    a) alleles=$OPTARG ;;
    #b) alleles2=$OPTARG ;;
    c) coor=$OPTARG ;;
    x) chr=$OPTARG ;;
    A) intA=$OPTARG ;;
    B) intB=$OPTARG ;;
  esac
done
# Flag to extract header
flag=1
shift $(( OPTIND - 1 ))
# Split file per sample id, in this case: second column (first 10 columns is a header)
awk '{if(NR>10){print >> $2".tmp"}}' $input 
# Extract info of all snps in the first condition + intensities of first sample
for a in *tmp; 
    do
    sid=${a%.tmp} 
    if [ "$flag" -eq 1 ]
        then
            less "$a" | awk -F "\t" -v name=$sid -v chr=$chr -v snp=$my_snp -v al=$alleles -v c=$coor -v A=$intA -v B=$intB 'BEGIN { print "Chr" "\t" "SNP" "\t" "Coor" "\t" "Alleles" "\t" name "A" "\t" name "B" }{ print $chr "\t" $snp "\t" $c "\t" substr($al,2,1) substr($al,4,1) "\t" $A "\t" $B}' > info
            flag=2
# keep intensities per sample
    else
        echo $sid
        less "$a" | awk -F "\t" -v name=$sid -v chr=$chr -v snp=$my_snp -v al=$alleles -v c=$coor -v A=$intA -v B=$intB 'BEGIN { print  name "A" "\t" name "B" }{ print  $A "\t" $B}' > "$a".tmp2
    fi
done
# Paste all intensities and paste snp info with the merged intensities 
paste *tmp2 > final.tmp
paste info final.tmp > all_final.tmp
# Split by chromosome
awk '{if(NR>10){print >> $1".tmp3"}}' all_final.tmp
# Add header and remove chromosome column 
for z in *tmp3; 
    do
    sid2=${z%.tmp3}
    head -1 all_final.tmp >> "chr_tmp_"$sid2
    cat $z >> "chr_tmp_"$sid2
    cut -f2- "chr_tmp_"$sid2 > "chr_"$sid2
done
# Remove temp files. 
rm *tmp*
rm  info
