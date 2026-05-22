This protein-mining workflow is designed to identify functionally conserved proteins, which might be distantly related in evolution. 
The workflow combined proteomic information from three aspects: 
  1) sequential homology,
  2) structural homology，
  3) conserved pathways in their corresponding genomes,
to investigate potentially functionally-conserved luciferases.

The workflow starts with homology investigation based on sequence alignment with Diamond blastp against reference proteins in the non-redundant protein database of NCBI (e-value threshold of 0.0001). The target sequences will then be examined by InterProScan for their functional domain and filtered by the InterPro ID ESMFold is then engaged to predict the tertiary structures of proteins with sequential homology followed by FoldSeek easy-cluster which apply structural clustering on those proteins (with the threshold of TM-score at 0.5, sequence identity at 0.7 and coverage at 0.7). The structural homology of the proteins clustered with  reference proteins is demonstrated by constructing structure-sharing networks with structural similarity as edges. The proteins which are clustered with reference proteins by structural homology are selected and demonstrated by their phylogenetic relations with Mafft alignment followed by IQ-Tree 2. 

The graph below shows how the workflow works in our luciferase mining project.
![Luciferase mining workflow](https://github.com/lynceuslq/prot_struct_clustering/blob/main/prot_mining_gpt.png)
