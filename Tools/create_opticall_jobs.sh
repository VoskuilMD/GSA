# Create opticall jobs for chromosomes 1-22
for i in {1..22}
do
echo "#!/bin/bash" >> chr_"$i"_opticall.sh
echo "#SBATCH --job-name=chr_"$i"_opticall" >> chr_"$i"_opticall.sh
echo "#SBATCH --mem 10gb" >> chr_"$i"_opticall.sh
echo "#SBATCH --time=24:00:00" >> chr_"$i"_opticall.sh
echo "#SBATCH --nodes 1" >> chr_"$i"_opticall.sh
#echo "#SBATCH --open-mode=append" >> chr_"$i"_opticall.sh
#echo "#SBATCH --export=NONE" >> chr_"$i"_opticall.sh
echo ". set_opticall_variables.sh" >> chr_"$i"_opticall.sh
echo "module load opticall" >> chr_"$i"_opticall.sh
echo "cd" '$RUNDIR/opticall_input' >> chr_"$i"_opticall.sh
echo '$EBROOTOPTICALL/opticall' "-in chr_"$i" -info" '$info' "-out ../opticall_output/chr_"$i"" >> chr_"$i"_opticall.sh 
done

# Create opticall jobs for chromosomes X,Y,MT
for i in {X,Y,MT}
do
echo "#!/bin/bash" >> chr_"$i"_opticall.sh
echo "#SBATCH --job-name=chr_"$i"_opticall" >> chr_"$i"_opticall.sh
echo "#SBATCH --mem 10gb" >> chr_"$i"_opticall.sh
echo "#SBATCH --time=24:00:00" >> chr_"$i"_opticall.sh
echo "#SBATCH --nodes 1" >> chr_"$i"_opticall.sh
#echo "#SBATCH --open-mode=append" >> chr_"$i"_opticall.sh
#echo "#SBATCH --export=NONE" >> chr_"$i"_opticall.sh
echo ". set_opticall_variables.sh" >> chr_"$i"_opticall.sh
echo "module load opticall" >> chr_"$i"_opticall.sh
echo "cd" '$RUNDIR/opticall_input' >> chr_"$i"_opticall.sh
echo '$EBROOTOPTICALL/opticall' "-in chr_"$i" -info" '$info' "-out ../opticall_output/chr_"$i"" -"$i" >> chr_"$i"_opticall.sh 
done
