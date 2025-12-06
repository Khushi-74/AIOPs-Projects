#!/bin/bash

# VM Health Check Script for Ubuntu EC2 Instances
# Description: Analyzes VM health by checking CPU, memory, and disk usage
# Status: HEALTHY if all metrics < 60%, UNHEALTHY otherwise
# Options: Pass "explain" as argument to see detailed reasons

THRESHOLD=60
EXPLAIN=false

# Parse command-line arguments
for arg in "$@"; do
    if [[ "$arg" == "explain" ]]; then
        EXPLAIN=true
    fi
done

# Function to get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d'.' -f1
}

# Function to get memory usage
get_memory_usage() {
    total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    available_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    used_mem=$((total_mem - available_mem))
    echo $((used_mem * 100 / total_mem))
}

# Function to get disk usage
get_disk_usage() {
    df / | tail -1 | awk '{print $5}' | cut -d'%' -f1
}

# Collect metrics
CPU_USAGE=$(get_cpu_usage)
MEM_USAGE=$(get_memory_usage)
DISK_USAGE=$(get_disk_usage)

# Determine health status
if [ "$CPU_USAGE" -lt "$THRESHOLD" ] && [ "$MEM_USAGE" -lt "$THRESHOLD" ] && [ "$DISK_USAGE" -lt "$THRESHOLD" ]; then
    HEALTH_STATUS="HEALTHY"
else
    HEALTH_STATUS="UNHEALTHY"
fi

# Print health status
echo "VM Status: $HEALTH_STATUS"

# Print detailed explanation if requested
if [ "$EXPLAIN" = true ]; then
    echo "Detailed Explanation:"
    if [ "$CPU_USAGE" -lt "$THRESHOLD" ]; then
        echo "CPU Usage: $CPU_USAGE% (Healthy)"
    else
        echo "CPU Usage: $CPU_USAGE% (Unhealthy)"
    fi

    if [ "$MEM_USAGE" -lt "$THRESHOLD" ]; then
        echo "Memory Usage: $MEM_USAGE% (Healthy)"
    else
        echo "Memory Usage: $MEM_USAGE% (Unhealthy)"
    fi

    if [ "$DISK_USAGE" -lt "$THRESHOLD" ]; then
        echo "Disk Usage: $DISK_USAGE% (Healthy)"
    else
        echo "Disk Usage: $DISK_USAGE% (Unhealthy)"
    fi
fi