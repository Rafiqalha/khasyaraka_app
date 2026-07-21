import pytest
from bug_001 import sum_list, find_average


def test_sum_list_basic():
    assert sum_list([10, 20, 30, 40, 50]) == 150


def test_sum_list_single():
    assert sum_list([42]) == 42


def test_sum_list_empty():
    assert sum_list([]) == 0


def test_find_average():
    assert find_average([10, 20, 30]) == 20.0


def test_find_average_empty():
    assert find_average([]) == 0
