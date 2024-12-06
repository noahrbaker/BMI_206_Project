#!/bin/bash

# Define input and output directories
input_directory="plink_in/EAS"
output_directory="plink_out/EAS"

# Create output directory if it doesn't exist
mkdir -p "$output_directory"

# Get list of unique prefixes
prefixes=$(ls "$input_directory" | grep -oP 'EAS_[^_]+_[^_]+_r[^_]_plink' | sort | uniq)

# Loop over each prefix
for prefix in $prefixes; do
  # Create an output file name based on the prefix
  output_file="$output_directory/${prefix%_r}_out"
  
  # Concatenate all files with the current prefix
  /wynton/scratch/BMI206_NIC/tools/plink --bfile /wynton/scratch/BMI206_NIC/naracGenos-gaw16raw --score "$input_directory"/${prefix}* --out "$output_file"
  echo "Scored ${output_file}."
done

echo "Files formatted successfully."

