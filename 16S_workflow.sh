#!/bin/bash

cd soft
./JarMaker.sh AlienTrimmer.java #ca permet de créer le AlienTrimmer.jar
java -jar AlienTrimmer.jar
cd ..

mkdir Cleaning-Trimming-outputs

gunzip *.gz

for i in $(ls fastq/*_R1.fastq);do
echo $i; 
nameR1="$i";
echo $nameR1;
nameR2=$(echo $i | sed s/R1/R2/g);
echo $nameR2;

#fastqc $nameR1 $nameR2
java -jar ./soft/AlienTrimmer.jar -if $nameR1 -ir $nameR2 -c ./databases/contaminants.fasta -q 20 -of ./Cleaning-Trimming-outputs/$(basename $nameR1) -or ./Cleaning-Trimming-outputs/$(basename $nameR2)
done

#Merging

mkdir vsearch_outputs

for i in $(ls Cleaning-Trimming-outputs/*_R1.fastq);do
vsearch --fastq_mergepairs $i --reverse ${i:0:-9}"_R2.fastq" --fastqout ./vsearch_outputs/$(basename ${i:0:-9})".fasta" --label_suffix $(basename ${i:0:-9})
done

for i in $(ls vsearch_outputs/*.fasta);do
cat $i | sed -e 's/ //g' > vsearch_outputs/amplicon.fasta
done

#les 4 étapes de la clusterisation

vsearch --derep_fulllength ./vsearch_outputs/amplicon.fasta --sizeout --minuniquesize 10 --output ./vsearch_outputs/amplicon_dedupliq.fasta

vsearch --uchime_denovo ./vsearch_outputs/amplicon.fasta --nonchimeras  ./vsearch_outputs/amplicon_nonchimeras.fasta

vsearch --id 0.97 --cluster_size ./vsearch_outputs/amplicon_nonchimeras.fasta --centroids ./vsearch_outputs/centroids.fasta --relabel "OTU_"

vsearch --usearch_global ./vsearch_outputs/amplicon_nonchimeras.fasta  --otutabout  ./vsearch_outputs/merged_otutabout --db ./vsearch_outputs/centroids.fasta --id 0.97

#annotation

vsearch --usearch_global ./vsearch_outputs/centroids.fasta --db ./databases/mock_16S_18S.fasta --id 0.90 --top_hits_only --userfields query+target --userout ./vsearch_outputs/OTU_annotation.txt


