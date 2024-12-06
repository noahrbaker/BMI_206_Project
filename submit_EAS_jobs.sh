#!/bin/bash
#$ -S /bin/bash       # the shell language when run via the job scheduler [IMPORTANT]
#$ -N PRScsx_EAS_job_sims
#$ -o sge/out_$JOB_ID_$TASK_ID.out
#$ -e sge/out_$JOB_ID_$TASK_ID.err
#$ -cwd               # job should run in the current working directory
#$ -l mem_free=8G     # job requires up to 8 GiB of RAM per slot
#$ -l scratch=8G      # job requires up to 2 GiB of local /scratch space
#$ -l h_rt=5:00:00    # job requires up to 1 hours of runtime
#$ -t 1-90            # array job with tasks equal to the number of .tsv files
#$ -r y               # if job crashes, it should be restarted

echo "Starting job on $(date)"
echo "SGE_TASK_ID: $SGE_TASK_ID"

# Source the Conda and Mamba setup scripts
source /wynton/protected/home/rotation/noahbaker/miniforge3/etc/profile.d/conda.sh
echo "Conda configuration sourced"

if [ -f "/wynton/protected/home/rotation/noahbaker/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "/wynton/protected/home/rotation/noahbaker/miniforge3/etc/profile.d/mamba.sh"
    echo "Mamba sourced"
else
    echo "Mamba script not found, proceeding without it"
fi

# Activate the Conda environment using Mamba
echo "Activating Mamba environment: bmi206"
mamba activate bmi206 || { echo "Failed to activate Mamba environment"; exit 1; }
echo "Activated bmi206 env"

# Directory of TSV files
DIR="/wynton/protected/home/rotation/noahbaker/wynton/scratch/BMI206_NIC/noahs_project/simulations/out"

# Read all TSV files into an array
params=($(ls $DIR/*.tsv))

# Get the file for the current task
param="${params[$((SGE_TASK_ID - 1))]}"
BASENAME=$(basename "$param" .tsv)
echo "Processing file: $param"
echo "Output basename set to: $BASENAME"

# Run the Python script with the provided parameters
python3 /wynton/scratch/BMI206_NIC/tools/PRScsx/PRScsx.py \
--ref_dir=/wynton/scratch/BMI206_NIC/ref_datasets/1KG_datasets \
--bim_prefix=/wynton/scratch/BMI206_NIC/naracGenos-gaw16raw \
--sst_file="$param" \
--n_gwas=1000 \
--pop=EAS \
--phi=1e-2 \
--out_dir=/wynton/scratch/BMI206_NIC/noahs_project/prs_out/EAS \
--out_name="EAS_$BASENAME"

echo "Finished processing $BASENAME for EAS"
echo "Job completed on $(date)"
