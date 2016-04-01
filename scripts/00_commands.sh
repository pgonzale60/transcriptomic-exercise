#!/usr/bin/env bash

# Bash commands used in order to fulfil the practice of quality evaluation of fastq files
# as part of the transcriptomic analysis class given by Selene Fernández in LANGEBIO
# in march-april 2016.

## Put the fastqc executable in a folder which is in the $PATH
## ln -s /Applications/FastQC.app/Contents/MacOS/fastqc ~/bin

# Initialise git repository
git init

# Extract data
tar -zxvf FastQC_Short.tar.gz

# Individually compress files
gzip FastQC_Short/*

# Specify files to be ignored by git
echo 'FastQC_Short/*fastq.gz' > .gitignore
echo 'FastQC_Short.tar.gz' >> .gitignore

# Organize working directory
mkdir output
mkdir output/trimmed
mkdir scripts
mkdir thirdP_software

# Run fastqc on fastq files
# find FastQC_Short/ -name "*fastq" -exec fastqc -O output/ {} \;
fastqc -O output/ FastQC_Short/*fastq.gz

# Parse fastqc results through multiQC
# For more info, visit: http://multiqc.info/docs/
# Install multiQC

# cd thirdP_software
# git clone https://github.com/ewels/MultiQC.git
# cd MultiQC
# python setup.py install
# ../../

# run multiQC
multiqc output/ -o output/

# From this file one can see the following:
# All samples have a good mean Phred score for all positions
# Most sequences of all samples have an average Phred score of 38
# All samples have clear nucleotide composition bias up to the 11th position
# All samples have similar GC distribution
# In all samples nearly 1% of sequences have an N at their first position
# All sequences of all samples have 101 nts in length
# In all samples only 4% of sequences are duplicated; seems to be little or
# or no n-plication
# Most of the samples start having adapter content from th 52nd position;
# the highest percentage of sequences with adapter is 1.87%;
# it's truncated at the 88th position.

# Having this in mind, I'll select a trimming of 11 bases at the start of
# all sequences from all samples. They are single end runs, as Professor
# Selene specified. Since the encoding is Sanger / Illumina 1.9, I'll use
# phred33. Cut Illumina adapters. A sliding window (size 4) with mean of
# at least of 30. And discard sequences shorter than 50 nts.


# Trimm files according to fastqc results
for file in FastQC_Short/*fastq.gz; do
filename=$(basename $file)
java -jar thirdP_software/Trimmomatic-0.36/trimmomatic-0.36.jar SE -phred33 \
$file output/trimmed/$filename LEADING:11 SLIDINGWINDOW:4:30 MINLEN:50
done