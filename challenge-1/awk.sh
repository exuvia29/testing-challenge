#!/bin/bash

# Directory containing the log files (current directory)
log_dir="./"

# Get the current time and the time 10 minutes ago, including seconds
current_time=$(date +"%d/%b/%Y:%H:%M:%S")
start_time=$(date -d "10 minutes ago" +"%d/%b/%Y:%H:%M:%S")

# Capture the script execution time
execution_time=$(date +"%Y-%m-%d %H:%M:%S")

# Display the script execution time
echo "Script executed at $execution_time"

# Loop through each .log file in the directory and count HTTP 500 errors from the last 10 minutes
for log in "$log_dir"/*.log; do
    if [[ -f "$log" ]]; then
        # Use awk to filter logs based on timestamps and count HTTP 500 errors
        count=$(awk -v start="$start_time" -v end="$current_time" '
        {
            # Extract the timestamp in the log line
            if ($0 ~ /\[[0-9]{2}\/[A-Za-z]{3}\/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2} [+-][0-9]{4}\]/) {
                logtime = substr($4, 2);  # Remove the opening '[' from timestamp
                if (logtime >= start && logtime <= end && $0 ~ / 500 /) {
                    count++;
                }
            }
        }
        END {print count+0}' "$log")

        echo "There were $count HTTP 500 errors in $(basename "$log") in the last 10 minutes"
    else
        echo "$log does not exist."
    fi
done
