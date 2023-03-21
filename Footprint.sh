#Identify footprint within atac-seq peaks
rgt-hint footprinting --atac-seq SampleName.bam SampleName_peaks.narrowPeak --output-location=./res --output-prefix=./res --organism=IWGSC
#Scan motif within footprint
rgt-motifanalysis matching --filter "database:PlantTFdb" --input-files ./res/res.bed --organism IWGSC --motif-dbs ~/rgtdata/motifs/PlantTFdb/ 
#Differential footprint analysis of sample A and B
rgt-hint differential --organism=IWGSC --bc --nc 4 --mpbs-files=../match/A-res_mpbs.bed,../match/B-res_mpbs.bed --reads-files=../bam/A.bam,../bam/B.bam --conditions=A,B --output-location=A.B

