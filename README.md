# Deploy_agent_-tmaulidi-arch
 What I Did

 1. Created the Script
- Built `setup_project.sh` to automate project setup
- Added directory creation: `attendance_tracker_{input}/Helpers/` and `reports/`
- Generated all required files with cotent

 2. Implemented Dynamic Configuration
- Used `read` command to get user input
- Added default values (75% warning, 50% failure)
- Used `sed -i` to update config.json in-place
- Added validation for numbers and range(0-100)
 3. Added Signal Trap
- Created `cleanup()` function for Ctrl+C
- Archives directory as `attendance_tracker_{input}_archive.tar.gz`
- Deletes incomplete directory automatically

 4. Environment Validation
- Checks if Python 3 is installed using `python3 --version`
- Displays success message or warning

 5. GitHub Setup
- Initialized git repository
- Committed files with clear messages
- Pushed to GitHub: `Deploy_agent_-tmaulidi-arch`
