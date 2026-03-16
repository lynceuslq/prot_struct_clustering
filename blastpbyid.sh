#!/bin/bash

export PATH="$PATH:/mnt/tools/"
DB="/mnt/diamond_db/nr_diamond_taxid.dmnd"
id=4751
QUERYFAA="/mnt/fps/fungi/reference_proteins.faa"
OUTDIR="/mnt/fps/fungi/blastp"

echo -e "start to blast against databse $DB at $(date)"

	diamond blastp --db $DB --query $QUERYFAA --out $OUTDIR/blastp.${id}.tsv  --threads 4  --outfmt 6 qseqid sseqid qlen slen length qcovhsp pident evalue bitscore mismatch staxids sscinames salltitles full_sseq  --very-sensitive  -k 0 -e 0.001 --taxonlist ${id}

	cat $OUTDIR/blastp.${id}.tsv  | tr " " "+" | cut -f2,11,12,14 | sort -u -T $OUTDIR |while read f1 f2 f3 f4; do echo -e ">${f1// /}\t${f2// /}\t${f3// /}\n${f4// /}"; done | tr "+" " " > $OUTDIR/sigblastp.${id}.faa


echo -e "completed blastp against databse $DB at $(date)"
