#!/bin/bash
for i in {european,admixed};
do
echo "#!/bin/bash" >> HRC-1000G-check-bim."$i".sh
echo "#SBATCH --job-name=HRC-check-bim."$i"" >> HRC-1000G-check-bim."$i".sh
echo "#SBATCH --mem 25gb" >> HRC-1000G-check-bim."$i".sh
echo "#SBATCH --time=10:00:00" >> HRC-1000G-check-bim."$i".sh
echo "#SBATCH --nodes 1" >> HRC-1000G-check-bim."$i".sh
echo "cd /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/check_files_HRC" >> HRC-1000G-check-bim."$i".sh
echo "module load R" >> HRC-1000G-check-bim."$i".sh
echo "module load Perl" >> HRC-1000G-check-bim."$i".sh
echo "perl HRC-1000G-check-bim.pl -b /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/all_"$i"-qc.bim  -f /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/check_files_HRC/all_"$i"-qc.frq  -r /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/check_files_HRC/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h" >> HRC-1000G-check-bim."$i".sh;
done
