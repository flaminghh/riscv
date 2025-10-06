`ifndef __INSTRUCTIONS__
`define __INSTRUCTIONS__

// TODO: Verify the F, D and Q extenstions

/////////////////////////////////////
/// R-Type Register Instructions (operand, funct7, funct3)
/////////////////////////////////////

`define INST_ADD       17'b0110011_0000000_000 // I Integer add *
`define INST_SUB       17'b0110011_0100000_000 // I Subtract *
`define INST_SLL       17'b0110011_0000000_001 // I Shift left logical *
`define INST_SLT       17'b0110011_0000000_010 // I Set on less than *
`define INST_SLTU      17'b0110011_0000000_011 // I Set on less than unsigned *
`define INST_XOR       17'b0110011_0000000_100 // I Exclusive OR *
`define INST_SRL       17'b0110011_0000000_101 // I Shift right logical *
`define INST_SRA       17'b0110011_0100000_101 // I Shift right arithmetic *
`define INST_OR        17'b0110011_0000000_110 // I Or *
`define INST_AND       17'b0110011_0000000_111 // I And *
`define INST_ADDW      17'b0111011_0000000_000 // I Add word *
`define INST_SUBW      17'b0111011_0100000_000 // I Subtract word *
`define INST_SLLW      17'b0111011_0000000_001 // I Shift left logical word *
`define INST_SRLW      17'b0111011_0000000_101 // I Shift right logical word *
`define INST_SRAW      17'b0111011_0100000_101 // I Shift right arithmetic word *

`define INST_DIV       17'b0110011_0000001_100 // M Signed division *
`define INST_DIVU      17'b0110011_0000001_101 // M Unsigned division *
`define INST_MUL       17'b0110011_0000001_000 // M Signed multiply *
`define INST_MULH      17'b0110011_0000001_001 // M Signed multiply high *
`define INST_MULHSU    17'b0110011_0000001_010 // M Signed/unsigned multiply high *
`define INST_MULHU     17'b0110011_0000001_011 // M Unsigned multiply high *
`define INST_REM       17'b0110011_0000001_110 // M Signed remainder *
`define INST_REMU      17'b0110011_0000001_111 // M Unsigned remainder *
`define INST_DIVUW     17'b0111011_0000001_101 // M Unsigned word division *
`define INST_DIVW      17'b0111011_0000001_100 // M Signed word division *
`define INST_MULW      17'b0111011_0000001_000 // M Signed word multiply *
`define INST_REMUW     17'b0111011_0000001_111 // M Unsigned word remainder *
`define INST_REMW      17'b0111011_0000001_110 // M Signed word remainder *

`define INST_ANDN      17'b0110011_0100000_111 // B And with inverted operand
`define INST_BCLR      17'b0110011_0100100_001 // B Single-Bit clear (Register)
`define INST_BEXT      17'b0110011_0100100_101 // B Single-Bit extract (Register)
`define INST_BINV      17'b0110011_0110100_001 // B Single-Bit invert (Register)
`define INST_BSET      17'b0110011_0010100_001 // B Single-Bit set (Register)
`define INST_CLMUL     17'b0110011_0000101_001 // B Carry-less multiply (low-part)
`define INST_CLMULH    17'b0110011_0000101_011 // B Carry-less multiply (high-part)
`define INST_CLMULR    17'b0110011_0000101_010 // B Carry-less multiply (reversed)
`define INST_MAX       17'b0110011_0000101_110 // B Maximum
`define INST_MAXU      17'b0110011_0000101_111 // B Unsigned maximum
`define INST_MIN       17'b0110011_0000101_100 // B Minimum
`define INST_MINU      17'b0110011_0000101_101 // B Unsigned minimum
`define INST_ORN       17'b0110011_0100000_110 // B OR with inverted operand
`define INST_ROL       17'b0110011_0110000_001 // B Rotate left (Register)
`define INST_ROR       17'b0110011_0110000_101 // B Rotate right (Register)
`define INST_RORW      17'b0111011_0110000_101 // B Rotate right word (Register)
`define INST_SH1ADD    17'b0110011_0010000_010 // B Shift left by 1 and add
`define INST_SH2ADD    17'b0110011_0010000_100 // B Shift left by 2 and add
`define INST_SH3ADD    17'b0110011_0010000_110 // B Shift left by 3 and add
`define INST_XNOR      17'b0110011_0100000_100 // B Exclusive NOR
`define INST_XPERM16   17'b0110011_0010100_110 // B Crossbar Permutation Instruction (word)
`define INST_XPERM32   17'b0110011_0010100_000 // B Crossbar Permutation Instruction (half-word)
`define INST_XPERM4    17'b0110011_0010100_010 // B Crossbar Permutation Instruction (nibble)
`define INST_XPERM8    17'b0110011_0010100_100 // B Crossbar Permutation Instruction (byte)
`define INST_ZEXTH32   17'b0110011_0000100_100 // B Zero-extend halfword (XLEN=32)
`define INST_ZEXTH64   17'b0111011_0000100_100 // B Zero-extend halfword (XLEN=64)
`define INST_ADD_UW    17'b0111011_0000100_000 // B Add unsigned word
`define INST_ROLW      17'b0111011_0110000_001 // B Rotate left word (Register)
`define INST_SH1ADD_UW 17'b0111011_0010000_010 // B Shift unsigend word left by 1 and add
`define INST_SH2ADD_UW 17'b0111011_0010000_100 // B Shift unsigend word left by 2 and add
`define INST_SH3ADD_UW 17'b0111011_0010000_110 // B Shift unsigend word left by 3 and add

// ===================== OP-FP (.S single-precision) =====================
// Layout reminder: opcode=1010011 (OP-FP)
//   funct7 = {funct5[31:27], fmt[26:25]}  → for .S, fmt=00
//   funct3 = rm for arithmetic (treat as don't-care), or sub-op selector for some ops.
// --- Arithmetic: FADD.S ---
// `define INST_FADD_S    17'b1010011_0000000_000 // WRONG: pins rm=000 (RNE) only; rm must be don't-care
`define INST_FADD_S       17'b1010011_0000000_??? // FIX: funct7 ok (funct5=00000,fmt=00); allow any rm in funct3
// --- Arithmetic: FSUB.S ---
// `define INST_FSUB_S    17'b1010011_0100000_000 // WRONG: funct7=0100000 is not FSUB.S
`define INST_FSUB_S       17'b1010011_0000100_??? // FIX: funct5=00001 → funct7=0000100 (fmt=00); rm=???
// --- Arithmetic: FMUL.S ---
// `define INST_FMUL_S    17'b1010011_0000001_000 // WRONG: funct7 should be 0001000 for FMUL.S
`define INST_FMUL_S       17'b1010011_0001000_??? // FIX: funct5=00010 → funct7=0001000; rm=???
// --- Arithmetic: FDIV.S ---
// `define INST_FDIV_S    17'b1010011_0000101_000 // WRONG: funct7 should be 0001100 for FDIV.S
`define INST_FDIV_S       17'b1010011_0001100_??? // FIX: funct5=00011 → funct7=0001100; rm=???
// --- Sign inject group: FSGNJ*.S ---
// `define INST_FSGNJ_S   17'b1010011_0000000_001 // WRONG: funct7 wrong; variant chosen by funct3
`define INST_FSGNJ_S      17'b1010011_0010000_000 // FIX: funct5=00100 → funct7=0010000; funct3=000 (SGNJ)
// `define INST_FSGNJN_S  17'b1010011_0100000_001 // WRONG: funct7 wrong
`define INST_FSGNJN_S     17'b1010011_0010000_001 // FIX: same funct7; funct3=001 (SGNJN)
// `define INST_FSGNJX_S  17'b1010011_0010000_001 // WRONG: funct3 should be 010 (XOR)
`define INST_FSGNJX_S     17'b1010011_0010000_010 // FIX: same funct7; funct3=010 (SGNJX)
// --- Min/Max: FMIN/FMAX.S ---
// `define INST_FMIN_S    17'b1010011_0000000_010 // WRONG: funct7 wrong
`define INST_FMIN_S       17'b1010011_0010100_000 // FIX: funct5=00101 → funct7=0010100; funct3=000 (MIN)
// `define INST_FMAX_S    17'b1010011_0000000_011 // WRONG: funct7 wrong
`define INST_FMAX_S       17'b1010011_0010100_001 // FIX: same funct7; funct3=001 (MAX)
// --- Non-standard (remove): FMINU/FMAXU ---
// `define INST_FMINU_S   17'b1010011_0000000_010 // WRONG/NON-STANDARD: no FMINU.S in base F; delete
// `define INST_FMAXU_S   17'b1010011_0000000_011 // WRONG/NON-STANDARD: no FMAXU.S in base F; delete
// --- Comparisons: FEQ/FLT/FLE.S ---
// `define INST_FEQ_S     17'b1010011_0000000_100 // WRONG: funct7/funct3 wrong for FEQ.S
`define INST_FEQ_S        17'b1010011_1010000_010 // FIX: funct5=10100 → funct7=1010000; funct3=010 (EQ; rd is x-reg)
// `define INST_FLT_S     17'b1010011_0000000_101 // WRONG: funct7/funct3 wrong for FLT.S
`define INST_FLT_S        17'b1010011_1010000_001 // FIX: same funct7; funct3=001 (LT)
// `define INST_FLE_S     17'b1010011_0000000_110 // WRONG: funct7/funct3 wrong for FLE.S
`define INST_FLE_S        17'b1010011_1010000_000 // FIX: same funct7; funct3=000 (LE)
// --- Classify: FCLASS.S (unary; rs2 must be 0) ---
// `define INST_FCLASS_S  17'b1010011_0000000_001 // WRONG: funct7 wrong
`define INST_FCLASS_S     17'b1010011_1110000_001 // FIX: funct5=11100 → funct7=1110000; funct3=001 (rs2=0 in full 32b)


// ===================== OP-FP (.D double-precision) =====================
// Layout: opcode=1010011, funct7={funct5[31:27],fmt[26:25]} with fmt=01 for .D; funct3=rm for arithmetic or sub-op for others.
// `define INST_FADD_D    17'b1010011_0000000_000 // WRONG: pins rm=000 (RNE) only; also funct7 must end with fmt=01 for .D
`define INST_FADD_D       17'b1010011_0000001_??? // FIX: funct5=00000 → funct7=0000001 (fmt=01); rm any
// `define INST_FSUB_D    17'b1010011_0100000_000 // WRONG: funct7 wrong; should be funct5=00001 with fmt=01; rm must be don't-care
`define INST_FSUB_D       17'b1010011_0000101_??? // FIX: funct7=0000101; rm any
// `define INST_FMUL_D    17'b1010011_0000001_000 // WRONG: funct7 wrong; should be funct5=00010 with fmt=01; rm must be don't-care
`define INST_FMUL_D       17'b1010011_0001001_??? // FIX: funct7=0001001; rm any
// `define INST_FDIV_D    17'b1010011_0000101_000 // WRONG: funct7 wrong; should be funct5=00011 with fmt=01; rm must be don't-care
`define INST_FDIV_D       17'b1010011_0001101_??? // FIX: funct7=0001101; rm any
// `define INST_FSGNJ_D   17'b1010011_0000000_001 // WRONG: funct7 wrong; SGNJ group uses funct5=00100 and fmt=01; funct3 selects variant
`define INST_FSGNJ_D      17'b1010011_0010001_000 // FIX: funct7=0010001; funct3=000 (SGNJ)
// `define INST_FSGNJN_D  17'b1010011_0100000_001 // WRONG: funct7 wrong; variant via funct3
`define INST_FSGNJN_D     17'b1010011_0010001_001 // FIX: funct3=001 (SGNJN)
// `define INST_FSGNJX_D  17'b1010011_0010000_001 // WRONG: funct7 must end with fmt=01; funct3 should be 010
`define INST_FSGNJX_D     17'b1010011_0010001_010 // FIX: funct7=0010001; funct3=010 (SGNJX)
// `define INST_FMIN_D    17'b1010011_0000000_010 // WRONG: funct7 wrong; FMIN/MAX use funct5=00101 and fmt=01; funct3 selects MIN/MAX
`define INST_FMIN_D       17'b1010011_0010101_000 // FIX: funct7=0010101; funct3=000 (MIN)
// `define INST_FMAX_D    17'b1010011_0000000_011 // WRONG: funct7 wrong
`define INST_FMAX_D       17'b1010011_0010101_001 // FIX: funct7=0010101; funct3=001 (MAX)
// `define INST_FMINU_D   17'b1010011_0000000_010 // WRONG/NON-STANDARD: no FMINU.D in base D; delete
// FIX: delete (non-standard)
// `define INST_FMAXU_D   17'b1010011_0000000_011 // WRONG/NON-STANDARD: no FMAXU.D in base D; delete
// FIX: delete (non-standard)
// `define INST_FEQ_D     17'b1010011_0000000_100 // WRONG: compares use funct5=10100 with fmt=01; funct3 selects EQ/LT/LE
`define INST_FEQ_D        17'b1010011_1010001_010 // FIX: funct7=1010001; funct3=010 (EQ; result in x-reg)
// `define INST_FLT_D     17'b1010011_0000000_101 // WRONG: compares use funct5=10100 with fmt=01
`define INST_FLT_D        17'b1010011_1010001_001 // FIX: funct3=001 (LT)
// `define INST_FLE_D     17'b1010011_0000000_110 // WRONG: compares use funct5=10100 with fmt=01
`define INST_FLE_D        17'b1010011_1010001_000 // FIX: funct3=000 (LE)
// `define INST_FCLASS_D  17'b1010011_0000000_001 // WRONG: FCLASS uses funct5=11100 with fmt=01; funct3=001; rs2=0 (unary)
`define INST_FCLASS_D     17'b1010011_1110001_001 // FIX: funct7=1110001; funct3=001 (note: rs2=0 in full 32b)


// ===================== OP-FP (.Q quad-precision) =====================
// Layout: opcode=1010011, funct7={funct5[31:27],fmt[26:25]} with fmt=11 for .Q; funct3=rm for arithmetic or sub-op for others.
// `define INST_FADD_Q    17'b1010011_0000000_000 // WRONG: pins rm=000 (RNE) only; funct7 must end with fmt=11 for .Q
`define INST_FADD_Q       17'b1010011_0000011_??? // FIX: funct5=00000 → funct7=0000011 (fmt=11); rm any
// `define INST_FSUB_Q    17'b1010011_0100000_000 // WRONG: funct7 wrong; should be funct5=00001 with fmt=11; rm must be don't-care
`define INST_FSUB_Q       17'b1010011_0000111_??? // FIX: funct7=0000111; rm any
// `define INST_FMUL_Q    17'b1010011_0000001_000 // WRONG: funct7 wrong; should be funct5=00010 with fmt=11; rm must be don't-care
`define INST_FMUL_Q       17'b1010011_0001011_??? // FIX: funct7=0001011; rm any
// `define INST_FDIV_Q    17'b1010011_0000101_000 // WRONG: funct7 wrong; should be funct5=00011 with fmt=11; rm must be don't-care
`define INST_FDIV_Q       17'b1010011_0001111_??? // FIX: funct7=0001111; rm any
// `define INST_FSGNJ_Q   17'b1010011_0000000_001 // WRONG: funct7 wrong; SGNJ group uses funct5=00100 and fmt=11; funct3 selects variant
`define INST_FSGNJ_Q      17'b1010011_0010011_000 // FIX: funct7=0010011; funct3=000 (SGNJ)
// `define INST_FSGNJN_Q  17'b1010011_0100000_001 // WRONG: funct7 wrong; variant via funct3
`define INST_FSGNJN_Q     17'b1010011_0010011_001 // FIX: funct3=001 (SGNJN)
// `define INST_FSGNJX_Q  17'b1010011_0010000_001 // WRONG: funct7 must end with fmt=11; funct3 should be 010
`define INST_FSGNJX_Q     17'b1010011_0010011_010 // FIX: funct7=0010011; funct3=010 (SGNJX)
// `define INST_FMIN_Q    17'b1010011_0000000_010 // WRONG: funct7 wrong; FMIN/MAX use funct5=00101 and fmt=11; funct3 selects MIN/MAX
`define INST_FMIN_Q       17'b1010011_0010111_000 // FIX: funct7=0010111; funct3=000 (MIN)
// `define INST_FMAX_Q    17'b1010011_0000000_011 // WRONG: funct7 wrong
`define INST_FMAX_Q       17'b1010011_0010111_001 // FIX: funct7=0010111; funct3=001 (MAX)
// `define INST_FMINU_Q   17'b1010011_0000000_010 // WRONG/NON-STANDARD: no FMINU.Q in base Q; delete
// FIX: delete (non-standard)
// `define INST_FMAXU_Q   17'b1010011_0000000_011 // WRONG/NON-STANDARD: no FMAXU.Q in base Q; delete
// FIX: delete (non-standard)
// `define INST_FEQ_Q     17'b1010011_0000000_100 // WRONG: compares use funct5=10100 with fmt=11; funct3 selects EQ/LT/LE
`define INST_FEQ_Q        17'b1010011_1010011_010 // FIX: funct7=1010011; funct3=010 (EQ; result in x-reg)
// `define INST_FLT_Q     17'b1010011_0000000_101 // WRONG: compares use funct5=10100 with fmt=11
`define INST_FLT_Q        17'b1010011_1010011_001 // FIX: funct3=001 (LT)
// `define INST_FLE_Q     17'b1010011_0000000_110 // WRONG: compares use funct5=10100 with fmt=11
`define INST_FLE_Q        17'b1010011_1010011_000 // FIX: funct3=000 (LE)
// `define INST_FCLASS_Q  17'b1010011_0000000_001 // WRONG: FCLASS uses funct5=11100 with fmt=11; funct3=001; rs2=0 (unary)
`define INST_FCLASS_Q     17'b1010011_1110011_001 // FIX: funct7=1110011; funct3=001 (note: rs2=0 in full 32b)

/////////////////////////////////////
/// I-Type Immediate Instricntions (opcode, funct3, IMM[31:19])
/////////////////////////////////////

`define INST_ADDI    22'b0010011_000_???????????? // I Add immediate *
`define INST_SLLI    22'b0010011_001_000000?????? // I Shift left logical immediate *
`define INST_SLTI    22'b0010011_010_???????????? // I Set on less than immediate *
`define INST_SLTIU   22'b0010011_011_???????????? // I Set on less than immediate unsigned *
`define INST_XORI    22'b0010011_100_???????????? // I Exclusive Or immediate *
`define INST_SRLI    22'b0010011_101_000000?????? // I Shift right logical immediate *
`define INST_SRAI    22'b0010011_101_010000?????? // I Shift right arithmetic *
`define INST_ORI     22'b0010011_110_???????????? // I Or immediate *
`define INST_ANDI    22'b0010011_111_???????????? // I And immediate *
`define INST_ADDIW   22'b0011011_000_???????????? // I Add immediate word *
`define INST_SLLIW   22'b0011011_001_000000?????? // I Shift left logical immediate word *
`define INST_SRLIW   22'b0011011_101_000000?????? // I Shift right logical immediate word *
`define INST_SRAIW   22'b0011011_101_010000?????? // I Shift right arithmetic *

`define INST_BCLRI   22'b0010011_001_010010?????? // B Single-Bit clear (Immediate)           (31-25 = 0100100, 31-26 = 010010)
`define INST_BINVI   22'b0010011_001_011010?????? // B Single-Bit invert (Immediate)          (31-25 = 0110100, 31-26 = 011010)
`define INST_BSETI   22'b0010011_001_001010?????? // B Single-Bit set (Immediate)             (31-25 = 0010100, 31-26 = 001010)
`define INST_CLZ     22'b0010011_001_011000000000 // B Count leading zero bits                (IMM = 011000000000)
`define INST_CPOP    22'b0010011_001_011000000010 // B Count Bits Set                         (IMM = 011000000010)
`define INST_CTZ     22'b0010011_001_011000000001 // B Count trailing zero bits               (IMM = 011000000001)
`define INST_SEXT_B  22'b0010011_001_011000000100 // B Sign-extend byte                       (IMM = 011000000100)
`define INST_SEXT_H  22'b0010011_001_011000000101 // B Sign-extend halfword                   (IMM = 011000000101)
`define INST_SHFLI   22'b0010011_001_000010?????? // B Generalized Shuffle immediate          (31-25 = 0000100) (ZIP)
`define INST_BEXTI   22'b0010011_101_010010?????? // B Single-Bit extract (Immediate)         (31-25 = 0100100, 31-26 = 010010)
`define INST_GREVI   22'b0010011_101_011010?????? // B Generalised Reverse with Immediate     (31-36 = 011010) (BREV8, REV8)
`define INST_ORCB    22'b0010011_101_001010000111 // B Bitware OR-combine, byte granule       (IMM = 001010000111)
`define INST_RORI    22'b0010011_101_011000?????? // B Rotate right (Immediate)               (31-35 = 0110000)
`define INST_UNSHFLI 22'b0010011_101_000010?????? // B Generalized Unshuffle immediate        (31-25 = 0000100) (UNZIP)
`define INST_CLZW    22'b0011011_001_011000000000 // B Count leading zero bits in word        (IMM = 011000000000)
`define INST_CPOPW   22'b0011011_001_011000000010 // B Count leading zero bits in word        (IMM = 011000000010)
`define INST_CTZW    22'b0011011_001_011000000001 // B Count leading zero bits in word        (IMM = 011000000001)
`define INST_RORIW   22'b0011011_101_011000?????? // B Rotate right word (Immediate)          (31-35 = 0110000)
`define INST_SLLIUW  22'b0011011_001_000010?????? // B Shift left unsigned word (Immediate)   (31-26 = 000010)

// `define INST_FLW     22'b0000011_010_???????????? // WRONG: used integer LOAD opcode (0000011); FP loads use LOAD-FP opcode 0000111
`define INST_FLW        22'b0000111_010_???????????? // FIX: FLW → opcode=0000111 (LOAD-FP), funct3=010 (word)
// `define INST_FSW     22'b0100011_010_???????????? // WRONG: used integer STORE opcode (0100011); FP stores use STORE-FP opcode 0100111
`define INST_FSW        22'b0100111_010_???????????? // FIX: FSW → opcode=0100111 (STORE-FP), funct3=010 (word)
// `define INST_FLD     22'b0000011_011_???????????? // WRONG: integer LOAD opcode; must be LOAD-FP
`define INST_FLD        22'b0000111_011_???????????? // FIX: FLD → opcode=0000111 (LOAD-FP), funct3=011 (doubleword)
// `define INST_FSD     22'b0100011_011_???????????? // WRONG: integer STORE opcode; must be STORE-FP
`define INST_FSD        22'b0100111_011_???????????? // FIX: FSD → opcode=0100111 (STORE-FP), funct3=011 (doubleword)
// `define INST_FLQ     22'b0000011_100_???????????? // WRONG: integer LOAD opcode; must be LOAD-FP
`define INST_FLQ        22'b0000111_100_???????????? // FIX: FLQ → opcode=0000111 (LOAD-FP), funct3=100 (quadword)
// `define INST_FSQ     22'b0100011_100_???????????? // WRONG: integer STORE opcode; must be STORE-FP
`define INST_FSQ        22'b0100111_100_???????????? // FIX: FSQ → opcode=0100111 (STORE-FP), funct3=100 (quadword)


/////////////////////////////////////
/// I-Type Branch (opcode, funct3)
/////////////////////////////////////

`define INST_BEQ     10'b1100011_000 // I Branch if equal *
`define INST_BGE     10'b1100011_101 // I Branch if greater than or equal *
`define INST_BGEU    10'b1100011_111 // I Branch if greater than or equal unsigned *
`define INST_BLT     10'b1100011_100 // I Branch if less than *
`define INST_BLTU    10'b1100011_110 // I Branch if less than unsigned *
`define INST_BNE     10'b1100011_001 // I Branch if not equal *

/////////////////////////////////////
/// I-Type Load (opcode, funct3)
/////////////////////////////////////

`define INST_LB      10'b0000011_000 // I Load byte *
`define INST_LBU     10'b0000011_100 // I Load byte Unsigned *
`define INST_LD      10'b0000011_011 // I Load doubleword
`define INST_LH      10'b0000011_001 // I Load halfword *
`define INST_LHU     10'b0000011_101 // I Load halfword unsigned *
`define INST_LW      10'b0000011_010 // I Load word *
`define INST_LWU     10'b0000011_110 // I Load word unsigned

/////////////////////////////////////
/// S-Type Store (opcode, funct3)
/////////////////////////////////////

`define INST_SB      10'b0100011_000 // I Store byte *
`define INST_SD      10'b0100011_011 // I Store double word *
`define INST_SH      10'b0100011_001 // I Store halfword *
`define INST_SW      10'b0100011_010 // I Store word *

/////////////////////////////////////
/// I-Type Fence (opcode, funct3)
/////////////////////////////////////

`define INST_FENCE     10'b0001111_000 // I Memory ordering fence
`define INST_FENCEI    10'b0001111_001 // I Instruction fence

// `define INST_FENCE_F   10'b0001111_010 // WRONG/NON-STANDARD: no FP-specific fence in RISC-V; delete (use standard FENCE 0001111_000)
 // FIX: use `INST_FENCE` (memory fence) or `INST_FENCEI` (instruction fence) as appropriate
// `define INST_FENCE_F_D 10'b0001111_010 // WRONG/NON-STANDARD: duplicate of non-existent FP fence; delete
 // FIX: delete and rely on standard FENCE/FENCEI encodings already defined
// `define INST_FENCE_F_Q 10'b0001111_011 // WRONG/NON-STANDARD: no FP-quad fence; delete
 // FIX: delete and rely on standard FENCE/FENCEI encodings already defined


/////////////////////////////////////
/// I-Type System (opcode, funct3, funct12)
/////////////////////////////////////

`define INST_EBREAK    22'b1110011_000_000000000001 // I  Breakpoint exception *
`define INST_ECALL     22'b1110011_000_000000000000 // I  Environment call *
`define INST_MRET      22'b1110011_000_001100000010 // Sm Machine Exception Return *
`define INST_SRET      22'b1110011_000_000100000010 // S  Supervisor Exception Return
`define INST_WIFI      22'b1110011_000_000100000101 // Sm Wait for interrupt
`define INST_CSRRC     22'b1110011_011_???????????? // CSR Atomic Read and Clear Bits *
`define INST_CSRRCI    22'b1110011_111_???????????? // CSR Atomic Read and Clear Bits (Immediate) *
`define INST_CSRRS     22'b1110011_010_???????????? // CSR Atomic Read and Set Bits in CSR *
`define INST_CSRRSI    22'b1110011_110_???????????? // CSR Atomic Read and Set Bits in CSR (Immediate) *
`define INST_CSRRW     22'b1110011_001_???????????? // CSR Atomic Read/Write CSR *
`define INST_CSRRWI    22'b1110011_101_???????????? // CSR Atomic Read/Write CSR (Immediate) *

// `define INST_FCVT_W_S  22'b1110011_000_000000000001 // WRONG: uses SYSTEM opcode (1110011). FCVT.* are OP-FP (1010011); funct5=11000, fmt=00 (.S), rm in funct3; rs2=00000 selects W
`define INST_FCVT_W_S     17'b1010011_1100000_??? // FIX: FCVT.W.S → funct7=1100000 (funct5=11000,fmt=00), rm=???; NOTE: check rs2==00000 for W
// `define INST_FCVT_WU_S 22'b1110011_000_000000000101 // WRONG: SYSTEM opcode; FCVT.WU.S is OP-FP; same funct7 as FCVT.W.S; rs2 selects WU
`define INST_FCVT_WU_S    17'b1010011_1100000_??? // FIX: FCVT.WU.S → funct7=1100000, rm=???; NOTE: check rs2==00001 for WU
// `define INST_FCVT_S_W  22'b1110011_000_000000001001 // WRONG: SYSTEM opcode; FCVT.S.W is OP-FP; funct5=11010, fmt=00 (.S); rm in funct3; rs2 selects W
`define INST_FCVT_S_W     17'b1010011_1101000_??? // FIX: FCVT.S.W → funct7=1101000 (funct5=11010,fmt=00), rm=???; NOTE: check rs2==00000 for W
// `define INST_FCVT_S_WU 22'b1110011_000_000000001101 // WRONG: SYSTEM opcode; same family as above; rs2 selects WU
`define INST_FCVT_S_WU    17'b1010011_1101000_??? // FIX: FCVT.S.WU → funct7=1101000, rm=???; NOTE: check rs2==00001 for WU
// `define INST_FMV_X_W   22'b1110011_000_000000010001 // WRONG: SYSTEM opcode; FMV.X.W is OP-FP; funct5=11100, fmt=00 (.S); unary (rs2=0); funct3=000
`define INST_FMV_X_W      17'b1010011_1110000_000 // FIX: FMV.X.W → funct7=1110000 (funct5=11100,fmt=00), funct3=000; NOTE: check rs2==00000
// `define INST_FMV_W_X   22'b1110011_000_000000010101 // WRONG: SYSTEM opcode; FMV.W.X is OP-FP; funct5=11110, fmt=00 (.S); unary (rs2=0); funct3=000
`define INST_FMV_W_X      17'b1010011_1111000_000 // FIX: FMV.W.X → funct7=1111000 (funct5=11110,fmt=00), funct3=000; NOTE: check rs2==00000
// `define INST_FMV_S_X   22'b1110011_000_000000010001 // WRONG/DUPLICATE alias of FMV.X.W with swapped letters; keep FMV.X.W and remove this alias
`define INST_FMV_S_X      17'b1010011_1110000_000 // FIX: same encoding as FMV.X.W; prefer FMV.X.W name; NOTE: rs2==00000
// `define INST_FMV_X_S   22'b1110011_000_000000010101 // WRONG/DUPLICATE alias of FMV.W.X; keep FMV.W.X and remove this alias
`define INST_FMV_X_S      17'b1010011_1111000_000 // FIX: same encoding as FMV.W.X; prefer FMV.W.X name; NOTE: rs2==00000
// `define INST_FCVT_W_D  22'b1110011_000_000000000001 // WRONG: SYSTEM opcode; FCVT.W.D is OP-FP; funct5=11000, fmt=01 (.D); rm in funct3; rs2 selects W
`define INST_FCVT_W_D     17'b1010011_1100001_??? // FIX: FCVT.W.D → funct7=1100001 (funct5=11000,fmt=01), rm=???; NOTE: rs2==00000 (W)
// `define INST_FCVT_WU_D 22'b1110011_000_000000000101 // WRONG: SYSTEM opcode; same family; rs2 selects WU
`define INST_FCVT_WU_D    17'b1010011_1100001_??? // FIX: FCVT.WU.D → funct7=1100001, rm=???; NOTE: rs2==00001 (WU)
// `define INST_FCVT_D_W  22'b1110011_000_000000001001 // WRONG: SYSTEM opcode; FCVT.D.W is OP-FP; funct5=11010, fmt=01 (.D); rm in funct3; rs2 selects W
`define INST_FCVT_D_W     17'b1010011_1101001_??? // FIX: FCVT.D.W → funct7=1101001 (funct5=11010,fmt=01), rm=???; NOTE: rs2==00000 (W)
// `define INST_FCVT_D_WU 22'b1110011_000_000000001101 // WRONG: SYSTEM opcode; rs2 selects WU
`define INST_FCVT_D_WU    17'b1010011_1101001_??? // FIX: FCVT.D.WU → funct7=1101001, rm=???; NOTE: rs2==00001 (WU)
// `define INST_FMV_X_D   22'b1110011_000_000000010001 // WRONG: SYSTEM opcode; FMV.X.D is OP-FP; funct5=11100, fmt=01 (.D); unary (rs2=0); funct3=000
`define INST_FMV_X_D      17'b1010011_1110001_000 // FIX: FMV.X.D → funct7=1110001 (funct5=11100,fmt=01), funct3=000; NOTE: rs2==00000
// `define INST_FMV_D_X   22'b1110011_000_000000010101 // WRONG: SYSTEM opcode; FMV.D.X is OP-FP; funct5=11110, fmt=01 (.D); unary (rs2=0); funct3=000
`define INST_FMV_D_X      17'b1010011_1111001_000 // FIX: FMV.D.X → funct7=1111001 (funct5=11110,fmt=01), funct3=000; NOTE: rs2==00000
// `define INST_FMV_D_X   22'b1110011_000_000000010101 // WRONG/DUPLICATE of the previous line; remove duplicate
`define INST_FMV_D_X_DUP  17'b1010011_1111001_000 // FIX: duplicate encoding; keep only one define name; NOTE: rs2==00000
// `define INST_FMV_X_D   22'b1110011_000_000000010001 // WRONG/DUPLICATE of FMV_X_D above; remove duplicate
`define INST_FMV_X_D_DUP  17'b1010011_1110001_000 // FIX: duplicate encoding; keep only one define name; NOTE: rs2==00000
// `define INST_FCVT_W_Q  22'b1110011_000_000000000001 // WRONG: SYSTEM opcode; FCVT.W.Q is OP-FP; funct5=11000, fmt=11 (.Q); rm in funct3; rs2 selects W
`define INST_FCVT_W_Q     17'b1010011_1100011_??? // FIX: FCVT.W.Q → funct7=1100011 (funct5=11000,fmt=11), rm=???; NOTE: rs2==00000 (W)
// `define INST_FCVT_WU_Q 22'b1110011_000_000000000101 // WRONG: SYSTEM opcode; rs2 selects WU
`define INST_FCVT_WU_Q    17'b1010011_1100011_??? // FIX: FCVT.WU.Q → funct7=1100011, rm=???; NOTE: rs2==00001 (WU)
// `define INST_FCVT_Q_W  22'b1110011_000_000000001001 // WRONG: SYSTEM opcode; FCVT.Q.W is OP-FP; funct5=11010, fmt=11 (.Q); rm in funct3; rs2 selects W
`define INST_FCVT_Q_W     17'b1010011_1101011_??? // FIX: FCVT.Q.W → funct7=1101011 (funct5=11010,fmt=11), rm=???; NOTE: rs2==00000 (W)
// `define INST_FCVT_Q_WU 22'b1110011_000_000000001101 // WRONG: SYSTEM opcode; rs2 selects WU
`define INST_FCVT_Q_WU    17'b1010011_1101011_??? // FIX: FCVT.Q.WU → funct7=1101011, rm=???; NOTE: rs2==00001 (WU)
// `define INST_FMV_X_Q   22'b1110011_000_000000010001 // WRONG: SYSTEM opcode; FMV.X.Q is OP-FP; funct5=11100, fmt=11 (.Q); unary (rs2=0); funct3=000
`define INST_FMV_X_Q      17'b1010011_1110011_000 // FIX: FMV.X.Q → funct7=1110011 (funct5=11100,fmt=11), funct3=000; NOTE: rs2==00000
// `define INST_FMV_Q_X   22'b1110011_000_000000010101 // WRONG: SYSTEM opcode; FMV.Q.X is OP-FP; funct5=11110, fmt=11 (.Q); unary (rs2=0); funct3=000
`define INST_FMV_Q_X      17'b1010011_1111011_000 // FIX: FMV.Q.X → funct7=1111011 (funct5=11110,fmt=11), funct3=000; NOTE: rs2==00000


/////////////////////////////////////
/// Other (operand)
/////////////////////////////////////

`define INST_AUIPC  10'b0010111 // S Add upper immediate to pc
`define INST_LUI    10'b0110111 // I Load upper immediate
`define INST_JAL    10'b1101111 // I Jump and link
`define INST_JALR   10'b1100111 // I Jump and link register

`endif // __INSTRUCTIONS__
