#!/usr/bin/env python3
"""Self-contained source ZIP, excluding all simulator/synthesis products."""
from pathlib import Path
import zipfile
ROOT = Path(__file__).resolve().parents[2]
out = ROOT / 'part3_matmul8' / 'deliverables'
out.mkdir(exist_ok=True)
paths = []
for dirname in ('rtl', 'tb', 'tools', 'synth'):
    paths += [p for p in (ROOT/'part3_matmul8'/dirname).rglob('*')
              if p.is_file() and '__pycache__' not in p.parts and p.suffix != '.pyc']
paths += [ROOT/'part3_matmul8'/n for n in ('Makefile', 'README.md')]
paths += [p for p in (ROOT/'part3_matmul8/docs').rglob('*') if p.is_file()
          and p.suffix in ('.md', '.json', '.tcl', '.svg', '.png')]
paths += list((ROOT/'part1_fp8/rtl').glob('*.sv'))
paths += [ROOT/'part1_fp8/tools/generate_vectors.py', ROOT/'part2_matmul4/matmul.v', ROOT/'env.cshrc']
target = out/'Lab3_Part3_Source.zip'
with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED) as z:
    for p in paths:
        data = p.read_bytes()
        if p.suffix in ('.v','.sv','.svh','.py','.tcl','.md','.json','.svg','.cshrc') or p.name in ('Makefile','env.cshrc'):
            data = data.replace(b'\r\n',b'\n')
        z.writestr(p.relative_to(ROOT).as_posix(),data)
print(target)
