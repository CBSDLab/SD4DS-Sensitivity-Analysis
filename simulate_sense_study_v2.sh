#!/bin/bash
#SBATCH -N 1
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH --mem=4gb
#SBATCH --output=my.stdout 
#SBATCH --mail-user=<your email address>
#SBATCH --mail-type=ALL 
#SBATCH --job-name="sensitivity analysis with k=10 and 4GB memor"

#SBATCH -o serial-R.out%j # capture jobid in output file name

# load R module
module load R/4.1.2-foss-2021b

# generate study file with random sampled initial conditions and parameters
Rscript create_sens_study.R

# run simulation study using AWK script
awk -f simulate_scenarios.awk -v MODEL="limits to growth v2.stmx" sens_study.csv

# load R module to process results
module load R/4.1.2-foss-2021b
Rscript process_results.R

# copy processed results to study results file
cp study_results.csv sens_study_results.csv
