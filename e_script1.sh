#!/bin/bash

# Script 1: Create Directory Structure
# This script creates the directories needed for data analysis.

# Define the base directory
BASE_DIR="$HOME/Sara/Exame_Sara/data_analysis"

# Create the directory structure
mkdir -p $BASE_DIR/{01_raw_data,02_fastqc,03_fastp,04_getorganelles}

# Print the structure
echo "Directory structure created at: $BASE_DIR"

# # Display the directory structure using 'find'
echo "Directory structure:" 
find $BASE_DIR -type d | sort -V
