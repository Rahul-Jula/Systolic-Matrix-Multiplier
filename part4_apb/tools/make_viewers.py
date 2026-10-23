"""Create nWave panels using actual exception simulation transaction times."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
log = (root/'reports/exception_sim.log').read_text()
if 'PART4 SIMULATION PASS total_checked=64' not in log:
    raise SystemExit('A passing exception simulation log is required.')
start = int(re.search(r'EVENT START t=\s*(\d+) ns', log)[1])-1
writes = [int(x) for x in re.findall(r'EVENT C_WRITE t=\s*(\d+) ns', log)]
if len(writes) != 8:
    raise SystemExit('Expected exactly eight committed C writes.')
tx = [(kind, int(t), int(addr,16), int(data,16)) for kind,t,addr,data in
      re.findall(r'APB (WRITE|READ ) t=\s*(\d+) ns addr=([0-9a-f]+) data=([0-9a-f]+)',log)]
cfg = [t for kind,t,a,d in tx if kind=='WRITE' and 2<=a<=12 and t<start]
done = next(t for kind,t,a,d in tx if kind=='READ ' and a==14 and d==0x8000)
flags = next(t for kind,t,a,d in tx if kind=='READ ' and a==16 and t>done)
common = ['PCLK','PSEL','PENABLE','PWRITE','PREADY','PADDR[9:0]']
config = ['cfg_base_a[9:0]','cfg_base_b[9:0]','cfg_base_c[9:0]',
          'cfg_stride_a[7:0]','cfg_stride_b[7:0]','cfg_stride_c[7:0]']
panels = {
 'writes': (common+['PRESETn','PWDATA[15:0]','start_pulse']+config,
            min(cfg)-30,start+60),
 'config': (['PCLK','start_pulse']+config+['engine_state[1:0]','engine_busy','core_run','core_cycle[7:0]'],
            start-30,start+180),
 'run': (['PCLK','core_run','core_cycle[7:0]','core_flags[4:0]','flags_reg[4:0]',
          'c_write_valid','c_write_addr[9:0]','c_write_data[63:0]','c_write_count[31:0]','done_reg','engine_busy'],
         start+200,writes[-1]+120),
 'reads': (common+['PRDATA[15:0]','done_reg','flags_reg[4:0]',
            'last_apb_read_addr[9:0]','last_apb_read_data[15:0]'],done-120,flags+50)
}
out=root/'docs/viewers'; out.mkdir(parents=True,exist_ok=True)
notes=['# Capture windows from actual exception log','',
       'Times below are ns; nWave zoom commands use ps. Screenshots still require capture and pen annotation.','']
for name,(signals,lo,hi) in panels.items():
    script='wvAddSignal -group {G1 '+' '.join('{/tb_part4/'+s+'} -height 20' for s in signals)+'}\n'
    script+=f'wvZoom {max(0,lo)*1000} {hi*1000}\n'
    (out/f'exception_{name}.tcl').write_text(script)
    notes.append(f'- {name}: {lo} to {hi} ns')
(root/'docs/CAPTURE_WINDOWS.md').write_text('\n'.join(notes)+'\n')
print('Created four viewer scripts from measured events.')
