#!/bin/bash


export PATH="$PATH:/mnt/tools/"
DB="/mnt/fps/fungi/embedding_res/ref_pathway"
REFFAA="/mnt/fps/fungi/ref_pathway.faa"
SHARESTRUCT="./share_structs.faa"
TAXID="./taxid.list"
OUTDIR="."
PATTERN="LUZ_NEONM"
PATHWAYS="/mnt/fps/fungi/pathway_genes.list"

echo -e "start to make diamond databse $DB at $(date)"

cat $SHARESTRUCT | cut -f2 | tr ";" "\n" | sort | uniq > $TAXID

diamond makedb --db $DB --in $REFFAA

cat $TAXID | while read id ; 
do 
	QUERYFNA="$OUTDIR/taxid/${id}/genome.fasta"
	OUTFILE="$OUTDIR/taxid/${id}/ref_pathway.${id}.tsv"
	OUTFAA="$OUTDIR/taxid/${id}/ref_pathway.${id}.faa"
	
	echo -e "start to process ${id} at $(date)"

	diamond blastx --db ${DB}.dmnd --query $QUERYFNA --out $OUTFILE  --threads 2  --outfmt 6 qseqid sseqid qstart qend qlen slen length scovhsp pident evalue bitscore mismatch qseq_translated  --very-sensitive -k 0  -e 0.001

	echo -e "blastx on $id completed at $(date)"

	cat $OUTFILE | tr " " "+" | cut -f1,2,3,4,13 | sort -u -T $OUTDIR |while read f1 f2 f3 f4 f5; do echo -e ">${f1// /}\t${f2// /}\t${f3// /}\t${f4// /}\n${f5// /}"; done | tr "+" " " > $OUTFAA

	echo -e "extraction from blastx results on $id completed at $(date)"

done

cat $TAXID | while read id ; 
do 
	cat $OUTDIR/taxid/${id}/ref_pathway.${id}.tsv | grep -w "$PATTERN" |cut -f1 | sort | uniq | while read scaff ; do grep -w ${scaff} $OUTDIR/taxid/${id}/ref_pathway.${id}.tsv | cut -f1-10 ; done > $OUTDIR/taxid/${id}/ref_pathway.${id}.sorted.tsv; 
	echo -e "completed sorting on $id at $(date)"; 
done


cat $PATHWAYS | while read gene ; do grep -w "$gene" $OUTDIR/taxid/*/ref_pathway.*.sorted.tsv  | rev | cut -d "/" -f2 |rev| sort | uniq > $OUTDIR/pathway.${gene}.list ; done

cat $TAXID | while read id ; 
do 
	line=$(grep "${id}" -w $OUTDIR/pathway.*.list | cut -d "." -f2 | tr "\n" ";") ; 
	echo -e "${id}\t${line}" ; 
done > $OUTDIR/sort.pathway.tsv


cat $TAXID | while read id ; 
do 
	grep "${id}" -w $OUTDIR/pathway.*.list | cut -d "." -f2 | while read gene ; do echo -e "$id\t$gene"; done ; 
done > $OUTDIR/sort.pathway.longtab.tsv


cat $OUTDIR/sort.pathway.tsv | while read id gene; 
do 
	lineage=$(cut -f3 $OUTDIR/taxid/$id/fullnamelineage.$id.dmp); 
	seq=$(cat $OUTDIR/taxid/$id/ref_pathway.$id.sorted.tsv  | cut -f1 | sort | uniq | while read hap ; do genes=$(grep "$hap" $OUTDIR/taxid/$id/ref_pathway.$id.sorted.tsv | sort -k3 -n | cut -f2 | cut -d "|" -f3 | tr "\n" ";"); echo -e "$hap:$genes" ; done | tr "\n" " ") ; 
	echo -e "${id}\t${gene}\t${seq}\t$lineage" ; 
done  > $OUTDIR/sortbyscafolds.pathway.tsv


cat $OUTDIR/pathway.*.list | sort | uniq -c |sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | awk '$1 == 4' | cut -d " " -f2 > $OUTDIR/allpathwaygenes.list

grep -f $OUTDIR/allpathwaygenes.list -w --no-group-separator $OUTDIR/sortbyscafolds.pathway.tsv > $OUTDIR/allpathwaygenes.tsv

echo -e "job completed at $(date)"
