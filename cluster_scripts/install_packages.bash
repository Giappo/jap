#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --job-name=install_packages
#SBATCH --output=install_packages.log

pkg_name=$1
cd /home/$USER/
#mkdir -p Rlibrary
#chmod +x /home/$USER/Rlibrary/

module load R
#Rscript -e "install.packages(\"$github_address\")"
#Rscript -e "devtools::install_github(\"$github_address\")"
Rscript -e "ifelse(grepl(pattern = "/", x = \"$pkg_name\"), yes = devtools::install_github(\"$pkg_name\"), no = install.packages(\"$pkg_name\"))"
#Rscript -e ".libPaths(new = file.path(substring(getwd(),1,13), 'Rlibrary')); devtools::install_github(\"$github_address\")"
