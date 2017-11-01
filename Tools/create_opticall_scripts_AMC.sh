for i in {1..22}
do
echo "#!/bin/bash" >> chr_"$i"_AMC.sh
echo "#SBATCH --job-name=opticall_chr_"$i"_AMC" >> chr_"$i"_AMC.sh
echo "#SBATCH --mem 10gb" >> chr_"$i"_AMC.sh
echo "#SBATCH --time=24:00:00" >> chr_"$i"_AMC.sh
echo "#SBATCH --nodes 1" >> chr_"$i"_AMC.sh
#echo "#SBATCH --open-mode=append" >> chr_"$i"_AMC.sh
#echo "#SBATCH --export=NONE" >> chr_"$i"_AMC.sh
echo "module load opticall" >> chr_"$i"_AMC.sh
echo "cd /groups/umcg-weersma/tmp04/Michiel/GSA/opticall_input" >> chr_"$i"_AMC.sh
echo '$EBROOTOPTICALL/opticall' "-in chr_"$i" -info opticall_info_file_AMC.txt  -out ../opticall_output/chr_"$i"_AMC_opticall" >> chr_"$i"_AMC.sh 
done


for i in {X,Y,MT,XY}
do
echo "#!/bin/bash" >> chr_"$i"_AMC.sh
echo "#SBATCH --job-name=opticall_chr_"$i"_AMC" >> chr_"$i"_AMC.sh
echo "#SBATCH --mem 10gb" >> chr_"$i"_AMC.sh
echo "#SBATCH --time=24:00:00" >> chr_"$i"_AMC.sh
echo "#SBATCH --nodes 1" >> chr_"$i"_AMC.sh
#echo "#SBATCH --open-mode=append" >> chr_"$i"_AMC.sh
#echo "#SBATCH --export=NONE" >> chr_"$i"_AMC.sh
echo "module load opticall" >> chr_"$i"_AMC.sh
echo "cd /groups/umcg-weersma/tmp04/Michiel/GSA/opticall_input" >> chr_"$i"_AMC.sh
echo '$EBROOTOPTICALL/opticall' "-in chr_"$i" -info opticall_info_file_AMC.txt -out ../opticall_output/chr_"$i"_AMC_opticall -"$i"" >> chr_"$i"_AMC.sh
done
