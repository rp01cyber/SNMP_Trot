#!/bin/bash

# Default values
IP_FILE=""
OUTPUT_FILE=""

# Help message
usage() {
    echo "Usage: $0 -i <ip_file> -o <output_file>"
    echo "  -i    Path to the input file containing IP addresses (one per line)"
    echo "  -o    Path to the output file where results will be saved"
    exit 1
}

# Parse flags
while getopts ":i:o:" opt; do
  case $opt in
    i) IP_FILE="$OPTARG"
    ;;
    o) OUTPUT_FILE="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        usage
    ;;
    :) echo "Option -$OPTARG requires an argument." >&2
       usage
    ;;
  esac
done

# Check for required arguments
if [[ -z "$IP_FILE" || -z "$OUTPUT_FILE" ]]; then
    usage
fi

# Empty the output file if it exists
> "$OUTPUT_FILE"

# Loop through each IP in the file
while IFS= read -r ip; do
    [[ -z "$ip" ]] && continue  # skip empty lines
    echo "Running SNMPWALK on $ip..."

    {
        echo "=== Results for $ip ==="
        snmpwalk -v2c -c public "$ip" 2>/dev/null | grep 'STRING: "'
        echo ""
    } >> "$OUTPUT_FILE"

done < "$IP_FILE"

echo "Done. Results saved in $OUTPUT_FILE"
