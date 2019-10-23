#!/bin/bash

'''Ecrivez un programme bash qui :
Pour chaque paire de fichier (R1 et R2):
1. Reportez les distributions de qualités avant et après filtrage qualité à l’aide de ​ fastqc​ :
http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip
2. Filtrer (trim) les reads appariés à l’aide d’Alientrimmer selon un Q20 et les séquences
dites “alien” fournies avec les séquences (databases/contaminants.fasta).
3. Puis fusionne ces reads à l’aide Vsearch (Paired-end reads merging) et sort un fichier au
format fasta
Il est ​ impératif​ à cette étape d’ajouter un ​ suffix​ à chaque read telle que:
@.... ;sample=nom d’échantillon;Par exemple
;sample=1ng-25cycles-1;
Cela permettra d’associer à chaque read - un échantillon et sera important pour la quantification
des OTU dans les échantillons.'''

cd soft
./JarMaker.sh AlienTrimmer.java #ca permet de créer le AlienTrimmer.jar
java -jar AlienTrimmer.jar
cd ..

mkdir Cleaning-Trimming-R1-outputs
mkdir Cleaning-Trimming-R2-outputs

gunzip *.gz

for i in $(ls fastq/*_R1.fastq);do
echo $i; 
nameR1="$i";
echo $nameR1;
nameR2=$(echo $i | sed s/R1/R2/g);
echo $nameR2;
#fastqc $nameR1 $nameR2
java -jar ./soft/AlienTrimmer.jar -if $nameR1 -ir $nameR2 -c ./databases/contaminants.fasta -q 20 -of ./Cleaning-Trimming-R1-outputs/$(basename $nameR1) -or ./Cleaning-Trimming-R2-outputs/$(basename $nameR2)
done 

