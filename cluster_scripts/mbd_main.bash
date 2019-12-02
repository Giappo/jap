#!/bin/bash
#SBATCH --time=00:57:58 --partition=gelifes
my_github=Giappo
project=mbd
my_email=glaudanno@gmail.com
cd /home/$USER/
mkdir -p $project
cd /home/$USER/$project/
mkdir -p results
mkdir -p data
mkdir -p logs

lambda=$1
mu=$2
nu=$3
q=$4
cond=$5
crown_age=$6
min_sims=$7
max_sims=$8
chosen_partition=${9}

R_file_name=R-${project}-${lambda}-${mu}-${nu}-${q}-${cond}-${crown_age}-${chosen_partition}.R

chmod +x install_packages.bash
./install_packages.bash "${my_github}/${project}"

sleep 30

echo ".libPaths(new = file.path(substring(getwd(),1,13), 'Rlibrary')); library(\"$project\"); args <- as.numeric(commandArgs(TRUE))" > $R_file_name
echo "mbd:::mbd_main(seed=args[1],sim_pars=c(args[2],args[3],args[4],args[5]),cond=args[6],age = args[7],loglik_functions=mbd_logliks_experiment())" >> $R_file_name

#args:
#1: $s = seed
#2: $lambda = Main clade speciation rate
#3: $mu = Main clade extinction rate
#4: $nu = Subclade speciation rate
#5: $q = Subclade extinction rate
#6: $cond = Conditioning
#7: $crown_age = Main clade starting time

for((s = min_sims; s <= max_sims; s++)); do

bash_file_name=bash-${project}-${s}-${lambda}-${mu}-${nu}-${q}-${cond}-${crown_age}.bash
ml_name=ml-${project}-${s}-${lambda}-${mu}-${nu}-${q}-${cond}-${crown_age}

echo "#!/bin/bash" > $bash_file_name
echo "#SBATCH --time=119:59:00" >> $bash_file_name
echo "module load R" >> $bash_file_name
echo "Rscript $R_file_name $s $lambda $mu $nu $q $cond $crown_age" >> $bash_file_name
echo "rm $bash_file_name" >> $bash_file_name

#NEVER ASK FOR MORE THAN 9GB OF MEMORY!
sbatch --partition=$chosen_partition --mem=9GB --job-name=$ml_name --mail-type=FAIL,TIME_LIMIT --mail-user=$my_email --output=logs/$ml_name.log $bash_file_name

done

