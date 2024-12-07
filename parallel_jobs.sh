#!/bin/bash
#$ -N PRScsx_job_array
#$ -o out_BBJ/out_$TASK_ID.out
#$ -e out_BBJ/out_$TASK_ID.err
#$ -tc 10  # Limit the number of concurrent tasks
#$ -l h_rt=0:10:00
#$ -l mem_free=2G
#$ -cwd

# Source the Conda and Mamba setup scripts
source /wynton/protected/home/rotation/noahbaker/miniforge3/etc/profile.d/conda.sh
if [ -f "/wynton/protected/home/rotation/noahbaker/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "/wynton/protected/home/rotation/noahbaker/miniforge3/etc/profile.d/mamba.sh"
    echo "Mamba sourced"
fi

# Activate the Conda environment using Mamba
mamba activate bmi206 || { echo "Failed to activate Mamba environment"; exit 1; }
echo "Activated bmi206 env"

# Assuming the environment is already set up correctly
DIRS=(BBJ/*/)
INPUT_DIR="${DIRS[$((SGE_TASK_ID-1))]}"
INPUT_DIR="${INPUT_DIR%/}"  # Normalize INPUT_DIR to not end with a slash
echo "After normalization: $INPUT_DIR"

# Ensure the output directory exists
OUTPUT_DIR="out_BBJ"
mkdir -p "$OUTPUT_DIR"
echo "Checked for the output dirs"

# Set the folder name from the directory name
FOLDER_NAME="${INPUT_DIR##*/}"
echo "Set the folder name: $FOLDER_NAME"

# Find the 'cl_*' file within the input directory
SST_FILES=$(find "$INPUT_DIR" -type f -name "cl_*")
if [ $(echo $SST_FILES | wc -w) -gt 1 ]; then
    echo "Error: Multiple 'cl_*' files found, specify which one to use."
    exit 1
fi
SST_FILE=$SST_FILES
echo "cl_ file located: $SST_FILE"

echo "Running PRScsx"

# Run the Python script with the provided parameters
python3 /wynton/scratch/BMI206_NIC/tools/PRScsx/PRScsx.py \
    --ref_dir=/wynton/scratch/BMI206_NIC/ref_datasets/1KG_datasets \
    --bim_prefix=/wynton/scratch/BMI206_NIC/naracGenos-gaw16raw \
    --sst_file=/wynton/scratch/BMI206_NIC/$SST_FILE \
    --n_gwas=1000 \
    --pop=EUR \
    --phi=1e-2 \
    --out_dir=/wynton/scratch/BMI206_NIC/out_BBJ \
    --out_name=$FOLDER_NAME