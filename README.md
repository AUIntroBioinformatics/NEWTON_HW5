# NEWTON_HW5
## Blast on Command Line Script

### Overview
This script has the commands necessary for using blast on the command line (making databases, blasting a fasta file against one or more of the databases created, counting amount of hits and placing into text file). Variables were made for each fasta file so that they could easily be changed by someone wanting to use this script for other fasta files. 

### Important Code for Script

#### Variables used
````
test=test.fasta
mt=ATmt.fasta
ch=ATcp.fasta
cV=ATchrV.fasta
CHRI_link=`ln -s /apps/bio/unzipped/genomes/Arabidopsis_thaliana/CHR_I`
thaliana_link=`ln -s /apps/bio/unzipped/genomes/Arabidopsis_thaliana`
````

#### Make databases
````
makeblastdb -in $cV -dbtype nucl
makeblastdb -in $ch -dbtype nucl
makeblastdb -in $mt -dbtype nucl
````

#### Blast test.fasta against the databases made from last step
````
blastn -query $test -db ATcp.fasta -outfmt 7 > qtest_dbcp.blastn_out
blastn -query $test -db ATmt.fasta -outfmt 7 > qtest_dbmt.blastn_out
blastn -query $test -db ATchrV.fasta -outfmt 7 > qtest_dbV.blastn_out
blastn -query $test -db Arabidopsis_thaliana/CHR_I/NC_003070.gbk -outfmt 7 > qtest_dbI.blastn_out
````

#### Find unique hits that were found in each database with evalue cutoff cutoff of 0.00001; put into text file
````
blastn -db "ATcp.fasta ATchrV.fasta Arabidopsis_thaliana/CHR_I/NC_003070.gbk ATmt.fasta" -query $test -outfmt 7 -evalue 0.00001 -max_target_seqs 1 | egrep -v '^#' | sed 's/[[:space:]]1_\/home.*NC_[0-9]*[[:space:]]/\tNT\t/' | awk '{print $1,$2}' | sort | uniq | awk '{print $2}' | sort | uniq -c | sort -n > RawCounts.txt
````

#### Set variable to look for any had no hits and echo into text file from last step
````
NUM=$(blastn -db "ATcp.fasta ATchrV.fasta Arabidopsis_thaliana/CHR_I/NC_003070.gbk ATmt.fasta" -query $test -outfmt 7 -evalue 0.00001 -max_target_seqs 1 | grep -c '0 hits' ) && echo $NUM No_hits >> RawCounts.txt
````
