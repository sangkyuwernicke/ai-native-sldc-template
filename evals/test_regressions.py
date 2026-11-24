"""회귀 eval: 인시던트/반복 실수가 생길 때마다 케이스를 추가한다."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from app import greet


def test_no_trailing_whitespace_in_greeting():
    assert greet("  A  ") == "Hello, A!"
