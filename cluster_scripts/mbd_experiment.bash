#!/bin/bash
#SBATCH --time=00:57:58 --partition=gelifes
project=mbd
my_email=glaudanno@gmail.com
cd /home/$USER/
mkdir -p $project
cd /home/$USER/$project/
mkdir -p results
mkdir -p data
mkdir -p logs

sim_min=1
sim_max=1000
crown_age=15

lambda_vec=(0.2)
mu_vec=(0.0 0.15)
nu_vec=(1 1.5 2 2.5)
q_vec=(0.1 0.15 0.2)

for lambda in ${lambda_vec[@]}; do
for mu in ${mu_vec[@]}; do
for nu in ${nu_vec[@]}; do
for q in ${q_vec[@]}; do

cond=0
experiment_name=exp-${project}-${lambda}-${mu}-${nu}-${q}-${cond}-${crown_age}
sbatch --job-name=$experiment_name --mail-type=FAIL,TIME_LIMIT --mail-user=$my_email --output=logs/$experiment_name.log mbd_main.bash $lambda $mu $nu $q $cond $crown_age $sim_min $sim_max gelifes

cond=1
experiment_name=exp-${project}-${lambda}-${mu}-${nu}-${q}-${cond}-${crown_age}
sbatch --job-name=$experiment_name --mail-type=FAIL,TIME_LIMIT --mail-user=$my_email --output=logs/$experiment_name.log mbd_main.bash $lambda $mu $nu $q $cond $crown_age $sim_min $sim_max regular

cond=2
experiment_name=exp-${project}-${lambda}-${mu}-${nu}-${q}-${cond}-${crown_age}
sbatch --job-name=$experiment_name --mail-type=FAIL,TIME_LIMIT --mail-user=$my_email --output=logs/$experiment_name.log mbd_main.bash $lambda $mu $nu $q $cond $crown_age $sim_min $sim_max gelifes

cond=3
experiment_name=exp-${project}-${lambda}-${mu}-${nu}-${q}-${cond}-${crown_age}
sbatch --job-name=$experiment_name --mail-type=FAIL,TIME_LIMIT --mail-user=$my_email --output=logs/$experiment_name.log mbd_main.bash $lambda $mu $nu $q $cond $crown_age $sim_min $sim_max regular

done
done
done
done
done
