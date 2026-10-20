#!/usr/bin/env python3
"""Render actual directed-test VCD bus events as annotated SVG report figures.

Standard library only. Run from part1_fp8 after simulation:
    python3 tools/render_waveforms.py
The generated SVG can be opened/exported as an image. It is NOT synthesized
timing data. This parser supports the simple scalar/vector VCD used here.
"""
from pathlib import Path
from html import escape
import json
import textwrap

ROOT = Path(__file__).resolve().parents[1]


def read_vcd(file, top):
    scopes, codes, events = [], {}, {}
    current_time = 0
    header = True
    for line in file.read_text().splitlines():
        words = line.split()
        if not words:
            continue
        if header:
            if words[0] == "$scope":
                scopes.append(words[2])
            elif words[0] == "$upscope":
                scopes.pop()
            elif words[0] == "$var" and scopes == [top]:
                codes[words[3]] = words[4]
                events[words[4]] = {}
            elif words[0] == "$enddefinitions":
                header = False
        elif line.startswith("#"):
            current_time = int(line[1:])
        elif line[0] in "bB":
            value, code = words[0][1:], words[1]
            if code in codes:
                events[codes[code]][current_time] = value
        elif line[0] in "01xXzZ":
            code = line[1:]
            if code in codes:
                events[codes[code]][current_time] = line[0]
    return events


def numeric(bits):
    if any(x in bits.lower() for x in "xz"):
        raise ValueError("Unknown value in requested waveform interval")
    return int(bits, 2)


def at(events, time):
    return numeric(events[max(t for t in events if t <= time)])


def render(operation, module):
    top = "tb_fp8_" + module
    events = read_vcd(ROOT / "build" / ("fp8_" + module + ".vcd"), top)
    cases = json.loads((ROOT / "tb" / "directed_cases.json").read_text())[operation][:5]
    width, height, left, right = 1800, 860, 205, 1750
    start, end = 10000, 60000  # VCD timescale 1 ps.
    x = lambda t: left + (t-start) * (right-left)/(end-start)
    elements = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<rect width="100%" height="100%" fill="white"/>',
        '<style>text{font-family:Arial,sans-serif;fill:#152c46}.mono{font-family:monospace}</style>',
        f'<text x="40" y="45" font-size="30" font-weight="bold">Part I - FP8 {module}: five annotated RTL test cases</text>',
        '<text x="40" y="76" font-size="18">Actual Icarus VCD events; e3m4, bias 3; hex data buses; no clock or pipeline inside the DUT.</text>',
    ]
    for i, (a, b, description) in enumerate(cases, 1):
        t0, t1 = i*10000, (i+1)*10000
        cx = (x(t0)+x(t1))/2
        if at(events["a"], t0) != int(a,16) or at(events["b"],t0) != int(b,16):
            raise ValueError("Stimulus does not match actual waveform")
        if at(events["result"],t0) != at(events["expected_result"],t0):
            raise ValueError("Output mismatch in waveform")
        if at(events["flags"],t0) != at(events["expected_flags"],t0):
            raise ValueError("Flag mismatch in waveform")
        color = "#fef0dc" if i >= 4 else "#e8f3fb"
        elements.append(f'<rect x="{x(t0)+8}" y="105" width="{x(t1)-x(t0)-16}" height="150" rx="8" fill="{color}" stroke="#457495"/>')
        elements.append(f'<text x="{x(t0)+20}" y="132" font-size="20" font-weight="bold">Case {i}</text>')
        for j, text in enumerate(textwrap.wrap(description, 30)):
            elements.append(f'<text x="{x(t0)+20}" y="{159+j*24}" font-size="17">{escape(text)}</text>')
        elements.append(f'<path d="M {cx} 255 L {cx} 282 l -5 -8 m 5 8 l 5 -8" fill="none" stroke="#457495" stroke-width="2"/>')
    for time in range(10000,60001,10000):
        elements.append(f'<path d="M {x(time)} 300 V 690" stroke="#d4dde5" stroke-dasharray="5,5"/>')
        elements.append(f'<text x="{x(time)}" y="292" text-anchor="middle" font-size="18">{time//1000} ns</text>')
    rows = [("case_id",345),("a",410),("b",475),("result",540),("flags",605)]
    for name, y in rows:
        elements.append(f'<text x="35" y="{y+7}" font-size="22" font-weight="bold">{name}</text>')
        changes = [(start, at(events[name],start))]
        for t, raw in sorted(events[name].items()):
            if start < t < end:
                value = numeric(raw)
                if value != changes[-1][1]:
                    changes.append((t,value))
        changes.append((end,None))
        for index, (t,value) in enumerate(changes[:-1]):
            tnext=changes[index+1][0]
            xl,xr=x(t),x(tnext)
            slant = 7 if index else 0
            er = 7 if index < len(changes)-2 else 0
            elements.append(f'<path d="M {xl} {y} L {xl+slant} {y-18} H {xr-er} L {xr} {y} L {xr-er} {y+18} H {xl+slant} Z" fill="#f4f8fb" stroke="#286789" stroke-width="2"/>')
            label = f"{value:05b}" if name=="flags" else (str(value) if name=="case_id" else f"0x{value:02X}")
            elements.append(f'<text x="{(xl+xr)/2}" y="{y+7}" text-anchor="middle" class="mono" font-size="23">{label}</text>')
    elements += [
        '<text x="40" y="714" font-size="20" font-weight="bold">Flags [4:0] = overflow | underflow | divide-by-zero | invalid | inexact</text>',
        '<text x="40" y="752" font-size="19">Cases 1-3: exact normal/zero results, flags=00000. Case 4: overflow to infinity, flags=10001.</text>',
        '<text x="40" y="784" font-size="19">Case 5: invalid operation returns canonical quiet NaN 0x78, flags=00010.</text>',
        '<text x="40" y="820" font-size="17">Bus transitions are zero-delay RTL events. Reported times are stimulus intervals, not measured hardware delays.</text>',
        '</svg>'
    ]
    output = ROOT / "docs" / "figures" / ("fp8_" + module + "_annotated.svg")
    output.parent.mkdir(exist_ok=True)
    output.write_text("\n".join(elements), newline="\n")
    print(output)


if __name__ == "__main__":
    render("add","adder")
    render("mul","multiplier")
