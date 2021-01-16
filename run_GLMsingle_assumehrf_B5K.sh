#!/bin/sh
#SBATCH -N 1      # nodes requested
#SBATCH -n 1      # tasks requested
#SBATCH -c 1      # cores requested
#SBATCH --partition=gpu
#SBATCH --job-name aGLM
#SBATCH --mem=80G  # memory 
#SBATCH --output logfiles/sbatch-logfile-%j.txt  # send stdout to outfile
#SBATCH --time=24:00:00

module load matlab-9.5

matlab -nodisplay -nosplash -r "step1_run_GLMs_v7 $1 $2 assume; exit"