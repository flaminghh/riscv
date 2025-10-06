#!/usr/bin/env python3
import re
import sys
import argparse
from dataclasses import dataclass

# ------------------------------ Helpers ------------------------------

@dataclass
class Define:
    name: str
    width: int
    bits: str

def parse_defines(text):
    """
    Parse Verilog `define lines of the form:
      `define NAME 17'b0110011_0000000_000
    Returns dict name -> Define
    """
    defines = {}
    pattern = re.compile(r"^\s*`define\s+(\S+)\s+(\d+)'b([01\?_]+)", re.ASCII)
    for ln, line in enumerate(text.splitlines(), 1):
        m = pattern.match(line)
        if not m:
            continue
        name = m.group(1)
        width = int(m.group(2))
        bits = m.group(3).replace("_", "")
        defines[name] = Define(name, width, bits)
    return defines

def split_17_key(bits):
    """Split 17-bit key as {opcode[6:0], funct7[31:25], funct3[14:12]}"""
    if len(bits) != 17:
        raise ValueError("expected 17 bits, got %d" % len(bits))
    opcode = bits[0:7]
    funct7 = bits[7:14]
    funct3 = bits[14:17]
    return opcode, funct7, funct3

def split_22_key(bits):
    """Split 22-bit key as {opcode[6:0], funct3[14:12], imm[31:20]}"""
    if len(bits) != 22:
        raise ValueError("expected 22 bits, got %d" % len(bits))
    opcode = bits[0:7]
    funct3 = bits[7:10]
    imm12 = bits[10:22]
    return opcode, funct3, imm12

def has_wildcards(s):
    return "?" in s or "z" in s.lower()

def fmt_bits_from_suffix(name):
    # name ends with _S/_D/_Q
    if name.endswith("_S"):
        return "00"
    if name.endswith("_D"):
        return "01"
    if name.endswith("_Q"):
        return "11"
    return None

def expect_funct7(funct5, fmt):
    """funct7 in OP-FP is {funct5[4:0], fmt[1:0]}"""
    return f"{funct5}{fmt}"

def status_icon(ok):
    return "✅" if ok else "❌"

# Spec maps (funct5 and funct3 requirements)
ARITH_FUNCT5 = {
    "FADD": "00000",
    "FSUB": "00001",
    "FMUL": "00010",
    "FDIV": "00011",
    "FSQRT": "01011",
}
SGNJ_FUNCT = {
    "FSGNJ":  ("00100", "000"),
    "FSGNJN": ("00100", "001"),
    "FSGNJX": ("00100", "010"),
}
MINMAX_FUNCT = {
    "FMIN": ("00101", "000"),
    "FMAX": ("00101", "001"),
}
CMP_FUNCT = {
    "FEQ": ("10100", "010"),
    "FLT": ("10100", "001"),
    "FLE": ("10100", "000"),
}
MVCLASS_FUNCT = {
    # (funct5, funct3) ; rs2 must be 00000 but we can't see it in 17-bit key
    "FMV_X":   ("11100", "000"),  # FMV.X.{W,D,Q}
    "FCLASS":  ("11100", "001"),
    "FMV_W":   ("11110", "000"),  # FMV.{W,D,Q}.X (move from x to f)
}

OP_FP = "1010011"
LOAD_FP = "0000111"   # FLW/FLD/FLQ
STORE_FP = "0100111"  # FSW/FSD/FSQ

WIDTH_FUNCT3 = {
    "W": "010",
    "D": "011",
    "Q": "100",
}

NON_STANDARD_PATTERNS = [
    re.compile(r"^INST_FMINU_"), re.compile(r"^INST_FMAXU_"),
    re.compile(r"^INST_FENCE_F($|_)"),
]

SYSTEM_PREFIXES_FP = [
    "INST_FCVT_", "INST_FMV_", "INST_FCLASS_"
]

def check_nonstandard(defines):
    problems = []
    for name in defines:
        if any(p.match(name) for p in NON_STANDARD_PATTERNS):
            problems.append((name, "Non-standard FP mnemonic present (remove or guard behind extension flag)."))
    return problems

def check_fploadstore(defines):
    rows = []
    for k in ["FLW","FLD","FLQ","FSW","FSD","FSQ"]:
        name = f"INST_{k}"
        d = defines.get(name)
        if not d:
            rows.append((name, False, "missing define"))
            continue
        if d.width != 22:
            rows.append((name, False, f"expected 22-bit key, found {d.width}"))
            continue
        opcode, funct3, imm12 = split_22_key(d.bits)
        if k.startswith("FL"):
            ok_opcode = (opcode == LOAD_FP)
        else:
            ok_opcode = (opcode == STORE_FP)
        exp_f3 = WIDTH_FUNCT3["W" if k.endswith("W") else ("D" if k.endswith("D") else "Q")]
        ok_f3 = funct3 == exp_f3
        msg = []
        if not ok_opcode:
            msg.append(f"opcode {opcode} != expected {'LOAD-FP(0000111)' if k.startswith('FL') else 'STORE-FP(0100111)'}")
        if not ok_f3:
            msg.append(f"funct3 {funct3} != expected {exp_f3}")
        rows.append((name, ok_opcode and ok_f3, "; ".join(msg) if msg else "ok"))
    return rows

def check_system_fp(defines):
    problems = []
    for name, d in defines.items():
        if any(name.startswith(pref) for pref in SYSTEM_PREFIXES_FP):
            # If it's actually an OP-FP instruction, defining it under SYSTEM is a problem
            # We detect by checking opcode in the numeric field if possible
            if d.width in (17,22,10):
                # For their system-style FCVT/ FMV / FCLASS they used 22'b1110011_...
                if d.width == 22:
                    opcode = d.bits[0:7]
                    if opcode == "1110011":
                        problems.append((name, "Should be OP-FP (1010011), not SYSTEM (1110011)."))
    return problems

def check_opfp_17(defines):
    rows = []
    # Build a list of interesting FP op names present in defines
    for name, d in defines.items():
        if not name.startswith("INST_F"):
            continue
        # Skip loads/stores handled elsewhere
        if name in ("INST_FLW","INST_FLD","INST_FLQ","INST_FSW","INST_FSD","INST_FSQ"):
            continue
        # Only check 17-bit keys (opcode,funct7,funct3)
        if d.width != 17:
            continue
        opcode, funct7, funct3 = split_17_key(d.bits)
        if opcode != OP_FP:
            # Not an OP-FP define; ignore here
            continue

        base = name.removeprefix("INST_")
        # remove trailing _S/_D/_Q to get family
        family = base
        suffix = None
        for sfx in ("_S","_D","_Q"):
            if base.endswith(sfx):
                family = base[:-len(sfx)]
                suffix = sfx
                break
        fmt = fmt_bits_from_suffix(base) if suffix else None
        exp_funct7 = None
        exp_funct3 = None
        class_label = None
        warn_rm_locked = False
        ok = True
        msg = []

        def set_expect(funct5, funct3_req=None):
            nonlocal exp_funct7, exp_funct3, class_label, ok, msg
            if fmt is None:
                msg.append("missing _S/_D/_Q suffix to determine fmt")
                ok = False
            else:
                exp_funct7 = expect_funct7(funct5, fmt)
            if funct3_req is not None:
                exp_funct3 = funct3_req

        # Determine expected fields
        if family in ARITH_FUNCT5:
            class_label = "arith"
            set_expect(ARITH_FUNCT5[family], None)  # funct3 is rm (don't care)
            # Warn if funct3 is locked to a value (not wildcard); in constants it's usually fixed
            if not has_wildcards(funct3):
                warn_rm_locked = True
        elif family in SGNJ_FUNCT:
            class_label = "sgnj"
            f5, f3 = SGNJ_FUNCT[family]
            set_expect(f5, f3)
        elif family in MINMAX_FUNCT:
            class_label = "minmax"
            f5, f3 = MINMAX_FUNCT[family]
            set_expect(f5, f3)
        elif family in CMP_FUNCT:
            class_label = "cmp"
            f5, f3 = CMP_FUNCT[family]
            set_expect(f5, f3)
        elif family.startswith("FMV_X"):
            class_label = "mv_to_x"
            set_expect(MVCLASS_FUNCT["FMV_X"][0], MVCLASS_FUNCT["FMV_X"][1])
        elif family.startswith("FMV_") and family.endswith("_X"):
            class_label = "mv_from_x"
            set_expect(MVCLASS_FUNCT["FMV_W"][0], MVCLASS_FUNCT["FMV_W"][1])
        elif family.startswith("FCLASS"):
            class_label = "fclass"
            set_expect(MVCLASS_FUNCT["FCLASS"][0], MVCLASS_FUNCT["FCLASS"][1])
        elif family.startswith("FCVT"):
            class_label = "fcvt"
            # FCVT encodings need rs2 subtype; we only check opcode/funct7(fmt+funct5) match here
            # Decide whether it's FP->int or int->FP by token
            # We can map both to funct5 11000 (to int) or 11010 (from int)
            tokens = family.split("_")
            # Heuristic: tokens might look like ['FCVT', 'W', 'S'] etc in some naming schemes.
            # Since the user's macros include suffix _S/_D/_Q we just verify funct7 matches either 11000 or 11010 with fmt.
            if fmt is None:
                ok = False
                msg.append("missing _S/_D/_Q suffix to determine fmt")
            else:
                exp_a = expect_funct7("11000", fmt)  # FP->int
                exp_b = expect_funct7("11010", fmt)  # int->FP
                if "?" not in funct7 and (funct7 != exp_a and funct7 != exp_b):
                    ok = False
                    msg.append(f"funct7 {funct7} != expected {exp_a} or {exp_b}")
        else:
            # Unknown FP family; skip
            continue

        # Compare funct7 (if determinable and not already checked)
        if exp_funct7 is not None:
            if "?" in funct7:
                msg.append("funct7 has wildcards; cannot strictly verify")
            elif funct7 != exp_funct7:
                ok = False
                msg.append(f"funct7 {funct7} != expected {exp_funct7}")

        # Compare funct3 if required
        if exp_funct3 is not None and not has_wildcards(funct3):
            if funct3 != exp_funct3:
                ok = False
                msg.append(f"funct3 {funct3} != expected {exp_funct3}")

        # Warn about rm locked for arithmetic
        if warn_rm_locked:
            msg.append("warning: arithmetic rm (funct3) is fixed; decoder should ignore rm for match")

        rows.append((name, class_label, ok, "; ".join(msg) if msg else "ok"))
    return rows

def main():
    ap = argparse.ArgumentParser(description="Verify RISC-V F/D/Q encodings in a Verilog `define header")
    ap.add_argument("header", help="Path to instructions.vh (or similar)")
    args = ap.parse_args()

    text = open(args.header, "r", encoding="utf-8").read()
    defines = parse_defines(text)

    failures = 0

    print("== Non-standard items ==")
    ns = check_nonstandard(defines)
    if not ns:
        print("  none")
    else:
        for name, why in ns:
            print(f"  {name}: {why}")
            failures += 1

    print("\n== FP Load/Store ==")
    for name, ok, note in check_fploadstore(defines):
        print(f"  {name:12s} {status_icon(ok)}  {note}")
        if not ok:
            failures += 1

    print("\n== OP-FP 17-bit keys (opcode/funct7/funct3) ==")
    rows = check_opfp_17(defines)
    if not rows:
        print("  no OP-FP 17-bit defines found")
    else:
        for name, cls, ok, note in sorted(rows):
            print(f"  {name:20s} [{cls:8s}] {status_icon(ok)}  {note}")
            if not ok:
                failures += 1

    print("\n== FP things defined under SYSTEM (should be OP-FP) ==")
    sysprobs = check_system_fp(defines)
    if not sysprobs:
        print("  none")
    else:
        for name, why in sysprobs:
            print(f"  {name}: {why}")
            failures += 1

    if failures:
        print(f"\nSummary: {failures} issue(s) found.")
        sys.exit(1)
    else:
        print("\nSummary: all checks passed.")
        sys.exit(0)

if __name__ == "__main__":
    main()
