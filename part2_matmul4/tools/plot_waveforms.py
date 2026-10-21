"""Render actual VCS VCD transitions; no generated or expected traces."""
from pathlib import Path
import re
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs' / 'waveforms'
OUT.mkdir(parents=True, exist_ok=True)

def read_vcd(path):
    scopes, signals, values = [], {}, {}
    t = 0
    header = True
    for line in path.read_text().splitlines():
        s = line.split()
        if not s: continue
        if header:
            if s[0] == '$scope': scopes.append(s[2])
            elif s[0] == '$upscope': scopes.pop()
            elif s[0] == '$var' and scopes == ['tb_part2']:
                signals[s[4]] = (s[3], int(s[2])); values[s[3]] = []
            elif s[0] == '$enddefinitions': header = False
        elif line.startswith('#'): t = int(line[1:]) / 1000 # VCS timescale 1 ps -> ns
        elif line[0] in 'bB':
            if len(s) == 2 and s[1] in values: values[s[1]].append((t, s[0][1:]))
        elif line[0] in '01xXzZ' and line[1:] in values:
            values[line[1:]].append((t,line[0]))
    return {n:(w,values[c]) for n,(c,w) in signals.items()}

def render(data, names, limits, title, filename, markers=()):
    fig, ax = plt.subplots(figsize=(15, 1.1+len(names)*.48))
    left,right=limits
    for i,name in enumerate(names):
        y=len(names)-1-i
        width,events=data[name]
        ev=events+[(right,events[-1][1])]
        for (t,v),(end,_) in zip(ev,ev[1:]):
            a,b=max(left,t),min(right,end)
            if b<=a: continue
            known=not any(c.lower() in 'xz' for c in v)
            color='#126b59' if known else '#ae5862'
            if width==1 and known:
                yy=y+.13+.57*int(v,2)
                ax.plot([a,b],[yy,yy],color=color,lw=1.2)
                if left<t<right: ax.plot([t,t],[y+.13,y+.70],color=color,lw=.8)
            else:
                ax.fill_between([a,b],y+.13,y+.70,color=color,alpha=.08)
                ax.plot([a,b,b,a,a],[y+.13,y+.13,y+.70,y+.70,y+.13],color=color,lw=.7)
                if name.endswith('flags') or name=='expected_flags': label=f'{int(v,2):05b}' if known else 'X'
                elif width<=10 or name in ('checked_entries','testcase_id'): label=str(int(v,2)) if known else 'X'
                else: label=f'{int(v,2):0{(width+3)//4}X}' if known else 'X'
                if (b-a)/(right-left)>max(.018,len(label)*.006):
                    ax.text((a+b)/2,y+.41,label,ha='center',va='center',fontsize=8,family='monospace')
        ax.axhline(y,color='#dbe4e8',lw=.6)
    for time,label in markers:
        ax.axvline(time,color='#b7651a',ls='--',lw=.8)
        ax.text(time,len(names)+.08,label,rotation=0,ha='center',va='bottom',fontsize=8,color='#8c4c16')
    ax.set_xlim(left,right); ax.set_ylim(-.1,len(names)+.8)
    ax.set_yticks([len(names)-1-i+.4 for i in range(len(names))],names,fontsize=9)
    ax.set_xlabel('Simulation time (ns) | 32-bit data hex; flags binary; other buses decimal',fontsize=9)
    ax.set_title(title,loc='left',fontsize=14,pad=14,weight='bold')
    ax.grid(axis='x',alpha=.15); ax.spines[['top','right','left']].set_visible(False)
    fig.tight_layout(); fig.savefig(OUT/filename,dpi=180); plt.close(fig)

for kind,description in [('clean','Case 1: no exceptions'),('exception','Case 2: finite overflow')]:
    data=read_vcd(ROOT/'build'/f'{kind}.vcd')
    render(data,['clk','resetn','pe_resetn','start','core_start','done','exception_flags','c_write_enable','c_write_addr','checked_entries'],(0,720),description+' - complete operation',kind+'_overview.png',[(200,'Start'),(590,'Done'),(640,'16 checks')])
    render(data,['clk','resetn','load_we','load_addr','load_a','load_b'],(60,180),description+' - input RAM loading',kind+'_loading.png',[(90,'A/B[0]'),(110,'A/B[1]'),(130,'A/B[2]'),(150,'A/B[3]')])
    render(data,['clk','done','exception_flags','pe33_product_flags','pe33_flags','c_write_enable','c_write_addr','c_write_data','final_c0','final_c1','final_c2','final_c3','checked_entries'],(430,720),description+' - flags and output RAM writes',kind+'_output.png',[(550,'C[0]'),(570,'C[1]'),(590,'C[2] / done'),(610,'C[3]'),(640,'RAM check')])
    print(kind, 'flag transitions:',data['exception_flags'][1])
    print(kind, 'product flag transitions:',data['pe33_product_flags'][1])
