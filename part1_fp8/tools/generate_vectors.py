#!/usr/bin/env python3
"""Independent exact-rational FP8 oracle, not a translation of the RTL.

Enumerate all output encodings and choose the nearest with even-LSB tie break.
No binary floats are used. DAZ and pre-rounding FTZ match the documented design
policy. Generated hex vectors belong in build/, not in the submission ZIP.
"""
from fractions import Fraction
from pathlib import Path
import argparse

OVERFLOW, UNDERFLOW, INVALID, INEXACT = 16, 8, 2, 1
QNAN = 0x78


def classify(code):
    exponent, fraction = (code >> 4) & 7, code & 15
    if exponent == 7:
        return "inf" if fraction == 0 else "nan"
    return "zero" if exponent == 0 else "normal"


def value(code):
    """Denormal encodings are treated as zero by the DUT input policy."""
    if classify(code) == "zero":
        return Fraction(0)
    exponent, fraction = (code >> 4) & 7, code & 15
    magnitude = Fraction(16 + fraction) * Fraction(2) ** (exponent - 7)
    return -magnitude if code & 128 else magnitude


NORMALS = [(value(code), code) for code in range(0x10, 0x70)]
# The next precision-limited magnitude is 16.0, which overflows e3m4.
# This sentinel is needed for the ties-to-even overflow boundary at 15.75.
CANDIDATES = NORMALS + [(Fraction(16), 0x70)]


def quantize(exact):
    if exact == 0:
        return 0, 0
    sign = 128 if exact < 0 else 0
    magnitude = abs(exact)
    if magnitude < Fraction(1, 4):
        return sign, UNDERFLOW | INEXACT
    if magnitude >= 16:
        return sign | 0x70, OVERFLOW | INEXACT
    represented, code = min(
        CANDIDATES, key=lambda item: (abs(item[0] - magnitude), item[1] & 1)
    )
    if code == 0x70:
        return sign | code, OVERFLOW | INEXACT
    return sign | code, INEXACT if represented != magnitude else 0


def evaluate(operation, a, b):
    ca, cb = classify(a), classify(b)
    sa, sb = bool(a & 128), bool(b & 128)
    if ca == "nan" or cb == "nan":
        signaling = (ca == "nan" and not (a & 8)) or (cb == "nan" and not (b & 8))
        return QNAN, INVALID if signaling else 0
    if operation == "add":
        if ca == cb == "inf" and sa != sb:
            return QNAN, INVALID
        if ca == "inf" or cb == "inf":
            return (a if ca == "inf" else b), 0
        if ca == cb == "zero":
            return 128 if sa and sb else 0, 0
        return quantize(value(a) + value(b))
    if operation != "mul":
        raise ValueError(operation)
    if (ca == "inf" and cb == "zero") or (cb == "inf" and ca == "zero"):
        return QNAN, INVALID
    sign = 128 if sa != sb else 0
    if ca == "inf" or cb == "inf":
        return sign | 0x70, 0
    if ca == "zero" or cb == "zero":
        return sign, 0
    return quantize(value(a) * value(b))


def self_check():
    assert value(0x10) == Fraction(1, 4)
    assert value(0x6f) == Fraction(31, 2)
    assert quantize(Fraction(63, 4)) == (0x70, 17)  # 15.75 overflow tie.
    assert evaluate("add", 0x30, 0x12) == (0x34, 1)  # Even tie down.
    assert evaluate("add", 0x31, 0x12) == (0x36, 1)  # Even tie up.
    assert evaluate("add", 0x70, 0xf0) == (QNAN, 2)
    assert evaluate("mul", 0, 0x70) == (QNAN, 2)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path, default=Path("build"))
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    self_check()
    for operation in ("add", "mul"):
        with (args.out / (operation + "_vectors.hex")).open("w", newline="\n") as stream:
            for a in range(256):
                for b in range(256):
                    result, flags = evaluate(operation, a, b)
                    packed = (a << 21) | (b << 13) | (result << 5) | flags
                    stream.write(f"{packed:08x}\n")
        print(f"Generated {operation}: 65,536 exact-rational vectors")


if __name__ == "__main__":
    main()
