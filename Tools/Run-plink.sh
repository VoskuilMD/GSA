for i in {european,admixed};
do
cd /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/check_files_HRC/
plink --bfile /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/all_"$i"-qc --exclude Exclude-all_"$i"-qc-HRC.txt --make-bed --out TEMP1
plink --bfile TEMP1 --update-chr Chromosome-all_"$i"-qc-HRC.txt --make-bed --out TEMP2
plink --bfile TEMP2 --update-chr Position-all_"$i"-qc-HRC.txt --make-bed --out TEMP3
plink --bfile TEMP3 --flip Strand-Flip-all_"$i"-qc-HRC.txt --make-bed --out TEMP4
plink --bfile TEMP4 --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --out all_"$i"-qc-updated
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 1 --out all_"$i"-qc-updated-chr1
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 2 --out all_"$i"-qc-updated-chr2
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 3 --out all_"$i"-qc-updated-chr3
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 4 --out all_"$i"-qc-updated-chr4
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 5 --out all_"$i"-qc-updated-chr5
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 6 --out all_"$i"-qc-updated-chr6
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 7 --out all_"$i"-qc-updated-chr7
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 8 --out all_"$i"-qc-updated-chr8
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 9 --out all_"$i"-qc-updated-chr9
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 10 --out all_"$i"-qc-updated-chr10
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 11 --out all_"$i"-qc-updated-chr11
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 12 --out all_"$i"-qc-updated-chr12
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 13 --out all_"$i"-qc-updated-chr13
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 14 --out all_"$i"-qc-updated-chr14
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 15 --out all_"$i"-qc-updated-chr15
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 16 --out all_"$i"-qc-updated-chr16
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 17 --out all_"$i"-qc-updated-chr17
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 18 --out all_"$i"-qc-updated-chr18
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 19 --out all_"$i"-qc-updated-chr19
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 20 --out all_"$i"-qc-updated-chr20
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 21 --out all_"$i"-qc-updated-chr21
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 22 --out all_"$i"-qc-updated-chr22
plink --bfile all_"$i"-qc-updated --reference-allele Force-Allele1-all_"$i"-qc-HRC.txt --make-bed --chr 23 --out all_"$i"-qc-updated-chr23
rm TEMP*;
done
