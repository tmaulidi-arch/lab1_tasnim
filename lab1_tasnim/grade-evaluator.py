import csv
import sys
import os

def load_csv_data():
    filename = input("Enter the name of the CSV file to process (e.g., grades.csv): ")

    if not os.path.exists(filename):
        print(f"Error: The file '{filename}' was not found.")
        sys.exit(1)

    assignments = []
    try:
        with open(filename, mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                assignments.append({
                    'assignment': row['assignment'],
                    'group': row['group'],
                    'score': float(row['score']),
                    'weight': float(row['weight'])
                })
        
        if len(assignments) == 0:
            print(f"Error: The file '{filename}' is empty.")
            sys.exit(1)
            
        return assignments
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)

def evaluate_grades(data):
    print("\n--- Processing Grades ---")

    for assignment in data:
        if assignment['score'] < 0 or assignment['score'] > 100:
            print(f"Error: {assignment['assignment']} has invalid score {assignment['score']}")
            sys.exit(1)
    print("All scores are valid (0-100)")

    total_weight = sum(a['weight'] for a in data)
    formative_weight = sum(a['weight'] for a in data if a['group'].lower() == 'formative')
    summative_weight = sum(a['weight'] for a in data if a['group'].lower() == 'summative')

    if abs(total_weight - 100) > 0.01:
        print(f"Error: Total weight is {total_weight}, must be 100")
        sys.exit(1)
    if abs(formative_weight - 60) > 0.01:
        print(f"Error: Formative weight is {formative_weight}, must be 60")
        sys.exit(1)
    if abs(summative_weight - 40) > 0.01:
        print(f"Error: Summative weight is {summative_weight}, must be 40")
        sys.exit(1)
    print("Weights are valid (Total=100, Formative=60, Summative=40)")

    total_grade = 0
    for assignment in data:
        total_grade += (assignment['score'] * assignment['weight']) / 100

    gpa = (total_grade / 100) * 5.0
    print(f"Total Grade: {total_grade:.2f}%")
    print(f"GPA: {gpa:.2f}/5.0")

    formative_score = 0
    summative_score = 0

    for assignment in data:
        contribution = (assignment['score'] * assignment['weight']) / 100
        if assignment['group'].lower() == 'formative':
            formative_score += contribution
        else:
            summative_score += contribution

    formative_percent = (formative_score / 60) * 100
    summative_percent = (summative_score / 40) * 100

    print(f"Formative category: {formative_percent:.1f}%")
    print(f"Summative category: {summative_percent:.1f}%")

    if formative_percent >= 50 and summative_percent >= 50:
        print("STATUS: PASSED")
        print("No resubmission needed")
    else:
        print("STATUS: FAILED")

        failed = []
        for assignment in data:
            if assignment['group'].lower() == 'formative' and assignment['score'] < 50:
                failed.append(assignment)
        
        if failed:
            max_weight = max(f['weight'] for f in failed)
            print(f"Eligible for resubmission (highest weight: {max_weight}%):")
            for f in failed:
                if f['weight'] == max_weight:
                    print(f"  - {f['assignment']} (score: {f['score']}%)")

if __name__ == "__main__":
    course_data = load_csv_data()
    evaluate_grades(course_data)
