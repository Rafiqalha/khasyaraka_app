# Bug 003: Silent Integer Division
# This program calculates student grade percentages.
# But the results are always wrong.

def calculate_percentage(score, total):
    return score / total * 100  # BUG in Python 2 mindset: integer division
    # Actually this works fine in Python 3, the real bug is below


def grade_report(students):
    report = {}
    for name, score, total in students:
        pct = calculate_percentage(score, total)
        if pct >= 90:
            grade = "A"
        elif pct >= 80:
            grade = "B"
        elif pct >= 70:
            grade = "C"
        elif pct >= 60:
            grade = "D"
        else:
            grade = "F"
        report[name] = {"percentage": pct, "grade": grade}

    # BUG: returns last student's data only, not the full report
    return {"percentage": pct, "grade": grade}


if __name__ == "__main__":
    students = [
        ("Alice", 85, 100),
        ("Bob", 72, 100),
        ("Charlie", 95, 100),
    ]
    result = grade_report(students)
    print(f"Report: {result}")
