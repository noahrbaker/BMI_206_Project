#!/bin/bash

# Define input and output directories
input_directory="prs_out/EAS"
output_directory="prs_out/EAS_cat"

# Create output directory if it doesn't exist
mkdir -p "$output_directory"

# Get list of unique prefixes
prefixes=$(ls "$input_directory" | grep -oP 'EAS_[^_]+_[^_]+_r[^_]' | sort | uniq)

# Loop over each prefix
for prefix in $prefixes; do
  # Create an output file name based on the prefix
  output_file="$output_directory/${prefix%_r}_concat.txt"
  
  # Concatenate all files with the current prefix
  cat "$input_directory"/${prefix}* > "$output_file"
done

echo "Files concatenated successfully."
