#!/bin/bash

for i in {1..22};
do
echo "#!/bin/bash" >> cut_eur_chr"$i".sh
echo "#SBATCH --job-name=cut_eur_chr."$i"" >> cut_eur_chr"$i"
echo "#SBATCH --mem 10gb" >> cut_eur_chr"$i"
echo "#SBATCH --time=10:00:00" >> cut_eur_chr"$i"
echo "#SBATCH --nodes 1" >> cut_eur_chr"$i"
echo "cd /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/post_imputation" >> cut_eur_chr"$i"
echo "module load R" >> cut_eur_chr"$i"
echo "module load Perl" >> cut_eur_chr"$i"
echo "perl vcfparse.pl -d /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/european_to_HRC_EUR/chr"$i" -o european_to_HRC_EUR_chr"$i"  -g" >> cut_eur_chr"$i";
done
