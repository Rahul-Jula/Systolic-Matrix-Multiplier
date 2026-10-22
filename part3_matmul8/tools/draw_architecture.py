#!/usr/bin/env python3
"""Write a vector diagram matching the implemented six-bank, four-tile RTL."""
from pathlib import Path
from xml.sax.saxutils import escape
from math import hypot
out = Path(__file__).resolve().parents[1]/'docs/figures'
out.mkdir(parents=True, exist_ok=True)
svg = ['<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="770" viewBox="0 0 1000 770">',
       '<defs><marker id="a" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0 0L8 4L0 8Z" fill="#2563eb"/></marker>',
       '<marker id="c" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0 0L8 4L0 8Z" fill="#c2410c"/></marker></defs>',
       '<rect width="1000" height="770" fill="white"/>']


def text(x,y,s,size=16,color='#172033',anchor='middle'):
    svg.append(f'<text x="{x}" y="{y}" text-anchor="{anchor}" font-family="Arial, sans-serif" font-size="{size}" fill="{color}">{escape(s)}</text>')


def box(x,y,w,h,lines,tile=False):
    svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="{"#eaf2ff" if tile else "#f1f5f9"}" stroke="#64748b" stroke-width="1.5"/>')
    for n,s in enumerate(lines):
        text(x+w/2,y+27+n*23,s,17 if n==0 else 14)


def arrow(points,label,x,y,c=False):
    svg.append(f'<polyline points="{points}" fill="none" stroke="{"#c2410c" if c else "#2563eb"}" stroke-width="2.4" marker-end="url(#{"c" if c else "a"})"/>')
    # Explicit triangles render in both browsers and the PDF SVG importer.
    coords=[tuple(map(float,p.split(','))) for p in points.split()]
    x0,y0=coords[-2]; x1,y1=coords[-1]
    length=hypot(x1-x0,y1-y0); ux=(x1-x0)/length; uy=(y1-y0)/length
    bx=x1-11*ux; by=y1-11*uy
    head=f'{x1},{y1} {bx-4*uy},{by+4*ux} {bx+4*uy},{by-4*ux}'
    svg.append(f'<polygon points="{head}" fill="{"#c2410c" if c else "#2563eb"}"/>')
    text(x,y,label,14,'#c2410c' if c else '#2563eb')


text(500,35,'Part III: 8 x 8 FP8 systolic array',27)
text(500,63,'Four unchanged 4 x 4 tiles; 64 physical PEs; final_mat_mul_size = 8',16)
box(280,95,190,70,['B left RAM','B[k][0..3], 32 bits'])
box(680,95,190,70,['B right RAM','B[k][4..7], 32 bits'])
box(20,225,190,75,['A top RAM','A[0..3][k], 32 bits'])
box(20,440,190,75,['A bottom RAM','A[4..7][k], 32 bits'])
box(280,220,190,110,['T00: 4 x 4 FP8','a_loc=0, b_loc=0','C rows 0..3, cols 0..3'],True)
box(680,220,190,110,['T01: 4 x 4 FP8','a_loc=0, b_loc=1','C rows 0..3, cols 4..7'],True)
box(280,435,190,110,['T10: 4 x 4 FP8','a_loc=1, b_loc=0','C rows 4..7, cols 0..3'],True)
box(680,435,190,110,['T11: 4 x 4 FP8','a_loc=1, b_loc=1','C rows 4..7, cols 4..7'],True)
box(70,610,250,70,['C top RAM','C[0..3][k], eight 32-bit words'])
box(620,610,250,70,['C bottom RAM','C[4..7][k], eight 32-bit words'])
arrow('375,165 375,220','B, 32',416,196)
arrow('775,165 775,220','B, 32',816,196)
arrow('210,257 280,257','A',245,247)
arrow('210,472 280,472','A',245,462)
arrow('470,255 680,255','A right, 32 bits',575,243)
arrow('470,475 680,475','A right, 32 bits',575,462)
arrow('375,330 375,435','B down, 32 bits',432,386)
arrow('775,330 775,435','B down, 32 bits',850,386)
arrow('680,305 470,305','C shift left, 32 bits',575,325,True)
arrow('680,525 470,525','C shift left, 32 bits',575,545,True)
arrow('300,330 245,360 245,610','C top',204,552,True)
arrow('375,545 375,585 745,585 745,610','C bottom',534,575,True)
text(500,713,'Common clock/reset/run; bases and strides shared across all tiles; all masks = 1111',16)
text(500,739,'Four 5-bit sticky exception vectors -> bitwise OR; own C address/count and global completion',16)
svg.append('</svg>')
(out/'microarchitecture.svg').write_text('\n'.join(svg)+'\n',encoding='utf-8')
print(out/'microarchitecture.svg')
