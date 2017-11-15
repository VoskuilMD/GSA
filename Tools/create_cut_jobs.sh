#!/bin/bash

for x in {european,admixed};
do
  for i in {1..22};
  do
echo "#!/bin/bash" >> cut_"$x"_chr"$i".sh
echo "#SBATCH --job-name=cut_eur_chr."$i"" >> cut_"$x"_chr"$i".sh
echo "#SBATCH --mem 10gb" >> cut_"$x"_chr"$i".sh
echo "#SBATCH --time=10:00:00" >> cut_"$x"_chr"$i".sh
echo "#SBATCH --nodes 1" >> cut_"$x"_chr"$i".sh
echo ". set_cut_variables.sh" >> cut_"$x"_chr"$i".sh
echo "module load R" >> cut_"$x"_chr"$i".sh
echo "module load Perl" >> cut_"$x"_chr"$i".sh
echo "cd" '$RUNDIR/'""$x"/results" >> cut_"$x"_chr"$i".sh
echo "perl vcfparse.pl -d" '$RUNDIR'"/imputation/"$x"/results/chr"$i" -o "$x"_chr"$i" -g" >> cut_"$x"_chr"$i".sh;
done;
