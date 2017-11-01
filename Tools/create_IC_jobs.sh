#!/bin/bash

for i in {admixed_to_HRC_EUR,admixed_to_HRC_AMR,european_to_HRC_EUR};
do
echo "#!/bin/bash" >> IC_"$i".sh
echo "#SBATCH --job-name=IC_"$i"" >>IC_"$i".sh
echo "#SBATCH --mem 50gb" >> IC_"$i".sh
echo "#SBATCH --time=23:59:00" >> IC_"$i".sh
echo "#SBATCH --nodes 1" >> IC_"$i".sh
echo "cd /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/post_imputation" >> IC_"$i".sh
echo "module load PerlPlus" >> IC_"$i".sh
echo "module load Java" >> IC_"$i".sh
echo "perl /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/post_imputation/IC/ic.pl -d /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/post_imputation/"$i" -r /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/check_files_HRC/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h -o /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/post_imputation/"$i"/ICoutput
" >> IC_"$i".sh;
done
