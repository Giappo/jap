#!/bin/bash
#SBATCH --time=00:04:58 --partition=short
my_email=glaudanno@gmail.com
chosen_partition=gelifes
cd /home/$USER/jap_scripts/

stringa=$1
stringa=$( printf $stringa )

R_file_name=R-${chosen_partition}.R
bash_file_name=bash-${chosen_partition}.bash
job_name=${chosen_partition}
log_name=${chosen_partition}.log

rm $R_file_name #remove previous versions
rm $bash_file_name #remove previous versions

echo "args <- commandArgs(TRUE)" > $R_file_name
echo "print(args)" >> $R_file_name
echo "devtools::install_github(\"Giappo/mbd\")" >> $R_file_name
echo "x <- eval(str2expression(args))" >> $R_file_name
echo "print(x)" >> $R_file_name
#echo 'save(x, file = file.path(getwd(), \"out.RData\"))' >> $R_file_name

echo "#!/bin/bash" > $bash_file_name
echo "#SBATCH --time=00:58:58" >> $bash_file_name
echo "#SBATCH --output=${log_name}" >> $bash_file_name
echo "module load R" >> $bash_file_name
echo "Rscript ${R_file_name} ${stringa}" >> $bash_file_name
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
