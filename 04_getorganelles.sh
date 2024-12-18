#!/bin/bash

# Activate the conda environment for GetOrganelle
source $(conda info --base)/etc/profile.d/conda.sh
conda activate organelles

# Define the base directory and the path to the sample names file
BASE_DIR="$HOME/Sara/Exame_Sara/data_analysis"
SAMPLES_FILE="$BASE_DIR/samplesnames.txt"
OUTPUT_DIR="$BASE_DIR/04_getorganelles"

# Define the SeedDatabase and the reference sequence for the mitochondrial genome
SEED_DATABASE="$HOME/Sara/.GetOrganelle/SeedDatabase/SardinaMH329246.fasta"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Check if the sample names file exists
if [ ! -f "$SAMPLES_FILE" ]; then
    echo "Error: $SAMPLES_FILE does not exist."
    exit 1
fi

# Read the sample names from the file and loop through them
while IFS= read -r SAMPLE_NAME
do
    # Debug: Print the sample name
    echo "Processing sample: $SAMPLE_NAME"
    
    # Check if the files for the current sample exist
    R1_FILE="$BASE_DIR/03_fastp/${SAMPLE_NAME}_fp_R1.fastq.gz"
    R2_FILE="$BASE_DIR/03_fastp/${SAMPLE_NAME}_fp_R2.fastq.gz"

    echo "Looking for files: $R1_FILE, $R2_FILE"

    # Check if the files exist before running the command
    if [ -f "$R1_FILE" ] && [ -f "$R2_FILE" ]; then
        # Run the GetOrganelle command for this sample in the background
        echo "Running GetOrganelle for sample: $SAMPLE_NAME with parameters:"
        echo "get_organelle_from_reads.py -1 $R1_FILE -2 $R2_FILE -R 5 -k 21,45,65 -t 16 -F animal_mt -s $SEED_DATABASE -o $OUTPUT_DIR/mtDNA_$SAMPLE_NAME"

        get_organelle_from_reads.py -1 "$R1_FILE" -2 "$R2_FILE" \
            -R 5 -k 21,45,65 -t 16 -F animal_mt \
            -s "$SEED_DATABASE" -o "$OUTPUT_DIR/mtDNA_$SAMPLE_NAME" &

    else
        echo "Warning: Missing input files for sample $SAMPLE_NAME. Skipping..."
    fi

done < "$SAMPLES_FILE"

# Wait for all background processes to finish
wait

# Done
echo "GetOrganelle analysis completed for all samples."

