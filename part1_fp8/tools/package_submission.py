#!/usr/bin/env python3
"""Package Part I sources/docs without compiler products or waveform databases."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

root = Path(__file__).resolve().parents[1]
dest = root / "build" / "lab3_part1_fp8.zip"
dest.parent.mkdir(exist_ok=True)
files = [root / "README.md", root / "Makefile", root / "files.f"]
for folder in ("rtl", "tb", "tools", "docs"):
    files += [p for p in (root / folder).rglob("*") if p.is_file()
              and "__pycache__" not in p.parts and p.suffix not in (".pyc",)]
with ZipFile(dest, "w", ZIP_DEFLATED) as archive:
    for file in sorted(files):
        archive.write(file, "part1_fp8/" + file.relative_to(root).as_posix())
print(dest)
print(f"Packaged {len(files)} source/documentation files; no build outputs included.")
