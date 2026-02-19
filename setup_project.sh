nano setup_project.sh
#!/bin/bash

echo "enter a project name"
read input
if [ -z "$input" ]; then
  echo "Project name cannot be empty. Exiting."
  exit 1
fi
tasi="attendance_tracker_${input}"
mkdir -p "$tasi/Helpers"
mkdir -p "$tasi/reports"
touch "$tasi/attendance_checker.py"
touch "$tasi/Helpers/assets.csv"
touch "$tasi/Helpers/config.json"
touch "$tasi/reports/reports.log"
cat << 'EOF' > "$tasi/attendance_checker.py"
import csv
import json
import os
from datetime import datetime
def run_attendance_check():
# 1. Load Config
with open('Helpers/config.json', 'r') as f:
config = json.load(f)
# 2. Archive old reports.log if it exists
if os.path.exists('reports/reports.log'):
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
os.rename('reports/reports.log',
f'reports/reports_{timestamp}.log.archive')
# 3. Process Data
with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log',
'w') as log:
reader = csv.DictReader(f)
total_sessions = config['total_sessions']
log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
for row in reader:
name = row['Names']
email = row['Email']
attended = int(row['Attendance Count'])
# Simple Math: (Attended / Total) * 100
attendance_pct = (attended / total_sessions) * 100
message = ""
if attendance_pct < config['thresholds']['failure']:
message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}
%. You will fail this class."
elif attendance_pct < config['thresholds']['warning']:
message = f"WARNING: {name}, your attendance is
{attendance_pct:.1f}%. Please be careful."
if message:
if config['run_mode'] == "live":
log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}
\n")
print(f"Logged alert for {name}")
else:
print(f"[DRY RUN] Email to {email}: {message}")
if __name__ == "__main__":
run_attendance_check()

EOF
cat << 'EOF' > "$tasi/Helpers/assets.csv"
Email                        Names             Attendance Count           Absence Count
alice@example.com            Alice Johnson         14                        1 
bob@example.com              Bob Smith             7                         8
charlie@example.com          Charlie Davis         4                         11
diana@example.com            Diana Prince          15                         0
EOF

cat << 'EOF' > "$tasi/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}

EOF

cat << 'EOF' > "$tasi/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your
attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie
Davis, your attendance is 26.7%. You will fail this class

EOF
	
cleanup() {
    echo -e "\n️  Script interrupted! Creating archive..."
    if [ -n "$tasi" ] && [ -d "$tasi" ]; then
        archive_name="attendance_tracker_${input}_archive.tar.gz"
        tar -czf "$archive_name" "$tasi" 2>/dev/null
        echo " Archive created: $archive_name"
        rm -rf "$tasi"
        echo " Incomplete directory deleted"
    fi
    exit 1
}
trap cleanup SIGINT
echo "Enter a project name:"
read input

if [ -z "$input" ]; then
    echo "Project name cannot be empty. Exiting."
    exit 1
fi
tasi="attendance_tracker_${input}"
echo " Creating project: $tasi"

mkdir -p "$tasi/Helpers"
mkdir -p "$tasi/reports"
echo  " Directories created"
touch "$tasi/attendance_checker.py"
touch "$tasi/Helpers/assets.csv"
touch "$tasi/Helpers/config.json"
touch "$tasi/reports/reports.log"
echo " Empty files created"

echo " Setup complete!"
echo "Project created in: $tasi"
echo ""
echo "To test the trap:"
echo "Run this script again and press Ctrl+C during execution"

cd "$tasi" || exit 1
read -p "Do you want to update attendance thresholds? (y/n): " update_choice
if [[ "$update_choice" == "y" || "$update_choice" == "Y" ]]; then
 read -p "Enter warning threshold % [default: 75]: " warning_val
    warning_val=${warning_val: -75}
read -p "Enter failure threshold % [default: 50]: " failure_val
    failure_val=${failure_val: -50}

if [[ -n "$warning_val" && ! "$warning_val" =~ ^[0-9]+$ ]] || \
   [[ -n "$failure_val" && ! "$failure_val" =~ ^[0-9]+$ ]]; then
    echo "Error: Thresholds must be numbers"

        exit 1
    fi
 if [[ "$warning_val" -lt 0 || "$warning_val" -gt 100 ]] || \
       [[ "$failure_val" -lt 0 || "$failure_val" -gt 100 ]]; then
        echo "Error: Thresholds must be between 0 and 100"
        exit 1
    fi
 if [ -f "Helpers/config.json" ]; then
sed -i 's/"warning": [0-9]\+/"warning": '"$warning_val"'/' Helpers/config.json
sed -i 's/"failure": [0-9]\+/"failure": '"$failure_val"'/' Helpers/config.json

        echo " Thresholds updated successfully!"
        echo "   Warning: $warning_val%"
        echo "   Failure: $failure_val%"
echo -e "\nUpdated config.json:"
        cat Helpers/config.json
    else
        echo " Error: config.json not found at Helpers/config.json"
        exit 1
 fi
else
    echo "Keeping default thresholds (Warning: 75%, Failure: 50%)"
fi
echo "  "
if python3 --version >/dev/null 2>&1; then
echo "python3 is installed."
fi
echo "setup compled."
