export PATH="$PATH:/mnt/tools/foldseek/bin/"

###################define input arguements

structure_dir="/mnt/fps/fungi/esm_structs"
outdir="test_all_struct_align"
allseqs="/mnt/fps/fungi/verified_seq.faa"
refprot="/mnt/fps/fungi/reference_proteins.faa"

###################
structures=$outdir/all_structs
reflist=$outdir/reference.list

mkdir $outdir
mkdir $structures

grep ">" $refprot | cut -f1 -d " " | sed "s/>//g" > $reflist

foldseek easy-cluster $structure_dir/ $outdir/res tmp -c 0.8  --tmscore-threshold 0.5 --min-seq-id 0.5

cat $outdir/res_cluster.tsv | cut -f1,2   > $outdir/res_cluster.mapped.tsv

grep -f $reflist $outdir/res_cluster.mapped.tsv > $outdir/share_structs.clusters.tsv

grep -f $reflist $outdir/res_cluster.mapped.tsv | cut -f2 | grep -f $reflist -v > $outdir/share_structs.tsv

echo -e "$(cat $outdir/share_structs.tsv | wc -l ) sequences found with shared structres with reference sequences"

cat $outdir/share_structs.tsv | while read gene ; do cp $structure_dir/struct-${gene}-esmfold.pdb   $structures ; done

cat $reflist | while read gene ; do cp $structure_dir/struct-${gene}-esmfold.pdb   $structures ; done

grep -f $outdir/share_structs.tsv -A1 --no-group-separator $allseqs > $outdir/share_structs.faa

database="$outdir/struct_db/"

mkdir $database

foldseek createdb $structures/ $database/struct_db
foldseek createindex $database tmp 

foldseek easy-search $structures/ $database/struct_db --format-output "query,target,fident,alnlen,alntmscore,qtmscore,ttmscore,lddt,prob,qstart,qend,tstart,tend,evalue,bits"  $outdir/aln.m8 tmpFolder

cat $outdir/aln.m8 | awk '$1 != $2' |awk -F "\t" '$4 >= 50'  > $outdir/aln.m8.filtered.tsv
cat $outdir/aln.m8.filtered.tsv | cut -f1,2,3  > $outdir/struct_homology.tsv

cat $outdir/struct_homology.tsv | awk '$1 != $2'| awk '$3 >= 0.8' > $outdir/struct_homology.id80.tsv
cat $outdir/struct_homology.tsv | awk '$1 != $2'| awk '$3 >= 0.5' > $outdir/struct_homology.id50.tsv

echo -e "completed strcutural aligning at $(date)"

python3 /mnt/plotnetwork.py -networkfile $outdir/struct_homology.id50.tsv -annotatefile $outdir/share_structs.clusters.tsv  -out $outdir 
