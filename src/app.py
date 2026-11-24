def greet(name: str) -> str:
    """샘플 함수: 실제 프로젝트 코드로 교체하세요."""
    name = name.strip()
    if not name:
        raise ValueError("name must not be empty")
    return f"Hello, {name}!"
