#!/bin/bash
#SBATCH --time=00:57:58 --partition=gelifes
project=mbd
my_email=glaudanno@gmail.com

lambda=$1
mu=$2
nu=$3
q=$4
cond=$5
crown_age=$6
min_sims=$7
max_sims=$8
chosen_partition=${9}

echo $lambda
echo $mu
echo $nu
echo $q
echo $cond
echo $crown_age
echo $min_sims
echo $max_sims
echo $chosen_partition
echo ${chosen_partition}_${lambda}