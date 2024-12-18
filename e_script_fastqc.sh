#!/bin/bash

# Define paths
BASE_DIR="$HOME/Sara/Exame_Sara"
DATA_ANALYSIS_DIR="$BASE_DIR/data_analysis"
FASTQC_DIR="$DATA_ANALYSIS_DIR/02_fastqc"
RAW_DATA_DIR="$DATA_ANALYSIS_DIR/01_raw_data"
SAMPLES_FILE="$DATA_ANALYSIS_DIR/samplesnames.txt"

# Handle interruptions (Ctrl+C)
trap "echo 'Interrupted. Exiting...'; exit 1" SIGINT

# Get directory containing .gz files
echo "Enter the relative path to the directory with .gz files (from Exame_Sara):"
read RELATIVE_PATH
INPUT_DIR="$BASE_DIR/$RELATIVE_PATH"

# Check if the input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Directory '$INPUT_DIR' does not exist."
    exit 1
fi

# Activate conda environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate tools_qc

# Check if FastQC is installed
if ! command -v fastqc &> /dev/null; then
    echo "Error: FastQC not found in 'tools_qc' environment."
    exit 1
fi

# Create directories if needed
mkdir -p "$RAW_DATA_DIR" "$FASTQC_DIR"
echo "Sample Names:" > "$SAMPLES_FILE"

# Copy files to RAW_DATA_DIR and save sample names
echo "Copying .gz files and saving sample names..."
for FILE in "$INPUT_DIR"/*.gz; do
    if [ -f "$FILE" ]; then
        SAMPLE_NAME=$(basename "$FILE" | sed -E 's/(_R1.fastq.gz|_R2.fastq.gz)//')
        cp "$FILE" "$RAW_DATA_DIR/"
        if ! grep -q "$SAMPLE_NAME" "$SAMPLES_FILE"; then
            echo "$SAMPLE_NAME" >> "$SAMPLES_FILE"
        fi
    fi
done

# Run FastQC on paired-end files
echo "Running FastQC analysis..."
for FORWARD_READ in "$RAW_DATA_DIR"/*_R1.fastq.gz; do
    SAMPLE_NAME=$(basename "$FORWARD_READ" _R1.fastq.gz)
    REVERSE_READ="$RAW_DATA_DIR/${SAMPLE_NAME}_R2.fastq.gz"
    
    if [ -f "$REVERSE_READ" ]; then
        fastqc --threads 16 --noextract -o "$FASTQC_DIR" "$FORWARD_READ" "$REVERSE_READ"
    else
        fastqc --threads 16 --noextract -o "$FASTQC_DIR" "$FORWARD_READ"
    fi
done

# Completion message
echo "FastQC analysis completed. Reports stored in $FASTQC_DIR."
