# Author: Michiel Voskuil 

# Date: 2017/10/31

1. Load tools in HPC environment
--------------------------------

```
module load plink
module load opticall
module load Perl
module load Python
module load PerlPlus
module load Java
module load VCFtools
```



2. Convert GS output into optiCall input file
--------------------------------

IDAT files are read by GS and converted into normalised intensities per variant. We use opticall for the genotype calling so we first need to convert the file.

```
#s => column containing snps name
#a => column containing allele, p.e [A/G]
#c => column containing snp position
#x => column containing chromosome 
#A => column containing illumina norm. intensity for allele 1
#B => column containing illumina norm. intensity for allele 2
```
```
bash GS_to_OptiCall.sh -i $input -s 1 -a 23 -c 20 -x 19 -A 30 -B 31
```



3. Run optiCall to call genotypes
---------------

In this example, we call AMC samples separately because their intensities differ from the other centers.

```
bash create_opticall_scripts_AMC.sh 
bash create_opticall_scripts_others.sh

for i in {1..22}; do sbatch chr_"$i"_others.sh; done
for i in {1..22}; do sbatch chr_"$i"_AMC.sh; done
for i in {X,Y,MT,XY}; do sbatch chr_"$i"_others.sh; done
for i in {X,Y,MT,XY}; do sbatch chr_"$i"_AMC.sh; done
```
WARNING MAY 24th. Chromosome MT fail to get called by optiCall. Reason currently unknown, but for now we will continue without MT SNPs anyway.



4. Convert into binary plink files
---------------------------

optiCall will generate files like: chr_1_others_opticall.calls and chr_1_others_opticall.probs.
We will use the .calls files to make .tped and .tfam PLINK files. The script "new_opticall_2_plink_with_position.py" does this automagically per chromosome.

```
for i in {amca,vumc,mumc,umcg,umcn,umcu,emcr,lumc}; do mkdir ./per_center/"$i"; done

for i in {1..22}; do python new_opticall_2_plink_with_position.py chr_"$i"_AMC_opticall.calls chr_"$i"_amca.tped chr_"$i"_amca.tfam "$i"; done
for i in {X,Y,XY}; do python new_opticall_2_plink_with_position.py chr_"$i"_AMC_opticall.calls chr_"$i"_amca.tped chr_"$i"_amca.tfam "$i"; done

```
Transform .tped and .tfam files into binary plink files. 

```
center=umcu
for i in {1..22} {X,XY,Y}; do plink --tfile chr_"$i"_others --make-bed --keep $center.ids --out per_center/$center/chr_"$i"_$center --allow-no-sex;
done 
center=umcn
for i in {1..22} {X,XY,Y}; do plink --tfile chr_"$i"_others --make-bed --keep $center.ids --out per_center/$center/chr_"$i"_$center --allow-no-sex;
done 
center=vumc
for i in {1..22} {X,XY,Y}; do plink --tfile chr_"$i"_others --make-bed --keep $center.ids --out per_center/$center/chr_"$i"_$center --allow-no-sex;
done 
center=lumc
for i in {1..22} {X,XY,Y}; do plink --tfile chr_"$i"_others --make-bed --keep $center.ids --out per_center/$center/chr_"$i"_$center --allow-no-sex;
done 
center=mumc
for i in {1..22} {X,XY,Y}; do plink --tfile chr_"$i"_others --make-bed --keep $center.ids --out per_center/$center/chr_"$i"_$center --allow-no-sex;
done 
center=emcr
for i in {1..22} {X,XY,Y}; do plink --tfile chr_"$i"_others --make-bed --keep $center.ids --out per_center/$center/chr_"$i"_$center --allow-no-sex;
done 
center=umcg
for i in {1..22} {X,XY,Y}; do plink --tfile chr_"$i"_others --make-bed --keep $center.ids --out per_center/$center/chr_"$i"_$center --allow-no-sex;
done 
```

Merge all chromosomes into one binary plink file per center.

```
for i in {amca,vumc,mumc,umcg,umcn,umcu,emcr,lumc};
do
cd /groups/umcg-weersma/tmp04/Michiel/GSA/plink/per_center/"$i"
```
```
echo "chr_2_"$i"" > merge.list."$i"
echo "chr_3_"$i"" >> merge.list."$i"
echo "chr_4_"$i"" >> merge.list."$i"
echo "chr_5_"$i"" >> merge.list."$i"
echo "chr_6_"$i"" >> merge.list."$i"
echo "chr_7_"$i"" >> merge.list."$i"
echo "chr_8_"$i"" >> merge.list."$i"
echo "chr_9_"$i"" >> merge.list."$i"
echo "chr_10_"$i"" >> merge.list."$i"
echo "chr_11_"$i"" >> merge.list."$i"
echo "chr_12_"$i"" >> merge.list."$i"
echo "chr_13_"$i"" >> merge.list."$i"
echo "chr_14_"$i"" >> merge.list."$i"
echo "chr_15_"$i"" >> merge.list."$i"
echo "chr_16_"$i"" >> merge.list."$i"
echo "chr_17_"$i"" >> merge.list."$i"
echo "chr_18_"$i"" >> merge.list."$i"
echo "chr_19_"$i"" >> merge.list."$i"
echo "chr_20_"$i"" >> merge.list."$i"
echo "chr_21_"$i"" >> merge.list."$i"
echo "chr_22_"$i"" >> merge.list."$i"
echo "chr_X_"$i"" >> merge.list."$i"
echo "chr_XY_"$i"" >> merge.list."$i"
echo "chr_Y_"$i"" >> merge.list."$i";
done
```
```
for i in {amca,vumc,mumc,umcg,umcn,umcu,emcr,lumc};
do
cd ./per_center/"$i"
plink --bfile chr_1_"$i" --merge-list merge.list."$i" --make-bed --out chr_1-22-XY_"$i" --allow-no-sex;
done
```

Add sex to .fam file. Sex info is stored in /groups/umcg-weersma/tmp04/Michiel/GSA/plink/sex.info
```
for i in {amca,vumc,mumc,umcg,umcn,umcu,emcr,lumc};
do
cd /groups/umcg-weersma/tmp04/Michiel/GSA/plink/per_center/"$i"
plink --bfile chr_1-22-XY_"$i" --update-sex ../../sex.info --out chr_1-22-XY_"$i"_sex --make-bed
rm chr_1-22-XY_"$i".*
mv chr_1-22-XY_"$i"_sex.bed chr_1-22-XY_"$i".bed
mv chr_1-22-XY_"$i"_sex.fam chr_1-22-XY_"$i".fam
mv chr_1-22-XY_"$i"_sex.bim chr_1-22-XY_"$i".bim;
done
```

5. We make use of the Ricopili pipeline to run pre imputation QC and PCA on the Broad Cluster
---------------------------------------------------------------------------------------------

Transfer the files from the HPC cluster to Broad cluster
```
for i in {amca,vumc,mumc,lumc,umcg,umcn,umcu,emcr}; do scp -3 lobby+calculon:./per_center/"$i"/chr_1-22-XY_"$i".* mvoskuil@login:/home/unix/mvoskuil/plink_files; done
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
mkdir /broad/hptmp/mvoskuil/texlive_[month]
cd /broad/hptmp/mvoskuil/texlive_[month]
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar xvzf install-tl-unx.tar.gz
cd install-tl-[yyyymmdd]/
./install-tl
# Enter command:
D
# Enter command:
1
# Enter path:
/broad/hptmp/mvoskuil/texlive_[month]
# Enter command:
R
# Enter command:
I
# TexLive will now start the installatio; depending on the connection this may over two hours


```
After installed, add it to your path:
```
#Example
PATH=/broad/hptmp/mvoskuil/texlive_nov2017/bin/x86_64-linux:$PATH

```

Every time you login to the Broad cluster, configurate the pipeline:

```
# Use UGER job scheduler 
use UGER

# Add PDF Latex to your PATH
PATH=/broad/hptmp/mvoskuil/texlive_nov2017/bin/x86_64-linux:$PATH

# Configurate Ricopili
./rp_config
```

7. Perform QC with Ricopili 
---------------------------

Follow instructions at [Ricopili preimputation-QC](https://sites.google.com/a/broadinstitute.org/ricopili/preimputation-qc)

Make directory for your output:

```
mkdir ./[name]_rp_out/
```

Copy your BINARY plink files into this directory:

```
cp my.input.bed [name]_rp_out/
cp my.input.bim [name]_rp_out/
cp my.input.fam [name]_rp_out/
```

Run the following command to run the QC:
```
preimp	--dis ibd --pop mix --out [name]
```

--dis is a required option that must be a 3 letter abbreviation for your phenotype. In here, I use ibd, which stands for inflammatory bowel disease. 

--pop stands for the ancestry of the samples in your dataset. For example, "eur" stands for European. There's also "asn" for Asian, "aam" for African-American, "afr" for African, "his" for Hispanic. 
* this is used only for naming conventions and will have no effect on genotypes / SNP selections. you are free to use any name, but it's helpful to restrict on these names here. if unclear use "mix".

--out is a required option that is the output name for the project (only used to identify this pipeline run in the log files and in the queue-jobs) I used the following abbrevations per center: amca, emcr, vumc, lumc, umcg, umcn, umcu, mumc.

When prompted, edit the text file ending in *.names using a text editor such as emacs, vim or nano


The number of lines in this file corresponds to the number of datasets in the working directory. Each line will have two columns where the second column is the root name of one PLINK file. Modify the first column to a 4 letter identifier for the file (ex: location data was obtained from).
 

```
nano ibd.names
``` 
 
Re-run the following command to run the QC:
```
preimp	--dis ibd --pop mix --out [name]
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



Make directory for your output:

```
mkdir ./pca_[name]
```

Copy (or link) your QC'ed files into this directory:

```
ln -s ../bfile-qc.* ./pca_[name]
```

Run the following command to run the PCA script:
```
pcaer --out [output_name] [bfile1-qc].bim
```

If you want to run the PCA with multiple files, for example with 1000G references populations, run a command like this:
```
pcaer --out [output_name] [bfile1-qc].bim [bfile_ref_populations].bim 

# Example for the Amsterdam (amca) cohort:
pcaer --out amca-4pop-test ibd_amca_mix_mv-qc.bim pop_4pop_mix_SEQ.bim
```

Make sure you also have put the corresponding .fam and .bed files in the directory


8b. Perform pre-imputation PCA to check for population stratification: output
-----------------------------------------------------------------------------

Ricopili will output many files: a full decription is available here: [Ricopili PCA Output-Files](https://sites.google.com/a/broadinstitute.org/ricopili/pca#TOC-Output-Files)



We will look at the following files, since we have done the PCA per center;

	- amca-4pop-test.menv.mds.2ds.pdf
	- emcr-4pop-test.menv.mds.2ds.pdf
	- lumc-4pop-test.menv.mds.2ds.pdf
	- mumc-4pop-test.menv.mds.2ds.pdf
	- umcg-4pop-test.menv.mds.2ds.pdf
	- umcn-4pop-test.menv.mds.2ds.pdf
	- umcu-4pop-test.menv.mds.2ds.pdf
	- vumc-4pop-test.menv.mds.2ds.pdf

Visually inspect the plots and extract populations of interest.

```
# amca
awk '{ if ($4 <= -0.019) print $1,$2 }' amca-4pop-test.menv.mds_cov > amca-1kg_european_samples.txt
awk '{ if ($4 >= -0.0189 && $4 <= 0.005) print $1,$2 }' amca-4pop-test.menv.mds_cov > amca-1kg_admixed_samples.txt

#emcr
awk '{ if ($4 <= -0.018) print $1,$2 }' emcr-4pop-test.menv.mds_cov > emcr-1kg_european_samples.txt
awk '{ if ($4 >= -0.0179 && $4 <= 0.01 ) print $1,$2 }' emcr-4pop-test.menv.mds_cov > emcr-1kg_admixed_samples.txt

#lumc
awk '{ if ($4 <= -0.016 && $5 >= 0.00) print $1,$2 }' lumc-4pop-test.menv.mds_cov > lumc-1kg_european_samples.txt
awk '{ if ($4 >= -0.0159 && $4 <= 0.005) print $1,$2 }' lumc-4pop-test.menv.mds_cov > lumc-1kg_admixed_samples.txt

#mumc
awk '{ if ($4 <= -0.01) print $1,$2 }' mumc-4pop-test.menv.mds_cov > mumc-1kg_european_samples.txt
awk '{ if ($4 >= -0.009 && $4 <= 0.01) print $1,$2 }' mumc-4pop-test.menv.mds_cov > mumc-1kg_admixed_samples.txt

#umcg
awk '{ if ($4 <= -0.004) print $1,$2 }' umcg-4pop-test.menv.mds_cov > umcg-1kg_european_samples.txt
awk '{ if ($4 >= -0.003 && $4 <= 0.01) print $1,$2 }' umcg-4pop-test.menv.mds_cov > umcg-1kg_admixed_samples.txt

#umcn
awk '{ if ($4 <= -0.015) print $1,$2 }' umcn-4pop-test.menv.mds_cov > umcn-1kg_european_samples.txt
awk '{ if ($4 >= -0.0149 && $4 <= 0.01) print $1,$2 }' umcn-4pop-test.menv.mds_cov > umcn-1kg_admixed_samples.txt

#umcu
awk '{ if ($4 <= -0.011) print $1,$2 }' umcu-4pop-test.menv.mds_cov > umcu-1kg_european_samples.txt
awk '{ if ($4 >= -0.010 && $4 <= 0.00) print $1,$2 }' umcu-4pop-test.menv.mds_cov > umcu-1kg_admixed_samples.txt

#vumc
awk '{ if ($4 <= -0.017) print $1,$2 }' vumc-4pop-test.menv.mds_cov > vumc-1kg_european_samples.txt
awk '{ if ($4 >= -0.0169 && $4 <= 0.005) print $1,$2 }' vumc-4pop-test.menv.mds_cov > vumc-1kg_admixed_samples.txt
```


Copy to local machine:
```
for i in {amca,vumc,lumc,emcr,mumc,umcn,umcu,umcg};
do
scp lobby+calculon:/groups/umcg-weersma/tmp04/Michiel/GSA/pca/"$i"/"$i"-1kg_european_samples.txt /Users/michielvoskuil/Documents/Werk/Promotie/GSA/IDAT_pca
scp lobby+calculon:/groups/umcg-weersma/tmp04/Michiel/GSA/pca/"$i"/"$i"-1kg_admixed_samples.txt /Users/michielvoskuil/Documents/Werk/Promotie/GSA/IDAT_pca;
done
```

Now, first we have to remove the 1000G IDs from the text files. Do this with whatever program you like. Also possible with Excel. 


Once removed the 1000G IDs from the .txt files, I'm left with files like this with contain GSA samples per ethnicity, per center:
```
# Example
amca_european_samples.txt
amca_admixed_samples.txt
```
Combine all samples into text file per ethnicity:

```
# European samples:
cat amca_european_samples.txt emcr_european_samples.txt lumc_european_samples.txt mumc_european_samples.txt umcn_european_samples.txt umcu_european_samples.txt vumc_european_samples.txt umcg_european_samples.txt > all_european_samples_post_qc.txt

#Admixed samples:
cat amca_admixed_samples.txt emcr_admixed_samples.txt lumc_admixed_samples.txt mumc_admixed_samples.txt umcn_admixed_samples.txt umcu_admixed_samples.txt vumc_admixed_samples.txt umcg_admixed_samples.txt > all_admixed_samples_post_qc.txt
```



In the PSI IBD cohort we can notice:
3534 European samples post QC
154 Admixed samples post QC


Copy back to HPC cluster: 

```
for i in {amca,vumc,lumc,emcr,mumc,umcn,umcu,umcg};
do
scp /Users/michielvoskuil/Documents/Werk/Promotie/GSA/IDAT_pca/"$i"_european_samples.txt lobby+calculon:/groups/umcg-weersma/tmp04/Michiel/GSA/pca/"$i"
scp /Users/michielvoskuil/Documents/Werk/Promotie/GSA/IDAT_pca/"$i"_admixed_samples.txt lobby+calculon:/groups/umcg-weersma/tmp04/Michiel/GSA/pca/"$i";
done
```

```
scp /Users/michielvoskuil/Documents/Werk/Promotie/GSA/IDAT_pca/all_european_samples_post_qc.txt lobby+calculon:/groups/umcg-weersma/tmp04/Michiel/GSA/pca
scp /Users/michielvoskuil/Documents/Werk/Promotie/GSA/IDAT_pca/all_admixed_samples_post_qc.txt lobby+calculon:/groups/umcg-weersma/tmp04/Michiel/GSA/pca
```

Now we can extract these samples from the PLINK binary files and merge all centers:

```
mkdir /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/
cd /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/
for i in {amca,vumc,lumc,emcr,mumc,umcn,umcu,umcg}; 
do
ln -s /groups/umcg-weersma/tmp04/Michiel/GSA/pre_imp_qc/ibd_"$i"_mix_mv-qc.bed .
ln -s /groups/umcg-weersma/tmp04/Michiel/GSA/pre_imp_qc/ibd_"$i"_mix_mv-qc.bim .
ln -s /groups/umcg-weersma/tmp04/Michiel/GSA/pre_imp_qc/ibd_"$i"_mix_mv-qc.fam .;
done
```
```
echo "ibd_vumc_mix_mv-qc" > merge.list
echo "ibd_emcr_mix_mv-qc" >> merge.list
echo "ibd_lumc_mix_mv-qc" >> merge.list
echo "ibd_mumc_mix_mv-qc" >> merge.list
echo "ibd_umcn_mix_mv-qc" >> merge.list
echo "ibd_umcu_mix_mv-qc" >> merge.list
echo "ibd_umcg_mix_mv-qc" >> merge.list
```
```
cd /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/

plink --bfile ibd_amca_mix_mv-qc --merge-list merge.list --keep ../all_european_samples_post_qc.txt --make-bed --out all_european-qc
plink --bfile ibd_amca_mix_mv-qc --merge-list merge.list --keep ../all_admixed_samples_post_qc.txt --make-bed --out all_admixed-qc
```

9. Pre-imputation checking
--------------------------

We will 'clean' our data prior to imputation. All credits for this step go to Will Rayner: [#Checking](http://www.well.ox.ac.uk/~wrayner/tools/#Checking)

First we need to compile a frequency file:
```
for i in {european,admixed};
do
plink --bfile /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/all_"$i"-qc --freq --out all_"$i"-qc;
done
```

Download  HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz from http://www.haplotype-reference-consortium.org/site 
(Filesize ~640MB zipped and ~ 2.6GB unzipped)
```
wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
gzip -d HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz 
```

Download script "HRC-1000G-check-bim.pl" ('Tools') developed by Will Rayner at http://www.well.ox.ac.uk/~wrayner/tools/#Checking 
```
wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
unzip HRC-1000G-check-bim-v4.2.7.zip
```

Script requires approximately 20GB memory to run. Suggest to run with scheduler.

```
# Usage: perl HRC-1000G-check-bim.pl -b <bim file> -f <Frequency file> -r <Reference panel> -g -p <population>

# Below I have prepared a script which will create jobs. Just modify your input file names in the script "create_HRC_jobs.sh" ('Tools').

bash create_HRC_jobs.sh


for i in {european,admixed}; do
sbatch HRC-1000G-check-bim."$i".sh;
done 
```

9b. Pre-imputation checking: output
--------------------------

Depending on the size of your data, this script takes approximately 8 minutes to run.
The output will be a ready-to-use script "Run-plink.sh" to update your .bim files.

Running this script will modify your .bim file according to the desired format for HRC imputation

```
bash Run-plink.sh
```

This will create updated post qc binary plink files per CHR (i.e. all_european-qc-updated-chr1)

We now need to remove the underscores in the sample IDs (.fam file), since plink merges FID and IID with underscore when converting to VCF

```
cd /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/check_files_HRC
for i in {european,admixed};
do
	for x in {1..23};
	do
	sed 's/_/-/g' all_"$i"-qc-updated-chr"$x".fam > all_"$i"-qc-updated-chr"$x"-pre-vcf.fam
	done
done

cd /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/check_files_HRC
for i in {european,admixed};
do
	for x in {1..23};
	do
	cp all_"$i"-qc-updated-chr"$x"-pre-vcf.fam ../imputation_ready
	cp all_"$i"-qc-updated-chr"$x".bim ../imputation_ready/all_"$i"-qc-updated-chr"$x"-pre-vcf.bim
	cp all_"$i"-qc-updated-chr"$x".bed ../imputation_ready/all_"$i"-qc-updated-chr"$x"-pre-vcf.bed
	done
done
```

Now we need to convert this to VCF prior to the upload to the Michigan Imputation Server

```
cd /groups/umcg-weersma/tmp04/Michiel/GSA/imputation/imputation_ready

# European
for i in {1..23};
do
module load plink
plink --bfile all_european-qc-updated-chr"$i"-pre-vcf --recode vcf --out all_european-qc-updated-chr"$i"
rm all_european-qc-updated-chr"$i"-pre-vcf.*;
done

# Admixed
for i in {1..23};
do
module load plink
plink --bfile all_admixed-qc-updated-chr"$i"-pre-vcf --recode vcf --out all_admixed-qc-updated-chr"$i"
rm all_admixed-qc-updated-chr"$i"-pre-vcf.*;
done
```

Before we upload to the Michigan imputation server, we have to sort and zip the vcf files:
```
# This step takes approximately 5 minutes

module load VCFtools
for i in {european,admixed};
do
for x in {1..23};
do
vcf-sort all_"$i"-qc-updated-chr"$x".vcf | bgzip -c > all_"$i"-qc-updated-chr"$x".vcf.gz;
done;
done
```

Copy imputation ready files to HD as back-up
```
for i in {european,admixed};
do
	for x in {1..23};
	do
	scp lobby+calculon:/groups/umcg-weersma/tmp04/Michiel/GSA/imputation/imputation_ready/all_"$i"-qc-updated-chr"$x".vcf.gz /Volumes/Michiel/IDAT;
	done;
done
```


10. Upload files to Michigan imputation server and run imputation.
----------------------------------------------------------------------------------------------------

Follow the detailed instructions on their website: [Michigan Imputation Server](https://imputationserver.sph.umich.edu/index.html)
Make sure you download your results within a week, or your results will be deleted from their server.

11. Visualise and check imputation results. 
-------------------------------------------

We will now check the imputation results, also via a script developed by Will Rayner: [#IC](http://www.well.ox.ac.uk/~wrayner/tools/Post-Imputation.html)

First unzip all results with the password sent to you by email from Michigan server:
```
for i in {1..22}; do
	unzip chr_"$i".zip;
	done
```

The current version requires only the first 8 columns from the VCF output file, use the "vcfparse.pl" script ('Tools') to extract them.


```
# This takes 6-7 hours per chromosome, so best do submit this as a job to the scheduler. 
# The script takes all VCFs in a folder, so best to create separate folders per input (per CHR). 

for i in {1..22}; do
	mkdir ./chr"$i"
	mv chr"$i".dose.vcf.gz ./chr"$i";
	done
```

Usage:
```
# ./vcfparse.pl -d <directory of VCFs> -o <outputname>  [-g]
# - d The path to the directory containing imputed VCF files.
# -o Specifies the output directory name, will be created if it doesn't exist.
# -g Flag to specify the output files are gzipped.
# The program will not overwrite files of the same name and this process will be required for each imputed data set.
```

Create jobs:
```
bash create_cut_jobs.sh
```

Submit jobs to scheduler:
```
for i in {1..22}; do
	sbatch cut_eur_chr"$i".sh;
	done
```

The output files will look like chr"$i".dose.vcf.cut.gz.
With these 'cutted' vcf files we can do the actual post imputation check. We make use of a script developped by Will Rayner ic.pl ('Tools'). The script requires a few dependencies, please see [a link](http://www.well.ox.ac.uk/~wrayner/tools/Post-Imputation.html)


Usage:
```
ic -d <directory> -r <Reference panel> [-h | (-g -p <population> )]  [-f <mappings file>] [-o <output directory>]

# Options:
# -d 			Top level directory containing either one set of per chromosome files, or multiple directories each containing a set of per chromosome files
# 				This directory will be searched recursively for files matching the required formats
# 				Files may be gzipped or uncompressed
# -f --file		Mapping file of directory name to cohort name, optional but recommended when using multiple data sets
# -r --ref		Reference panel	Reference panel summary file, either 1000G or the tab delimited HRC (r1 or r1.1)
# -h --hrc		Flag to indicate Reference panel file is HRC, defaults to HRC if no option is given
# -g --1000g 	Flag to indicate Reference panel file is 1000G
# -p --pop		Population to check allele frequency against
# 				Applies to 1000G only, defaults to ALL if not supplied. 
#				Options available ALL, EUR, AFR, AMR, SAS, EAS
# -o 			Output Directory: Top level directory to contain all the output folders

#Mapping file

# The mapping file should consist of two columns:
# The directory name (optionally including the path)
# The name you wish to use for the output files

# Example mapping file:
# /full/path/to/folder/1	MyStudy1
# ./path/to/folder/2		MyStudy2
# folder3                 	MyStudy3



If no mapping file is supplied the program will attempt to determine a unique set of names from the top level directory and/or sub-directories supplied with the -d option, this may or may not end up with unique folders for each output, if not the program will start an auto-increment on the file names within the directory (these will be consistent across each data set).
One advantage of using a mapping file is the data sets provided need not be all in the same base path.
```

Create jobs:

```
bash create_IC_jobs.sh
```

Submit jobs to scheduler:

```
sbatch IC_admixed_to_HRC_AMR.sh
sbatch IC_admixed_to_HRC_EUR.sh
sbatch IC_european_to_HRC_EUR.sh
```

11. Visualise and check imputation results: output
-------------------------------------------------


These jobs will output many files, most interesting where all results are summarized is the summaryOutput/STUDY.html 











