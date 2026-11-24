import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from app import greet


def test_greet():
    assert greet(" Jimin ") == "Hello, Jimin!"


def test_greet_empty():
    with pytest.raises(ValueError):
        greet("  ")
