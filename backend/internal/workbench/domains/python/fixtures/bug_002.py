# Bug 002: Mutable Default Argument
# This function is supposed to append items to a list and return it.
# But something weird happens when called multiple times.

def add_item(item, items=[]):  # BUG: mutable default argument
    items.append(item)
    return items


def build_shopping_list(new_items):
    result = []
    for item in new_items:
        result = add_item(item)
    return result


if __name__ == "__main__":
    list1 = build_shopping_list(["apple", "banana"])
    print(f"List 1: {list1}")

    list2 = build_shopping_list(["milk", "bread"])
    print(f"List 2: {list2}")
    # Expected: ["milk", "bread"]
    # Actual:   ["apple", "banana", "milk", "bread"]
