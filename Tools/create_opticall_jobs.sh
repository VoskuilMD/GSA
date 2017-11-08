# Create opticall jobs for chromosomes 1-22
for i in {1..22}
do
echo "#!/bin/bash" >> scripts/chr_"$i"_opticall.sh
echo "#SBATCH --job-name=chr_"$i"_opticall" >> scripts/chr_"$i"_opticall.sh
echo "#SBATCH --mem 10gb" >> scripts/chr_"$i"_opticall.sh
echo "#SBATCH --time=24:00:00" >> scripts/chr_"$i"_opticall.sh
echo "#SBATCH --nodes 1" >> scripts/chr_"$i"_opticall.sh
#echo "#SBATCH --open-mode=append" >> scripts/chr_"$i"_opticall.sh
#echo "#SBATCH --export=NONE" >> scripts/chr_"$i"_opticall.sh
echo "module load opticall" >> scripts/chr_"$i"_opticall.sh
echo "cd" $RUNDIR/opticall_input >> scripts/chr_"$i"_opticall.sh
echo '$EBROOTOPTICALL/opticall' "-in chr_"$i" -info" $info "-out ../opticall_output/chr_"$i"" >> scripts/chr_"$i"_opticall.sh 
done

# Create opticall jobs for chromosomes X,Y,MT
for i in {X,Y,MT}
do
echo "#!/bin/bash" >> scripts/chr_"$i"_opticall.sh
echo "#SBATCH --job-name=chr_"$i"_opticall" >> scripts/chr_"$i"_opticall.sh
echo "#SBATCH --mem 10gb" >> scripts/chr_"$i"_opticall.sh
echo "#SBATCH --time=24:00:00" >> scripts/chr_"$i"_opticall.sh
echo "#SBATCH --nodes 1" >> scripts/chr_"$i"_opticall.sh
#echo "#SBATCH --open-mode=append" >> scripts/chr_"$i"_opticall.sh
#echo "#SBATCH --export=NONE" >> scripts/chr_"$i"_opticall.sh
echo "module load opticall" >> scripts/chr_"$i"_opticall.sh
echo "cd" $RUNDIR/opticall_input >> scripts/chr_"$i"_opticall.sh
echo '$EBROOTOPTICALL/opticall' "-in chr_"$i" -info" $info "-out ../opticall_output/chr_"$i"" -"$i" >> scripts/chr_"$i"_opticall.sh 
done
