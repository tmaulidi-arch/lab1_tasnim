#!/bin/bash

if [ ! -d "archive" ]; then
    mkdir archive
fi

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

mv grades.csv "archive/grades_${TIMESTAMP}.csv"

touch grades.csv

echo "[$(date +"%Y-%m-%d %H:%M:%S")] Moved grades.csv to archive/grades_${TIMESTAMP}.csv" >> organizer.log

echo "Archived to archive/grades_${TIMESTAMP}.csv"
