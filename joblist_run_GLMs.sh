#!/bin/sh

#sbatch run_GLMs.sh CSI1 1 assume
sbatch run_GLMs.sh CSI1 1 optimize

#sbatch run_GLMs.sh CSI2 1 assume
#sbatch run_GLMs.sh CSI2 1 optimize

#sbatch run_GLMs.sh CSI3 1 assume
#sbatch run_GLMs.sh CSI3 1 optimize
