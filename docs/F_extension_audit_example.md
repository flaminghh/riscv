# F-Extension Encoding Audit Example

This note illustrates how to execute the planning steps from `docs/CONTRIBUTING.md` for the single-precision floating-point (F) instructions without modifying any RTL yet.

## 1. Gather specification references
- **Floating-Point Instruction Set Manual, Version 2.2 (20191213)** – Section 9 of the unprivileged ISA manual covers the base F extension encodings.
- **"The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA" (Version 20191213)** – Table 11.1 (and related tables) summarize opcode layouts that are shared across the F, D, and Q extensions.

Record the exact document versions in your notes so reviewers know which authoritative source you relied on.

## 2. Inventory current defines
Collect the relevant `define` statements from `src/instructions.sv` so you can compare them with the specification.

| Instruction | Current macro | Encoded fields |
|-------------|---------------|----------------|
| FADD.S | `INST_FADD_S` | `opcode=1010011`, `funct7=0000000`, `funct3=000` |
| FSUB.S | `INST_FSUB_S` | `opcode=1010011`, `funct7=0100000`, `funct3=000` |
| FMUL.S | `INST_FMUL_S` | `opcode=1010011`, `funct7=0000001`, `funct3=000` |
| FDIV.S | `INST_FDIV_S` | `opcode=1010011`, `funct7=0000101`, `funct3=000` |
| FSGNJ.S | `INST_FSGNJ_S` | `opcode=1010011`, `funct7=0000000`, `funct3=001` |
| FSGNJN.S | `INST_FSGNJN_S` | `opcode=1010011`, `funct7=0100000`, `funct3=001` |
| FSGNJX.S | `INST_FSGNJX_S` | `opcode=1010011`, `funct7=0010000`, `funct3=001` |
| FMIN.S | `INST_FMIN_S` | `opcode=1010011`, `funct7=0000000`, `funct3=010` |
| FMAX.S | `INST_FMAX_S` | `opcode=1010011`, `funct7=0000000`, `funct3=011` |
| FMINU.S | `INST_FMINU_S` | `opcode=1010011`, `funct7=0000000`, `funct3=010` |
| FMAXU.S | `INST_FMAXU_S` | `opcode=1010011`, `funct7=0000000`, `funct3=011` |
| FEQ.S | `INST_FEQ_S` | `opcode=1010011`, `funct7=0000000`, `funct3=100` |
| FLT.S | `INST_FLT_S` | `opcode=1010011`, `funct7=0000000`, `funct3=101` |
| FLE.S | `INST_FLE_S` | `opcode=1010011`, `funct7=0000000`, `funct3=110` |
| FCLASS.S | `INST_FCLASS_S` | `opcode=1010011`, `funct7=0000000`, `funct3=001` |
| FLW | `INST_FLW` | `opcode=0000011`, `funct3=010` |
| FSW | `INST_FSW` | `opcode=0100011`, `funct3=010` |

(Use your preferred spreadsheet or note-taking tool if you want to capture the entire table.)

## 3. Cross-check against the spec
Look up each instruction’s entry in the floating-point manual:

- `FADD.S` matches the spec (opcode `1010011`, funct7 `0000000`, funct3 `000`). No action required.
- `FSUB.S` **does not match**: the spec shows funct7 `0000100`, not `0100000`. Note this mismatch.
- `FMUL.S` should use funct7 `0001000`; the placeholder reuses `0000001`. Flag it for correction.
- `FDIV.S` needs funct7 `0001100` per Table 11.2; the define currently uses `0000101`.
- `FSGNJ.S`/`FSGNJN.S`/`FSGNJX.S` share funct7 `0010000` with funct3 `000/001/010`. The existing defines use mixed funct7 values; highlight the discrepancy.
- `FMIN.S` and `FMAX.S` require funct7 `0010100`. Both defines currently specify `0000000`.
- `FEQ.S`, `FLT.S`, `FLE.S`, and `FCLASS.S` should use funct7 values `1010000`, `1010000`, `1010000`, and `1110000` respectively. The placeholders still show `0000000`.
- Memory operations (`FLW`, `FSW`) already match the opcode/funct3 assignments listed in Table 8.2 of the unprivileged ISA manual, so no change is necessary there.

Capture each discrepancy together with the exact table/figure number from the spec so reviewers can trace your conclusions.

## 4. Prepare change notes for maintainers
Draft a short document (issue comment, PR draft, or design note) that lists every define you intend to update. Include:

- The incorrect bit pattern currently in the source.
- The corrected bit pattern from the spec.
- A citation to the exact spec table (e.g., “Unprivileged ISA v20191213, Table 11.2”).
- Any open questions (e.g., whether the design should support `FMINU.S`/`FMAXU.S` since they are non-standard aliases).

Share this plan to make sure you interpreted the task correctly before editing RTL.

## 5. Plan validation
Decide how you will confirm the encodings after making changes. For example:

1. Assemble representative instructions with `riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64d` and use `riscv64-unknown-elf-objdump -d` to verify the machine code matches the expected bit fields.
2. Extend or add unit tests in the RTL testbench to exercise the updated opcodes.
3. If available, run formal checks or linting that decode the updated fields to ensure no regressions.

Document this validation plan alongside your change notes so reviewers know how you will prove correctness once edits are permitted.

By following these steps you will have a complete, reviewable plan for updating the F-extension encodings without touching the implementation yet. Once the maintainers approve, you can proceed with code changes using the documented corrections.
