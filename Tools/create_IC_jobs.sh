#!/bin/bash

for i in {admixed,european};
do
echo "#!/bin/bash" >> IC_"$i".sh
echo "#SBATCH --job-name=IC_"$i"" >>IC_"$i".sh
echo "#SBATCH --mem 50gb" >> IC_"$i".sh
echo "#SBATCH --time=23:59:00" >> IC_"$i".sh
echo "#SBATCH --nodes 1" >> IC_"$i".sh
echo ". set_cut_variables.sh" >> IC_"$i".sh
echo "cd" '$RUNDIR/scripts' >> IC_"$i".sh
echo "module load PerlPlus" >> IC_"$i".sh
echo "module load Java" >> IC_"$i".sh
echo "perl ic.pl -d" '$RUNDIR'"/imputation/"$i"/results -r" '$RUNDIR'"/imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h -o" '$RUNDIR'"/imputation/"$i"/results/ICoutput" >> IC_"$i".sh;
done
