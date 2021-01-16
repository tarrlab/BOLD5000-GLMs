#!/bin/sh
#SBATCH -N 1      # nodes requested
#SBATCH -n 1      # tasks requested
#SBATCH -c 1     # cores requested
#SBATCH --partition=gpu
#SBATCH --job-name SNR
#SBATCH --mem=24G  # memory 
#SBATCH --output logfiles/sbatch-logfile-%j.txt  # send stdout to outfile
#SBATCH --time=00:20:00

module load matlab-9.5

matlab -nodisplay -nosplash -r "compute_BOLD5000_NCSNR_v6; exit"
