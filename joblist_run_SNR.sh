#!/bin/sh

sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess_assume/CSI1 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess_assume/CSI2 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess_assume/CSI3 TYPEB_FITHRF

sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess_assume/CSI1 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess_assume/CSI2 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess_assume/CSI3 TYPEB_FITHRF

sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess_assume/CSI1 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess_assume/CSI2 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess_assume/CSI3 TYPEB_FITHRF


sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess/CSI1 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess/CSI2 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess/CSI3 TYPEB_FITHRF

sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess/CSI1 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess/CSI2 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess/CSI3 TYPEB_FITHRF

sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess/CSI1 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess/CSI2 TYPEB_FITHRF
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess/CSI3 TYPEB_FITHRF


sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess/CSI1 TYPEC_FITHRF_GLMDENOISE
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess/CSI2 TYPEC_FITHRF_GLMDENOISE
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess/CSI3 TYPEC_FITHRF_GLMDENOISE

sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess/CSI1 TYPEC_FITHRF_GLMDENOISE
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess/CSI2 TYPEC_FITHRF_GLMDENOISE
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess/CSI3 TYPEC_FITHRF_GLMDENOISE

sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess/CSI1 TYPEC_FITHRF_GLMDENOISE
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess/CSI2 TYPEC_FITHRF_GLMDENOISE
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess/CSI3 TYPEC_FITHRF_GLMDENOISE


sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess/CSI1 TYPED_FITHRF_GLMDENOISE_RR
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess/CSI2 TYPED_FITHRF_GLMDENOISE_RR
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_one-sess/CSI3 TYPED_FITHRF_GLMDENOISE_RR

sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess/CSI1 TYPED_FITHRF_GLMDENOISE_RR
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess/CSI2 TYPED_FITHRF_GLMDENOISE_RR
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_three-sess/CSI3 TYPED_FITHRF_GLMDENOISE_RR

sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess/CSI1 TYPED_FITHRF_GLMDENOISE_RR
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess/CSI2 TYPED_FITHRF_GLMDENOISE_RR
sbatch run_SNR.sh /home/jacobpri/git/BOLD5000-GLMs/betas/07_27_20_five-sess/CSI3 TYPED_FITHRF_GLMDENOISE_RR

# sbatch run_SNR.sh CSI2 07_08_20 TYPEB_FITHRF
# sbatch run_SNR.sh CSI2 07_08_20 TYPEC_FITHRF_GLMDENOISE
# sbatch run_SNR.sh CSI2 07_08_20 TYPED_FITHRF_GLMDENOISE_RR

# sbatch run_SNR.sh CSI3 07_08_20_assume TYPEB_FITHRF
# sbatch run_SNR.sh CSI3 07_08_20 TYPEB_FITHRF
# sbatch run_SNR.sh CSI3 07_08_20 TYPEC_FITHRF_GLMDENOISE
# sbatch run_SNR.sh CSI3 07_08_20 TYPED_FITHRF_GLMDENOISE_RR
