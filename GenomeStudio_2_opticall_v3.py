#This script will convert the my_report.txt file to optiCall input files per chromosome
#To run this script: python GenomeStudio_2_opticall_v3.py my_report.txt 


#!/bin/python

import sys
import re
from collections import defaultdict
count=0
snp_info={}
chromosomes=["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","X","Y","MT"]
def snp_alleles():
	input_file= open (sys.argv[1],'r')
	with open(sys.argv[1]) as input_file:
		next(input_file)
		for i, line in enumerate(input_file):
			each_line=line.split('\t')
			snp_id=each_line[0]
			allele_string=each_line[1]
			#print allele_string[1]
			alleles= allele_string[1] + allele_string[3]
			A_allele=allele_string[1]
			B_allele=allele_string[3]
			snp_info[snp_id]=alleles

def illumina_2_opticall ():
	input_file2= open (sys.argv[2],'r')
	with open(sys.argv[2]) as input_file2:
		for i, line in enumerate(input_file2):
			info=line.split('\t')
			if info[1]=="Chr":
				#print "TRUE"
				snp=info[0]
				pos=info[2]
				al="Allele"
				#intesities=info[3:]
				end=len(info)
				for my_chr in chromosomes:
					with open("chr_%s.txt" % my_chr, "w" ) as f:
						f.write ('%s' '\t' '%s' '\t' '%s' % (snp, pos, al))
						x=3
						y=6
						while y<=end:
							trio=info[x:y]
							A=trio[1]
							B=trio[2]
							f.write ('\t' '%s' '\t' '%s' % (A,B))
							x=y
							y=x+3
			else:
				 #for my_chr in chromosomes:
				with open("chr_%s.txt" % info[1], "a" ) as f:
							#if info[1]==my_chr:
					snp=info[0]
					if snp == "rs2861203":
						continue
					pos=info[2]
					al=snp_info.get(snp)
					x=3
					y=6
					f.write ('%s' '\t' '%s' '\t' '%s' % (snp, pos, al))
					while y<=end:
						trio=info[x:y]
						A=trio[1]
						B=trio[2]
						f.write ('\t' '%s' '\t' '%s' % (A,B))
						x=y
						y=x+3
snp_alleles();
illumina_2_opticall();
