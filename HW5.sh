########################
#!/bin/env sh
########################

########################
##Modules
module load blast+
########################

########################
##Variables
test=test.fasta
mt=ATmt.fasta
ch=ATcp.fasta
cV=ATchrV.fasta
CHRI_link=`ln -s /apps/bio/unzipped/genomes/Arabidopsis_thaliana/CHR_I`
thaliana_link=`ln -s /apps/bio/unzipped/genomes/Arabidopsis_thaliana`
########################

########################
##Commands
#make directory to hold all files used in class
mkdir Feb21_class
cd ./Feb21_class 

#copy over fasta files from class shared folder to Feb21_class folder
cp ~/class_shared/GuestLectureII/ATchrV.fasta ./
cp ~/class_shared/GuestLectureII/ATcp.fasta ./
cp ~/class_shared/GuestLectureII/ATmt.fasta ./
cp ~/class_shared/GuestLectureII/test.fasta ./

#make databases of each fasta file
makeblastdb -in $cV -dbtype nucl
makeblastdb -in $ch -dbtype nucl
makeblastdb -in $mt -dbtype nucl

#read help page to look at the various options available in blastn
blastn -help

#make symbolic links to A. thaliana 
$CHRI_link
$thaliana_link

#blast test.fasta against all other fasta files (chloroplast, mitochondria, chrV, chrI)
blastn -query $test -db ATcp.fasta -outfmt 7 > qtest_dbcp.blastn_out
blastn -query $test -db ATmt.fasta -outfmt 7 > qtest_dbmt.blastn_out
blastn -query $test -db ATchrV.fasta -outfmt 7 > qtest_dbV.blastn_out
blastn -query $test -db Arabidopsis_thaliana/CHR_I/NC_003070.gbk -outfmt 7 > qtest_dbI.blastn_out

#example query to look at amount of hits for each database
grep "ATMG00020.1" qtest_dbmt.blastn_out
grep "ATMG00020.1" qtest_dbI.blastn_out
grep "ATMG00020.1" qtest_dbcp.blastn_out

#blast query against multiple databases and use less to examine output file
blastn -db "ATcp.fasta ATchrV.fasta Arabidopsis_thaliana/CHR_I/NC_003070.gbk ATmt.fasta" -query $test -outfmt 7 | less -S

#do all of these pipes to look at how many unique hits were found in each database with an evalue cutoff of 0.00001, removed unnecessary path, and put in RawCounts.txt file
blastn -db "ATcp.fasta ATchrV.fasta Arabidopsis_thaliana/CHR_I/NC_003070.gbk ATmt.fasta" -query $test -outfmt 7 -evalue 0.00001 -max_target_seqs 1 | egrep -v '^#' | sed 's/[[:space:]]1_\/home.*NC_[0-9]*[[:space:]]/\tNT\t/' | awk '{print $1,$2}' | sort | uniq | awk '{print $2}' | sort | uniq -c | sort -n > RawCounts.txt

#set variable to see if any had 0 hits and put into RawCounts.txt file
NUM=$(blastn -db "ATcp.fasta ATchrV.fasta Arabidopsis_thaliana/CHR_I/NC_003070.gbk ATmt.fasta" -query $test -outfmt 7 -evalue 0.00001 -max_target_seqs 1 | grep -c '0 hits' ) && echo $NUM No_hits >> RawCounts.txt
