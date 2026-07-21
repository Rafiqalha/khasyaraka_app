# Bug 001: Off-by-one Error in List Processing
# The function should return the sum of all elements in a list.
# But it has a subtle bug.

def sum_list(numbers):
    total = 0
    for i in range(1, len(numbers)):  # BUG: starts at index 1, skipping first element
        total += numbers[i]
    return total


def find_average(numbers):
    if len(numbers) == 0:
        return 0
    return sum_list(numbers) / len(numbers)


if __name__ == "__main__":
    data = [10, 20, 30, 40, 50]
    print(f"Sum: {sum_list(data)}")
    print(f"Average: {find_average(data)}")
