#!/bin/bash
#SBATCH --time=00:00:58 --partition=short
my_github=Giappo
project=mbd
my_email=glaudanno@gmail.com
cd /home/$USER/
mkdir -p $project
cd /home/$USER/$project/
mkdir -p results
mkdir -p data
mkdir -p logs

lambda=${1}
mu=${2}
nu=${3}
q=${4}
cond=${5}
crown_age=${6}
seed=${7}
chosen_partition=${8}

#args:
#1: $seed
#2: $lambda = Speciation rate
#3: $mu = Extinction rate
#4: $nu = Multiple speciation rate
#5: $q = Multiple speciation probability
#6: $cond = Conditioning
#7: $crown_age = Clade starting time

args_string=${seed}-${lambda}-${mu}-${nu}-${q}-${cond}-${crown_age}
args_vector=(${seed} ${lambda} ${mu} ${nu} ${q} ${cond} ${crown_age})

R_file_name=R-${project}-${args_string}-${chosen_partition}.R
bash_file_name=bash-${project}-${args_string}.bash
job_name=ml-${project}-${args_string}

rm $R_file_name #remove previous versions
rm $bash_file_name #remove previous versions

echo "library(\"$project\"); args <- as.numeric(commandArgs(TRUE))" > $R_file_name
echo "mbd::mbd_main(seed=args[1],sim_pars=c(args[2],args[3],args[4],args[5]),cond=args[6],age=args[7],loglik_functions=mbd::mbd_experiment_logliks())" >> $R_file_name

echo "#!/bin/bash" > $bash_file_name
echo "#SBATCH --time=71:58:58" >> $bash_file_name
echo "module load R" >> $bash_file_name
echo "Rscript $R_file_name ${args_vector[@]}" >> $bash_file_name
echo "rm $R_file_name" >> $bash_file_name
echo "rm $bash_file_name" >> $bash_file_name

#NEVER ASK FOR MORE THAN 9GB OF MEMORY!
sbatch  --partition=$chosen_partition \
		--mem=9GB \
		--job-name=$job_name \
		--mail-type=FAIL,TIME_LIMIT \
		--mail-user=$my_email \
		--output=logs/$job_name.log \
		$bash_file_name
		
cd /home/$USER/
ls | find . -name "slurm*" | xargs rm
