#!/bin/bash

# Script to execute each line in commands.log sequentially; assumes 1 command per line
# Each command will wait for the previous one to finish before starting

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if commands.log exists
if [ ! -f "commands.log" ]; then
    echo -e "${RED}Error: commands.log file not found in current directory${NC}"
    exit 1
fi

# Get total number of lines
total_lines=$(wc -l < commands.log)
echo -e "${BLUE}Found ${total_lines} commands to execute${NC}"
echo

# Initialize counters
current_line=0
successful_commands=0
failed_commands=0

# Read commands.log line by line
while IFS= read -r line; do
    current_line=$((current_line + 1))

    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi

    echo -e "${BLUE}[${current_line}/${total_lines}] Executing command:${NC}"
    echo -e "${YELLOW}$line${NC}"
    echo

    # Execute the command
    eval "$line"
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ Command ${current_line} completed successfully${NC}"
        successful_commands=$((successful_commands + 1))
    else
        echo -e "${RED}✗ Command ${current_line} failed with exit code $exit_code${NC}"
        failed_commands=$((failed_commands + 1))
        echo -e "${YELLOW}Continuing with next command...${NC}"
    fi

    echo
    echo "----------------------------------------"
    echo

done < commands.log

# Print summary
echo -e "${BLUE}=== Execution Summary ===${NC}"
echo -e "${GREEN}Successful commands: ${successful_commands}${NC}"
echo -e "${RED}Failed commands: ${failed_commands}${NC}"
echo -e "${BLUE}Total commands processed: ${current_line}${NC}"

if [ $failed_commands -eq 0 ]; then
    echo -e "${GREEN}All commands completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}Some commands failed. Please review the output above.${NC}"
    exit 1
fi
