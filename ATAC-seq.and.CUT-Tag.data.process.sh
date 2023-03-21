##For ATAC-seq and CUT&Tag data
#quality control
fastp -i SampleName_R1.fq.gz -I SampleName_R2.fq.gz -o clean.SampleName_R1.fq.gz -O clean.SampleName_R2.fq.gz --detect_adapter_for_pe -w 4 --compression 9 -h SampleName.html -j SampleName.json

#mapping using bwa
bwa mem -M -t 4 IWGSC.bwa.index clean.SampleName_R1.fq.gz clean.SampleName_R2.fq.gz > SampleName.sam
samtools view -@ 4 -bS SampleName.sam | samtools sort -@ 4 - -o SampleName.bam

#filter reads
samtools view -@ 4 -bS -F 1804 -f 2 -q 30 SampleName.bam | samtools sort -@ 4 -o SampleName.filtered.bam -

#remove PCR duplicates
java -XX:ParallelGCThreads=4 -Xmx40g -jar picard.jar MarkDuplicates -I SampleName.filtered.bam -O SampleName.rmdup.bam -M SampleName.rmdup.metrics.txt -REMOVE_DUPLICATES true

#convert bam file to bigwig file
bamCoverage -p 4 -bs 10 --effectiveGenomeSize 14600000000 --normalizeUsing RPKM --smoothLength 50 -b SampleName.rmdup.bam -o SampleName.bw

#peak calling for ATAC-seq data
macs2 callpeak -t SampleName.rmdup.bam -q 0.05 -f BAMPE --nomodel --extsize 200 --shift -100 -g 14600000000 -n SampleName
#peak calling for CUT&Tag narrow peak
macs2 callpeak -t SampleName.rmdup.bam -p 1e-3 -f BAMPE -g 14600000000 --keep-dup all -n SampleName
#peak calling for CUT&Tag broad peak
macs2 callpeak -t SampleName.rmdup.bam  -f BAMPE -g 14600000000 --keep-dup all -n SampleName --broad --broad-cutoff 0.05

