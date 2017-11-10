# Author: Michiel Voskuil 

# Date: 2017/11/07

Set working directory and upload necessary scripts
---------------------------------------------------

All scripts are available in the Github GSA/Tools directory.

```
# Set run directory in which input file is stored
RUNDIR=/groups/umcg-weersma/tmp04/[your_RUNDIR]

mkdir $RUNDIR/scripts
```

Make sure the following scripts are in '$RUNDIR/scripts'
	- GS_to_OptiCall.sh
	- OptiCall_to_plink.py
	- HRC-1000G-check-bim.pl

Make sure the following scripts are in $RUNDIR
	- create_opticall_jobs.sh
	- create_HRC_jobs.sh


1.Load tools and set variables for SLURM environment / Calculon cluster UMCG
-------------------------------------------------------------------------

```
#!/bin/bash
#SBATCH --job-name=GSA.1
#SBATCH --output=GSA.1.out
#SBATCH --error=GSA.1.err
#SBATCH --time=40:00:00
#SBATCH --cpus-per-task=6
#SBATCH --mem=70gb
#SBATCH --nodes=1
#SBATCH --get-user-env=L

module load plink
module load opticall
module load Perl
module load Python
module load PerlPlus
module load Java
module load VCFtools

#####Set environment variables here

#Run directory in which input file is stored
RUNDIR=/groups/umcg-weersma/tmp04/[your_RUNDIR]

#Name of input file [final report table from Illumina Genome Studio Software]
input=GSA.final_report.txt

#Final report: column with snp name
s=1
#Final report: column with allele, p.e. [A/G]
a=23
#Final report: column with snp position
c=20
#Final report: column with chromosome
x=19
#Final report: column with illumina norm. intensity for allele 1
A=30
#Final report: column with illumina norm. intensity for allele 2
B=31
```

2. Convert GS output into optiCall input files per chromosome
-------------------------------------------------------------------------

```
cd $RUNDIR
mkdir $RUNDIR/opticall_input
bash scripts/GS_to_OptiCall.sh -i $input -s $s -a $a -c $c -x $x -A $A -B $B
for i in {1..22} {X,XY,Y,MT};
	do mv chr_$i $RUNDIR/opticall_input;
done
```

3. Use optiCall to call genotypes 
-------------------------------------------------------------------------
In order to call chromosomes seperately, which saves a lot of time, run this script seperately. 
Make sure the [info](https://opticall.bitbucket.io/#info-option-desc) file for opticall is in your $RUNDIR/opticall_input directory. 


```
# Set variables
RUNDIR=/groups/umcg-weersma/tmp04/[your_RUNDIR]
info=[my_info_file]

cd $RUNDIR/scripts
echo "export RUNDIR="$RUNDIR"" > set_opticall_variables.sh
echo "export info="$info"" >> set_opticall_variables.sh


mkdir $RUNDIR/opticall_output
cd $RUNDIR/scripts
bash create_opticall_jobs.sh
for i in {1..22} {X,Y,MT};
	do
	sbatch scripts/chr_"$i"_opticall.sh;
	done
```


4. Convert optiCall output into plink binary files
-------------------------------------------------------------------------
Mannualy set your $RUNDIR and $sexinfo
Make sure your [sex.info] file is stored in your $RUNDIR

```
#!/bin/bash
#SBATCH --job-name=GSA.2
#SBATCH --output=GSA.2.out
#SBATCH --error=GSA.2.err
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=10gb
#SBATCH --nodes=1
#SBATCH --get-user-env=L

module load plink
module load Python

# Set variables
RUNDIR=/groups/umcg-weersma/tmp04/[your_RUNDIR]
sexinfo=$RUNDIR/[your_sex.info]
name=[your_project_name i.e. 'GSA']

cd $RUNDIR
mkdir $RUNDIR/plink_files
rm $RUNDIR/scripts/chr_*_opticall.sh
rm $RUNDIR/opticall_input/chr_*
rm $RUNDIR/slurm-*

#Convert optiCall output into transposed plink files
for i in {1..22} {X,Y}; 
	do python scripts/OptiCall_to_plink.py opticall_output/chr_"$i".calls plink_files/chr_"$i".tped plink_files/chr_"$i".tfam "$i";
	done
	
# Convert transposed plink files into binary plink files. To avoid heterozygous haploid warnings that involve the X chromosome we use --set-hh-missing, since we are sure at this stage there are no gender errors in our .fam file yet.
for i in {1..22} {X,Y};
	do plink --tfile plink_files/chr_"$i" --recode --make-bed --set-hh-missing --out plink_files/chr_"$i" --allow-no-sex;
	done
	
# Remove large temporary files
for i in {1..22} {X,Y,MT}; 
	do rm plink_files/chr_"$i".tped plink_files/chr_"$i".tfam opticall_output/chr_"$i".calls opticall_output/chr_"$i".probs;
	done
	
# Merge all chromosomes 1-22, X and Y
cat plink_files/chr_X.fam > plink_files/$namepreQC.fam
cat plink_files/chr_{{1..22},X,Y}.bim > plink_files/$namepreQC.bim
(echo -en "\x6C\x1B\x01"; tail -qc +4 plink_files/chr{{1..22},X,Y}.bed) > plink_files/$namepreQC.bed

# Add sex to .fam file. Your [sex.info] file should be stored in your $RUNDIR
plink --bfile plink_files/$namepreQC --update-sex $sexinfo --make-bed --out plink_files/$namepreQC 

# Make directory for pca
mkdir $RUNDIR/pca
```


5. We make use of the Ricopili pipeline to run pre imputation QC and PCA on the Broad Cluster
---------------------------------------------------------------------------------------------

Transfer the files from the HPC cluster to Broad cluster

Open a new terminal window:
```
#Set variables
RUNDIR=/groups/umcg-weersma/tmp04/[your_RUNDIR]

for i in {bim,bed,fam};
	do scp lobby+calculon:$RUNDIR/plink_files/$namepreQC."$i" mvoskuil@login:/home/unix/mvoskuil; 
	done
```

6. Configurate Ricopili on Broad Cluster
----------------------------------------

```
ssh mvoskuil@login
```

First you have to install Ricopili on the Broad cluster. To do so, follow the detailed manual at [Ricopili installation](https://sites.google.com/a/broadinstitute.org/ricopili/installation) 
For now consider Ricopili installed in mvoskuil@login:/home/unix/mvoskuil/rp_bin
To run Ricopili you have to install PDF latex (TexLive). Unfortunately, this is too big to install in your home directory at the Broad cluster, so you have to install it in the hptmp folder. However, files in this folder will be deleted every 14 days.  
Follow the instruction on the TexLive website: [TexLive](https://www.tug.org/texlive/) 

```
# Set variables
date=[current_date_yyyymmdd]
RUNDIRBROAD=/broad/hptmp/mvoskuil/[your_RUNDIR_on_BROAD_cluster]
name=[your_project_name i.e. 'GSA']

mkdir $RUNDIRBROAD/texlive_$date
cd $RUNDIRBROAD/texlive_$date
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar xvzf install-tl-unx.tar.gz
cd install-tl-$date/
./install-tl
# Enter command:
D
# Enter command:
1
# Enter path:
$RUNDIRBROAD/texlive_$date
# Enter command:
R
# Enter command:
I
# TexLive will now start the installation; depending on the connection this may over two hours
```

After installed, add it to your path:
```
#Example
PATH=$RUNDIRBROAD/texlive_$date/bin/x86_64-linux:$PATH
```

Every time you login to the Broad cluster, configurate the pipeline:

```
# Use UGER job scheduler 
use UGER

# Add PDF Latex to your PATH
PATH=$RUNDIRBROAD/texlive_$date/bin/x86_64-linux:$PATH

# Configurate Ricopili
/home/unix/mvoskuil/rp_bin/rp_config
```

7. Perform QC with Ricopili 
---------------------------

Make sure you have configured Ricopili according to step 6.
Follow instructions at [Ricopili preimputation-QC](https://sites.google.com/a/broadinstitute.org/ricopili/preimputation-qc)

```
# Set variables
RUNDIRBROAD=/broad/hptmp/mvoskuil/[your_RUNDIR_on_BROAD_cluster]
name=[name_your_project i.e. 'GSA']

# Make output directory
mkdir $RUNDIRBROAD/$name_rp_out

# Copy your BINARY plink files into this directory
cp /home/unix/mvoskuil/$namepreQC.bed $RUNDIRBROAD/$name_rp_out
cp /home/unix/mvoskuil/$namepreQC.bim $RUNDIRBROAD/$name_rp_out
cp /home/unix/mvoskuil/$namepreQC.fam $RUNDIRBROAD/$name_rp_out

#Run the following command to run the QC:
cd $RUNDIRBROAD/$name_rp_out
preimp --dis ibd --pop mix --out $name
```

When prompted, edit the text file ending in $name.names using a text editor such as emacs, vim or nano
The number of lines in this file corresponds to the number of datasets in the working directory. Each line will have two columns where the second column is the root name of one PLINK file. 
Modify the first column to a 4 letter identifier for the file (ex: location data was obtained from. In here I use: 'PSIc').

```
# For this example I changed the identifier to PSIc [ParelSnoerIniative cohort]
nano ibd.names
```

Now you can run the pipeline
```
# Re-run the following command to run the QC
preimp --dis ibd --pop mix --out $name
```


7b. Perform QC with Ricopili: output
-----------------------------------

Look at the output files in the qc/ directory
PLINK files with -qc extension will be in your directory for each file in disease.names.
The naming of the files is disease_batch_popname_initials-qc.[bed,bim,fam], where disease is the 3 letter phenotype abbreviation specified by --dis, batch is the cohort identifier in disease.names, popname is the population name specified by --popname, and initials are the user's 2 letter initials specified in $HOME/ricopili.conf.
The file qc/disease_batch_popname_initials-qc.pdf.gz contains a summary of the qc that occurred for each batch including the parameters used.
For a more detailed description of the output files, see here: [Ricopili preimp Output-Files](https://sites.google.com/a/broadinstitute.org/ricopili/preimputation-qc#TOC-Output-Files)

8. Perform pre-imputation PCA to check for population stratification
--------------------------------------------------------------------

To assess relatedness and population stratification, the Ricopili pipeline only uses SNP passing the following filters:

	- SNPs are found in all datasets
	- MAF > 5%
	- HWE > 1.0e-04
	- MISSING RATE < 2%
	- no AT/GC SNPs (Strand Ambiguous SNPs)
	- no MHC (6:25-35Mb)
	- no Chr.8 inversion (8:7-13Mb)

Ricopili then prunes SNPs to ensure that there was little linkage disequilibrium between SNPs (R2 < 0.2).

	- LD - R2 < .2, 200 SNPs window: plink --indep-pairwise 200 100 0.2
	- repeat LD pruning with resulting LD pruned dataset
	- if still over 100K SNPs (rare) prune randomly

The resulting SNPs are used to assess common ancestry and population with Eigenstrat

Make sure you have your reference panel [bim,bed,fam] present in your $RUNDIRBROAD/pca directory. 

```
# Set referencepanel
reference=[ref panel p.e. pop_4pop_mix_SEQ or pop_euro_eur_SEQ]

# Make directory for your output:
mkdir $RUNDIRBROAD/pca_$name
cd $RUNDIRBROAD/pca_$name

# Copy (or link) your QC'ed files into this directory:
ln -s $RUNDIRBROAD/rp_out_$name/ibd_PSIc_mix_mv-qc.* $RUNDIRBROAD/pca_$name

# Run the following command to run the PCA script
pcaer --out $name ibd_PSIc_mix_mv-qc.bim $reference.bim 


# Make sure you also have put the corresponding .fam and .bed files in the directory

# Example for the Amsterdam (amca) cohort:
# pcaer --out amca-4pop-test ibd_amca_mix_mv-qc.bim pop_4pop_mix_SEQ.bim
```


8b. Perform pre-imputation PCA to check for population stratification: output
-----------------------------------------------------------------------------

Ricopili will output many files: a full decription is available here: [Ricopili PCA Output-Files](https://sites.google.com/a/broadinstitute.org/ricopili/pca#TOC-Output-Files)

We will look at the following files, since we have done the PCA per center;

	- PSIc-[ref].menv.mds.2ds.pdf
	

Visually inspect the plots and extract populations of interest.

```
# Example
awk '{ if ($4 <= -0.019) print $1,$2 }' PSIc-[ref].menv.mds_cov > 1kg_european_samples.txt
awk '{ if ($4 >= -0.0189 && $4 <= 0.005) print $1,$2 }' PSIc-[ref].menv.mds_cov > 1kg_admixed_samples.txt
```
Copy the files back to your local machine
```
# Set local folder
localfolder=[your_local_folder]
name=[name_your_project i.e. 'GSA']
scp mvoskuil@login:$RUNDIRBROAD/pca_$name/1kg_european_samples.txt $localfolder
scp mvoskuil@login:$RUNDIRBROAD/pca_$name/1kg_admixed_samples.txt $localfolder
```

Now, first we have to remove the 1000G IDs from the text files. Do this in whatever program you like. Also possible with Excel. 

Once removed the 1000G IDs from the .txt files, I'm left with files like this with contain GSA samples per ethnicity, per center:
```
# Example:
# GSA_european_samples.txt
# GSA_admixed_samples.txt
```

Now we copy these files back to the HPC cluster

Open a new terminal window
```

scp /Users/michielvoskuil/Documents/Werk/Promotie/GSA/redo/GSA_european_samples.txt lobby+calculon:$RUNDIR/pca
scp /Users/michielvoskuil/Documents/Werk/Promotie/GSA/redo/GSA_admixed_samples.txt lobby+calculon:$RUNDIR/pca

scp -3 mvoskuil@login:$RUNDIRBROAD/rp_out_$name/ibd_PSIc_mix_mv-qc.bim lobby+calculon:$RUNDIR/pca
scp -3 mvoskuil@login:$RUNDIRBROAD/rp_out_$name/ibd_PSIc_mix_mv-qc.bed lobby+calculon:$RUNDIR/pca
scp -3 mvoskuil@login:$RUNDIRBROAD/rp_out_$name/ibd_PSIc_mix_mv-qc.fam lobby+calculon:$RUNDIR/pca
```


9. Pre-imputation checking
--------------------------

We will 'clean' our data prior to imputation. All credits for this step go to Will Rayner: [#Checking](http://www.well.ox.ac.uk/~wrayner/tools/#Checking)

From this step onwards we will only work on the HPC cluster.
Make sure your have the script HRC-1000G-check-bim.pl in your $RUNDIR/scripts directory

```
# Set your RUNDIR and QC'ed file
RUNDIR=/groups/umcg-weersma/tmp04/[your_RUNDIR]
postQC=[your_post_qc_file]

# Load plink
module load plink

cd $RUNDIR/scripts
echo "export RUNDIR="$RUNDIR"" > set_HRC_variables.sh
echo "export postQC="$postQC"" >> set_HRC_variables.sh

cd $RUNDIR/pca

# Extract samples for QC'ed files based on ethnicity
plink --bfile $RUNDIR/pca/$postQC --keep $RUNDIR/pca/GSA_european_samples.txt --make-bed --out GSA-european
plink --bfile $RUNDIR/pca/$postQC --keep $RUNDIR/pca/GSA_admixed_samples.txt --make-bed --out GSA-admixed

# Create imputation directory
mkdir $RUNDIR/imputation
mkdir $RUNDIR/imputation/european
mkdir $RUNDIR/imputation/admixed
for i in {bim,bed,fam}; do
	mv $RUNDIR/pca/GSA-european."$i" $RUNDIR/imputation/european
	mv $RUNDIR/pca/GSA-admixed."$i" $RUNDIR/imputation/admixed;
	done

# Compile frequency file necessary for the preimputation checking script
plink --bfile $RUNDIR/imputation/european/GSA-european --freq --out $RUNDIR/imputation/european/GSA-european
plink --bfile $RUNDIR/imputation/admixed/GSA-admixed --freq --out $RUNDIR/imputation/admixed/GSA-admixed

# Download HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz from http://www.haplotype-reference-consortium.org/site 
# (Filesize ~673MB zipped and ~ 2.6GB unzipped)
cd $RUNDIR/imputation
wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
gzip -d HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz 

# Download script "HRC-1000G-check-bim.pl" developed by Will Rayner available at http://www.well.ox.ac.uk/~wrayner/tools/#Checking 
cd $RUNDIR/scripts
wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
unzip HRC-1000G-check-bim-v4.2.7.zip

# Script requires approximately 20GB memory to run. Suggest to run with scheduler.
cd $RUNDIR/scripts
bash $RUNDIR/scripts/create_HRC_jobs.sh
sbatch $RUNDIR/scripts/HRC-1000G-check-bim.admixed.sh 
sbatch $RUNDIR/scripts/HRC-1000G-check-bim.european.sh 

# Depending on the size of your data, this script takes approximately 8 minutes to run.
# The output will be a ready-to-use script "Run-plink.sh" to update your .bim files.
```

9b. Pre-imputation checking: modify your .bim files
--------------------------

```
# Set your local folder you would like to store the imputation-ready files
localfolder=[your_local_folder]

# Set your RUNDIR
RUNDIR=/groups/umcg-weersma/tmp04/[your_RUNDIR]

# Running the Run-plink.sh script will modify your .bim file according to the desired format for HRC imputation
module load plink
for i in {european,admixed};
	do cd $RUNDIR/imputation/"$i"
	bash Run-plink.sh;
	done
	
# This will create updated post qc binary plink files per CHR (i.e. all_european-qc-updated-chr1)

# We now need to remove the underscores in the sample IDs (.fam file), since plink merges FID and IID with underscore when converting to VCF
for i in {european,admixed};
	do cd $RUNDIR/imputation/"$i"
	for x in {1..23};
	do
	sed 's/_/-/g' GSA-"$i"-updated-chr"$x".fam > GSA-"$i"-updated-chr"$x"-pre-vcf.fam
	mv GSA-"$i"-updated-chr"$x".bed GSA-"$i"-updated-chr"$x"-pre-vcf.bed
	mv GSA-"$i"-updated-chr"$x".bim GSA-"$i"-updated-chr"$x"-pre-vcf.bim
	done
done

# Now we need to convert this to VCF prior to the upload to the Michigan Imputation Server
for i in {1..23}; do
	cd $RUNDIR/imputation/european
	plink --bfile GSA-european-updated-chr"$i"-pre-vcf --recode vcf --out GSA-european-updated-chr"$i"
	cd $RUNDIR/imputation/admixed
	plink --bfile GSA-admixed-updated-chr"$i"-pre-vcf --recode vcf --out GSA-admixed-updated-chr"$i";
	done
# Before we upload to the Michigan imputation server, we have to sort and zip the vcf files
# This takes approximately 5 minutes
module load VCFtools
for i in {european,admixed};
	do
	cd $RUNDIR/imputation/"$i"
	for x in {1..23};
	do
	vcf-sort GSA-"$i"-updated-chr"$x".vcf | bgzip -c > GSA-"$i"-updated-chr"$x".vcf.gz;
	done;
	done
```

Copy the files back to your local HD.
Open new terminal window:
```
for i in {european,admixed};
do
	mkdir "$i"
	for x in {1..23};
	do
	scp lobby+calculon:$RUNDIR/imputation/GSA-"$i"-updated-chr"$x".vcf.gz $localfolder/"$i";
	done;
done
```

