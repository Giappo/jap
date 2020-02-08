example_no=$1

module load git
git clone https://github.com/richelbilderbeek/peregrine.git
git clone https://github.com/richelbilderbeek/pirouette_example_${example_no}.git
cd pirouette_example_${example_no}/
module load R
sbatch ../peregrine/scripts/run_r_script.sh example_${example_no}.R 