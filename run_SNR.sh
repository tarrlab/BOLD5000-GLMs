#!/bin/sh
#SBATCH -N 1      # nodes requested
#SBATCH -n 1      # tasks requested
#SBATCH -c 3     # cores requested
#SBATCH --partition=gpu
#SBATCH --job-name SNR
#SBATCH --mem=24G  # memory 
#SBATCH --output logfiles/sbatch-logfile-%j.txt  # send stdout to outfile
#SBATCH --time=12:00:00

module load matlab-9.5

matlab -nodisplay -nosplash -r "step3_compute_NCSNR; exit"
