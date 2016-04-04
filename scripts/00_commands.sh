#!/usr/bin/env bash

# Bash commands used in order to fulfil the practice of quality evaluation of fastq files
# as part of the transcriptomic analysis class given by Selene Fernández in LANGEBIO
# in march-april 2016.

## Put the fastqc executable in a folder which is in the $PATH
## ln -s /Applications/FastQC.app/Contents/MacOS/fastqc ~/bin

# Initialise git repository
git init

# Organize working directory
mkdir -p data/trimmed
mkdir -p output/fastqc/trimmed
mkdir -p output/fastqc/raw
mkdir -p output/multiqc/trimmed
mkdir -p output/multiqc/raw
mkdir scripts
mkdir thirdP_software

# Extract data
tar -zxf FastQC_Short.tar.gz -C data/

# Individually compress files
gzip data/FastQC_Short/*

# Specify files to be ignored by git
echo 'data/FastQC_Short/*fastq.gz' > .gitignore
echo 'FastQC_Short.tar.gz' >> .gitignore

# Run fastqc on fastq files
# find FastQC_Short/ -name "*fastq" -exec fastqc -O output/ {} \;
fastqc -O output/fastqc/raw data/FastQC_Short/*fastq.gz

# Parse fastqc results through multiQC
# For more info, visit: http://multiqc.info/docs/
# Install multiQC

# conda create --name py2.7 python=2.7
# source activate py2.7
# conda install -c bioconda multiqc

# run multiQC
multiqc output/fastqc/raw -o output/multiqc/raw

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
for file in data/FastQC_Short/*fastq.gz; do
filename=$(basename $file)
java -jar thirdP_software/Trimmomatic-0.36/trimmomatic-0.36.jar SE -phred33 \
$file data/trimmed/$filename HEADCROP:11 SLIDINGWINDOW:4:30 MINLEN:50 \
ILLUMINACLIP:thirdP_software/Trimmomatic-0.36/adapters/TruSeq3-SE.fa:2:0:10
done

# Run fastqc on trimmed files
fastqc -O output/fastqc/trimmed data/trimmed/*fastq.gz

# Evaluate fastqc results with multiqc
multiqc output/fastqc/trimmed -o output/multiqc/trimmed

# Close anaconda environment
source deactivate

# Trinity commands
Trinity --seqType fq --SS_lib_type RF \
--left data/trinSeqs/Sp_log.left.fq.gz,data/trinSeqs/Sp_hs.left.fq.gz,data/trinSeqs/Sp_plat.left.fq.gz,data/trinSeqs/Sp_ds.left.fq.gz \
--right data/trinSeqs/Sp_log.right.fq.gz,data/trinSeqs/Sp_hs.right.fq.gz,data/trinSeqs/Sp_plat.right.fq.gz,data/trinSeqs/Sp_ds.right.fq.gz \
--CPU 2 --max_memory 1G --trimmomatic \
--output output/trinity
