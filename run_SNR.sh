#!/bin/sh
#SBATCH -N 1      # nodes requested
#SBATCH -n 1      # tasks requested
#SBATCH -c 1     # cores requested
#SBATCH --partition=cpu
#SBATCH --job-name SNR
#SBATCH --mem=24G  # memory 
#SBATCH --output logfiles/sbatch-logfile-%j.txt  # send stdout to outfile
#SBATCH --time=00:15:00

module load matlab-9.5

matlab -nodisplay -nosplash -r "compute_BOLD5000_NCSNR $1 $2; exit"
