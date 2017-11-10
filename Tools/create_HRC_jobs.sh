#!/bin/bash
for i in {european,admixed};
do
echo "#!/bin/bash" >> HRC-1000G-check-bim."$i".sh
echo "#SBATCH --job-name=HRC-check-bim."$i"" >> HRC-1000G-check-bim."$i".sh
echo "#SBATCH --mem 25gb" >> HRC-1000G-check-bim."$i".sh
echo "#SBATCH --time=10:00:00" >> HRC-1000G-check-bim."$i".sh
echo "#SBATCH --nodes 1" >> HRC-1000G-check-bim."$i".sh
echo ". set_HRC_variables.sh" >> HRC-1000G-check-bim."$i".sh
echo "cd" '$RUNDIR/imputation/'""$i"" >> HRC-1000G-check-bim."$i".sh
echo "module load R" >> HRC-1000G-check-bim."$i".sh
echo "module load Perl" >> HRC-1000G-check-bim."$i".sh
echo "module load Java" >> HRC-1000G-check-bim."$i".sh
echo "perl" '$RUNDIR/scripts/HRC-1000G-check-bim.pl' "-b" '$RUNDIR/imputation/'""$i"/GSA-"$i".bim -f" '$RUNDIR/imputation/'""$i"/GSA-"$i".frq -r" '$RUNDIR/imputation/HRC.r1-1.GRCh37.wgs.mac5.sites.tab'" -h" >> HRC-1000G-check-bim."$i".sh;
done
