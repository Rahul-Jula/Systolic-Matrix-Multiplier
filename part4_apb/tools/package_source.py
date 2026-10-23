"""Explicit source allowlist; excludes simulator products and existing ZIPs."""
from pathlib import Path
import hashlib
import zipfile

root=Path(__file__).resolve().parents[2]
part=root/'part4_apb'
paths=[root/p for p in [
    'env.cshrc','part1_fp8/rtl/fp8_round_pack.sv','part1_fp8/rtl/fp8_adder.sv',
    'part1_fp8/rtl/fp8_multiplier.sv','part2_matmul4/matmul.v',
    'part3_matmul8/rtl/matmul_8x8.sv','part3_matmul8/rtl/matmul_with_ram_8x8.sv',
    'baseline/apb_slave.v','baseline/example_tb.v']]
paths += [part/'Makefile',part/'README.md',part/'.gitignore']
for folder,extensions in [('rtl',{'.sv'}),('tb',{'.sv','.svh'}),
                          ('tools',{'.py'}),('docs',{'.md','.json','.tcl'})]:
    paths += [p for p in (part/folder).rglob('*') if p.is_file() and p.suffix in extensions]
out=part/'deliverables'; out.mkdir(exist_ok=True)
archive=out/'Lab3_Part4_Source.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
    for path in sorted(set(paths)):
        z.write(path,path.relative_to(root).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
(out/'SHA256SUMS.txt').write_text(hashlib.sha256(archive.read_bytes()).hexdigest()+'  '+archive.name+'\n')
print(archive)
