"""
Test Safe Skill - A simple, secure skill for testing purposes.

This skill demonstrates safe coding practices and should pass security scans.
"""

def greet(name: str) -> str:
    """
    Safely greet a user by name.
    
    Args:
        name: The name to greet
        
    Returns:
        A greeting message
    """
    if not isinstance(name, str):
        raise TypeError("Name must be a string")
    
    # Safe string formatting
    return f"Hello, {name}!"


def add_numbers(a: int, b: int) -> int:
    """
    Safely add two numbers.
    
    Args:
        a: First number
        b: Second number
        
    Returns:
        Sum of a and b
    """
    return a + b


def read_file_safely(filepath: str) -> str:
    """
    Read a file with basic validation.
    
    Args:
        filepath: Path to file
        
    Returns:
        File contents
    """
    # Basic validation
    if not filepath or ".." in filepath:
        raise ValueError("Invalid filepath")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        return f.read()


if __name__ == "__main__":
    print(greet("World"))
    print(f"2 + 2 = {add_numbers(2, 2)}")
