#!/bin/bash

# Script to perform Fastp analysis on paired-end files listed in samplesnames.txt
# Uses predefined parameters and outputs results with a specific naming convention

# Define directories
BASE_DIR="$HOME/Sara/Exame_Sara"  
DATA_ANALYSIS_DIR="$BASE_DIR/data_analysis" 
RAW_DATA_DIR="$DATA_ANALYSIS_DIR/01_raw_data"
FASTP_DIR="$DATA_ANALYSIS_DIR/03_fastp"
SAMPLES_FILE="$DATA_ANALYSIS_DIR/samplesnames.txt"

# Function to handle interruptions
function handle_interrupt {
    echo -e "\nProcess interrupted by the user. Exiting gracefully..."
    exit 1
}

# Trap SIGINT (Ctrl+C) to call the interrupt handler
trap handle_interrupt SIGINT

# Check if samplesnames.txt exists
if [ ! -f "$SAMPLES_FILE" ]; then
    echo "Error: samplesnames.txt not found in $DATA_ANALYSIS_DIR."
    exit 1
fi

# Activate the Conda environment 'tools_qc'
echo "Activating tools_qc environment..."
source $(conda info --base)/etc/profile.d/conda.sh
conda activate tools_qc

# Check if Fastp is installed in the 'tools_qc' environment
if ! command -v fastp &> /dev/null; then
    echo "Error: Fastp is not installed in the 'tools_qc' environment."
    exit 1
fi

# Create necessary directories if they don't exist
mkdir -p $FASTP_DIR

# Start the timer
start_time=$(date +%s)

# Perform Fastp analysis on paired-end files listed in samplesnames.txt
echo "Starting Fastp analysis on paired-end files in $RAW_DATA_DIR..."

while read -r SAMPLE_NAME; do
    if [[ "$SAMPLE_NAME" == "Sample Names:" || -z "$SAMPLE_NAME" ]]; then
        continue  # Skip the header or empty lines
    fi

    # Define file paths for R1 and R2
    FORWARD_READ="$RAW_DATA_DIR/${SAMPLE_NAME}_R1.fastq.gz"
    REVERSE_READ="$RAW_DATA_DIR/${SAMPLE_NAME}_R2.fastq.gz"

    # Check if both R1 and R2 files exist
    if [ -f "$FORWARD_READ" ] && [ -f "$REVERSE_READ" ]; then
        # Define output file names
        OUTPUT_R1="$FASTP_DIR/${SAMPLE_NAME}_fp_R1.fastq.gz"
        OUTPUT_R2="$FASTP_DIR/${SAMPLE_NAME}_fp_R2.fastq.gz"
        REPORT_HTML="$FASTP_DIR/${SAMPLE_NAME}.html"
        FAILED_OUTPUT="$FASTP_DIR/${SAMPLE_NAME}_failed.txt"

        # Echo with the parameters being used
        echo "Running Fastp on sample: $SAMPLE_NAME"
        echo "Parameters:  -l 80 -q 20 -D -p -g"

        # Run Fastp with predefined parameters
        fastp -i "$FORWARD_READ" -I "$REVERSE_READ" \
              -o "$OUTPUT_R1" -O "$OUTPUT_R2" \
              -l 80 -q 20 -D -p -g \
              --html "$REPORT_HTML" --json "$FASTP_DIR/${SAMPLE_NAME}.json" --failed_out "$FAILED_OUTPUT"

        echo "Fastp completed for sample: $SAMPLE_NAME"
    else
        echo "Warning: Missing R1 or R2 file for $SAMPLE_NAME. Skipping."
    fi
done < "$SAMPLES_FILE"

# Finished
echo "Fastp analysis completed. Results are stored in $FASTP_DIR."

# Record end time
end_time=$(date +%s)

# Calculate the elapsed time
elapsed_time=$((end_time - start_time))

echo "The script took $elapsed_time seconds to run."

