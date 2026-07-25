# Arrays — Your First Data Structure

An **array** is a sequence of values stored side-by-side in memory, each accessible by a numbered **index** starting from `0`.

:::adaptive
id: analogy
:::

## How Indexing Works

```
Index:   0        1         2         3
       ┌────┐  ┌────┐   ┌────┐   ┌────┐
       │ 10 │  │ 20 │   │ 30 │   │ 40 │
       └────┘  └────┘   └────┘   └────┘
```

The **first** element is always at index `0`, not `1`.
This is one of the most common sources of bugs — we call it an **off-by-one error**.

## Creating and Reading Arrays in Python

:::code
language: python
content: |
  scores = [85, 92, 78, 95]

  # Access the first score
  print(scores[0])   # → 85

  # Access the last score
  print(scores[3])   # → 95
  print(scores[-1])  # → 95 (Python shortcut!)
:::

## Traversing an Array

To visit every element, we use a **loop**.

:::code
language: python
content: |
  scores = [85, 92, 78, 95]

  total = 0
  for i in range(len(scores)):
      total += scores[i]

  average = total / len(scores)
  print(f"Average: {average}")
:::

> 💡 Notice `range(len(scores))` generates `0, 1, 2, 3` — exactly matching our indices.

:::adaptive
id: extra_example
:::

## Common Pitfall

What happens if we accidentally start from `1` instead of `0`?

:::code
language: python
content: |
  scores = [85, 92, 78, 95]

  total = 0
  for i in range(1, len(scores)):  # ← Bug! Skips index 0
      total += scores[i]

  print(f"Sum: {total}")   # → 265, not 350
:::

The first element `85` was silently skipped.
This is the exact bug you will fix in the upcoming **Mission**.
