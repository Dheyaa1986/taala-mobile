import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "lib"


def strip_trailing_comment(line: str) -> str:
    in_single = in_double = in_triple = False
    i = 0
    n = len(line)
    while i < n:
        if in_triple:
            if line[i : i + 3] == "'''":
                in_triple = False
                i += 3
                continue
        elif in_single:
            if line[i] == "'" and (i + 1 >= n or line[i + 1] != "'"):
                in_single = False
            i += 1
            continue
        elif in_double:
            if line[i] == '"' and (i + 1 >= n or line[i + 1] != '"'):
                in_double = False
            i += 1
            continue
        else:
            if line[i : i + 3] == "'''":
                in_triple = True
                i += 3
                continue
            if line[i] == "'":
                in_single = True
                i += 1
                continue
            if line[i] == '"':
                in_double = True
                i += 1
                continue
            if line[i : i + 2] == "//":
                return line[:i].rstrip()
        i += 1
    return line


def strip_block_comments(text: str) -> str:
    result = []
    i = 0
    n = len(text)
    while i < n:
        if text[i : i + 2] == "/*":
            j = text.find("*/", i + 2)
            if j == -1:
                break
            i = j + 2
            continue
        result.append(text[i])
        i += 1
    return "".join(result)


def is_log_line(line: str) -> bool:
    s = line.strip()
    return s.startswith("log(") or s.startswith("print(")


def process_file(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    text = strip_block_comments(original)
    lines = text.splitlines()
    new_lines = []
    for line in lines:
        stripped = line.lstrip()
        if stripped.startswith("//") or stripped.startswith("///"):
            continue
        if is_log_line(line):
            continue
        new_lines.append(strip_trailing_comment(line))
    new_text = "\n".join(new_lines)
    if original.endswith("\n"):
        new_text += "\n"
    new_text = re.sub(r"\n{4,}", "\n\n\n", new_text)
    if new_text != original:
        path.write_text(new_text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = 0
    for path in ROOT.rglob("*.dart"):
        if process_file(path):
            changed += 1
    print(f"Updated {changed} files")


if __name__ == "__main__":
    main()
