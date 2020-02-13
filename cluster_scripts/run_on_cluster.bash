#!/bin/bash
#SBATCH --time=00:04:58 --partition=short
my_email=glaudanno@gmail.com
chosen_partition=gelifes
cd /home/$USER/jap_scripts/

args_file=$1
fun_file=$2
args_string=${args_file%.*}

echo ${args_file}
echo ${args_string}
echo ${fun_file}

args_file=$( printf $args_file )
fun_file=$( printf $fun_file )

R_file_name=R-${args_string}.R
bash_file_name=bash-${args_string}.bash
job_name=${args_string}
log_name=${args_string}.log

rm $R_file_name #remove previous versions
rm $bash_file_name #remove previous versions

echo "args <- commandArgs(TRUE)" > $R_file_name
echo "print(args)" >> $R_file_name
echo "load(file.path(getwd(), \"${fun_file}\"))" >> $R_file_name
echo "x <- fun_list\$run_function_from_file(args_file = args)" >> $R_file_name
echo "print(x)" >> $R_file_name
#echo 'save(x, file = file.path(getwd(), \"out.RData\"))' >> $R_file_name

echo "#!/bin/bash" > $bash_file_name
echo "#SBATCH --time=71:58:58" >> $bash_file_name
echo "#SBATCH --output=${log_name}" >> $bash_file_name
echo "module load R" >> $bash_file_name
echo "Rscript ${R_file_name} ${args_file}" >> $bash_file_name
#echo "rm ${R_file_name}" >> $bash_file_name
#echo "rm ${bash_file_name}" >> $bash_file_name

#NEVER ASK FOR MORE THAN 9GB OF MEMORY!
sbatch  --partition=$chosen_partition \
		--mem=9GB \
		--job-name=$job_name \
		--mail-type=FAIL,TIME_LIMIT \
		--mail-user=$my_email \
		--output=job-${job_name}.log \
		$bash_file_name
		
cd /home/$USER/
# ls | find . -name "slurm*" | xargs rm
