#!/bin/bash

SCANNER="/mnt/tools/my_interproscan/interproscan-5.72-103.0/interproscan.sh"
id=4751
INPUTfaa=/mnt/fps/fungi/blastp/sigblastp.${id}.faa
OUTDIR="interproscan_out"
feature="IPR048273"

echo "feature scanning start at $(date) "; 
$SCANNER -cpu 6 -d $OUTDIR -i $INPUTfaa -appl PANTHER,Gene3D,ProSiteProfiles,CDD,Pfam  ;
grep -w "$feature" $OUTDIR/${INPUTfaa}.tsv | cut -f1 | sort | uniq > $OUTDIR/verified.${id}.list

grep -f $OUTDIR/varified.${id}.list -w -A1 --no-group-separator $INPUTfaa > $OUTDIR/verified_seq.faa


echo -e "scanning completed at $(date)"
