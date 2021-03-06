#!/bin/bash -l
#
#SBATCH
#SBATCH --partition=shared
#SBATCH --job-name=CheckM
#SBATCH --time=72:0:0
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G


comm () { ${SOFT}/print_comment.py "$1" "-"; }
error () { ${SOFT}/print_comment.py "$1" "*"; exit 1; }
warning () { ${SOFT}/print_comment.py "$1" "*"; }
announcement () { ${SOFT}/print_comment.py "$1" "#"; }


source config-metawrap

# runs CheckM mini-pipeline on a single folder of bins
if [[ -d ${1}.checkm ]]; then rm -r ${1}.checkm; fi
comm "Running CheckM on $1 bins"
mkdir ${1}.tmp
checkm lineage_wf -x fa $1 ${1}.checkm -t 24 --tmpdir ${1}.tmp
if [[ ! -s ${1}.checkm/storage/bin_stats_ext.tsv ]]; then error "Something went wrong with running CheckM. Exiting..."; fi
rm -r ${1}.tmp

comm "Finalizing CheckM stats..."
${SOFT}/summarize_checkm.py ${1}.checkm/storage/bin_stats_ext.tsv > ${1}.stats

#comm "Making CheckM plot of $1 bins"
#checkm bin_qa_plot -x fa ${1}.checkm $1 ${1}.plot
#if [[ ! -s ${1}.plot/bin_qa_plot.png ]]; then warning "Something went wrong with making the CheckM plot. Exiting."; fi
#mv ${1}.plot/bin_qa_plot.png ${1}.png
#rm -r ${1}.plot


announcement "CheckM pipeline finished"
