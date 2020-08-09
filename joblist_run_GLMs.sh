#!/bin/sh

NSES=15

#######################
# 1 SESSION AT A TIME 
#######################

# for ((i=1;i<=NSES;i++)); do
#     sbatch run_GLMs_optimize.sh CSI2 $i
# done

# for ((i=1;i<=NSES;i++)); do
#     sbatch run_GLMs_optimize.sh CSI1 $i
# done

#  for ((i=1;i<=NSES;i++)); do
#      sbatch run_GLMs_optimize.sh CSI3 $i
#  #    scancel $i
#  done

# for ((i=369324;i<=369356;i++)); do
#     scancel $i
# done

#sbatch run_GLMs_optimize.sh CSI1 1
# sbatch run_GLMs_optimize.sh CSI1 2 
# sbatch run_GLMs_optimize.sh CSI1 3
# sbatch run_GLMs_optimize.sh CSI1 5
# sbatch run_GLMs_optimize.sh CSI1 7
# sbatch run_GLMs_optimize.sh CSI1 9
# sbatch run_GLMs_optimize.sh CSI1 10
# sbatch run_GLMs_optimize.sh CSI1 15

# sbatch run_GLMs_optimize.sh CSI2 1
# sbatch run_GLMs_optimize.sh CSI2 3 
# sbatch run_GLMs_optimize.sh CSI2 4
# sbatch run_GLMs_optimize.sh CSI2 5
# sbatch run_GLMs_optimize.sh CSI2 9
# sbatch run_GLMs_optimize.sh CSI2 10
# sbatch run_GLMs_optimize.sh CSI2 11
# sbatch run_GLMs_optimize.sh CSI2 12
# sbatch run_GLMs_optimize.sh CSI2 14

#######################
# 3 SESSIONS AT A TIME 
#######################

# sbatch run_GLMs_assume.sh CSI1 7_10_12 
# sbatch run_GLMs_assume.sh CSI1 1_2_3 
# sbatch run_GLMs_assume.sh CSI1 4_13_14 
# sbatch run_GLMs_assume.sh CSI1 6_8_15 
# sbatch run_GLMs_assume.sh CSI1 5_9_11 

# sbatch run_GLMs_assume.sh CSI2 7_10_13 
# sbatch run_GLMs_assume.sh CSI2 3_9_14 
# sbatch run_GLMs_assume.sh CSI2 5_6_11 
# sbatch run_GLMs_assume.sh CSI2 1_2_15 
# sbatch run_GLMs_assume.sh CSI2 4_8_12 

# sbatch run_GLMs_assume.sh CSI3 1_12_14 
# sbatch run_GLMs_assume.sh CSI3 2_3_15 
# sbatch run_GLMs_assume.sh CSI3 4_8_9 
# sbatch run_GLMs_assume.sh CSI3 6_10_13 
# sbatch run_GLMs_assume.sh CSI3 5_7_11 

sbatch run_GLMs_optimize.sh CSI1 7_10_12
sbatch run_GLMs_optimize.sh CSI1 1_2_3 
sbatch run_GLMs_optimize.sh CSI1 4_13_14 
sbatch run_GLMs_optimize.sh CSI1 6_8_15 
sbatch run_GLMs_optimize.sh CSI1 5_9_11 

sbatch run_GLMs_optimize.sh CSI2 7_10_13 
sbatch run_GLMs_optimize.sh CSI2 3_9_14 
sbatch run_GLMs_optimize.sh CSI2 5_6_11 
sbatch run_GLMs_optimize.sh CSI2 1_2_15 
sbatch run_GLMs_optimize.sh CSI2 4_8_12 

sbatch run_GLMs_optimize.sh CSI3 1_12_14 
sbatch run_GLMs_optimize.sh CSI3 2_3_15 
sbatch run_GLMs_optimize.sh CSI3 4_8_9 
sbatch run_GLMs_optimize.sh CSI3 6_10_13 
sbatch run_GLMs_optimize.sh CSI3 5_7_11 

#######################
# 5 SESSIONS AT A TIME 
#######################

# sbatch run_GLMs_assume.sh CSI1 2_4_8_13_14 
# sbatch run_GLMs_assume.sh CSI1 1_5_10_11_15 
# sbatch run_GLMs_assume.sh CSI1 3_6_7_9_12 

sbatch run_GLMs_optimize.sh CSI1 2_4_8_13_14 
sbatch run_GLMs_optimize.sh CSI1 1_5_10_11_15 
sbatch run_GLMs_optimize.sh CSI1 3_6_7_9_12 

# sbatch run_GLMs_assume.sh CSI2 2_3_4_8_14 
# sbatch run_GLMs_assume.sh CSI2 6_7_10_11_13 
# sbatch run_GLMs_assume.sh CSI2 1_5_9_12_15 

sbatch run_GLMs_optimize.sh CSI2 2_3_4_8_14 
sbatch run_GLMs_optimize.sh CSI2 6_7_10_11_13 
sbatch run_GLMs_optimize.sh CSI2 1_5_9_12_15 

# sbatch run_GLMs_assume.sh CSI3 3_5_6_9_15 
# sbatch run_GLMs_assume.sh CSI3 4_7_10_11_14 
# sbatch run_GLMs_assume.sh CSI3 1_2_8_12_13 

sbatch run_GLMs_optimize.sh CSI3 3_5_6_9_15 
sbatch run_GLMs_optimize.sh CSI3 4_7_10_11_14 
sbatch run_GLMs_optimize.sh CSI3 1_2_8_12_13 

