#!/bin/bash
#SBATCH --time=00:04:58 --partition=short
my_email=glaudanno@gmail.com
chosen_partition=gelifes
cd /home/$USER/jap_scripts/

github=$1
package=$2
funname=$3
arguments=$4

github=$( printf $github )
package=$( printf $package )
funname=$( printf $funname )
arguments=$( printf $arguments )

args_vector=(${github} ${package} ${funname} ${arguments})

R_file_name=R-${funname}.R
bash_file_name=bash-${funname}.bash
job_name=${funname}-${arguments}

echo "${github}"
echo "${package}"
echo "${funname}"
echo "${arguments}"
echo "${args_vector[@]}"
echo "${R_file_name}"
echo "${bash_file_name}"
echo "${job_name}"

printf '%q\n' "$arguments"

rm $R_file_name #remove previous versions
rm $bash_file_name #remove previous versions

echo "args <- commandArgs(TRUE)" > $R_file_name
echo "print(args[1])" >> $R_file_name
echo "print(args[2])" >> $R_file_name
echo "print(args[3])" >> $R_file_name
echo "print(args[4])" >> $R_file_name
echo "x <- jap::run_function(github_name = args[1], package_name = args[2], function_name = args[3], fun_arguments = args[4])" >> $R_file_name
echo "print(x)" >> $R_file_name
echo 'save(x, file = file.path(getwd(), \"out.RData\"))' >> $R_file_name

echo "#!/bin/bash" > $bash_file_name
echo "#SBATCH --time=71:58:58" >> $bash_file_name
echo "#SBATCH --output=bash-${funname}.log" >> $bash_file_name
echo "module load R" >> $bash_file_name
echo "Rscript ${R_file_name} ${args_vector[@]}" >> $bash_file_name
echo "rm ${R_file_name}" >> $bash_file_name
echo "rm ${bash_file_name}" >> $bash_file_name

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
