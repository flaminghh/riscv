# Project Onboarding Guide

Welcome to the RISC-V SoC project! This guide summarizes the repository layout, the most important modules, and suggests a learning path to become productive quickly.

## Repository Layout

| Path | Purpose |
| --- | --- |
| [`docs/`](./) | Documentation, background material, and this onboarding guide. Start with [`docs/README.md`](./README.md) for a high-level overview and toolchain requirements. |
| [`src/`](../src) | Synthesizable SystemVerilog source for the CPU core, TileLink fabric, peripherals, and SoC wrappers. Each module is written for clarity and is heavily documented. |
| [`test/`](../test) | SystemVerilog testbenches for unit and integration testing. Every new hardware block should ship with a companion testbench. |
| [`etc/`](../etc) | Supporting software and scripts (e.g., BIOS, bare-metal demos, simulation runners, and FPGA loader helpers). |

The build system is centered around GNU Make. The [`Makefile`](../Makefile) delegates to configuration-specific makefiles (e.g., `Makefile9k.mk`) and exposes common targets such as `run_cpu`, `run_soc`, `test`, and FPGA synthesis flows described in the main README.

## Key Hardware Blocks

The design is built around a modular TileLink-UL fabric:

- **`src/tl_cpu.sv`** – A single-issue RV32/RV64 core with optional `M`, `Zicsr`, and `B` extensions. It fetches, decodes, executes, and performs memory transactions through a TL-UL interface while handling traps and interrupts. 【F:src/tl_cpu.sv†L1-L111】
- **`src/tl_soc.sv`** – The top-level SoC wrapper that instantiates the CPU, TileLink switch, on-chip memory, BIOS ROM, and basic peripherals (UART, GPIO LEDs). It maps them into a simple address space for FPGA targets. 【F:src/tl_soc.sv†L1-L111】
- **`src/tl_switch.sv` & `src/tl_interface.sv`** – Provide TileLink master/slave arbitration and protocol translation between the CPU and devices. (See in-source comments for detailed timing expectations.)
- **Memory & Peripherals** – `tl_memory.sv` implements on-chip RAM; `tl_ul_bios.sv` and `tl_ul_output.sv` expose ROM/output devices; `tl_ul_uart.sv` offers a memory-mapped UART used both in simulation and on FPGA.
- **CPU Subsystems** – Modules such as `cpu_alu.sv`, `cpu_regfile.sv`, `cpu_mdu.sv`, `cpu_bmu.sv`, and `cpu_csr.sv` provide arithmetic, register, multiply/divide, bit-manipulation, and CSR functionality, respectively. They are included from `tl_cpu.sv` to keep the core organized.

## Simulation, Testing, and FPGA Flow

- **Simulation** – `make run_cpu` runs the core against `etc/main.c` via `etc/run.sv`, while `make run_soc` brings up the full SoC using the BIOS in `etc/bios/`. Waveforms are emitted to `graph/*.vcd` for debugging. 【F:docs/README.md†L42-L73】
- **Unit & Integration Tests** – Each major module has a companion testbench in `test/` (for example, `test/cpu_alu_tb.sv`, `test/tl_switch_tb.sv`). `make test_<name>` runs an individual test, and `make test` sweeps all registered benches. 【F:docs/README.md†L88-L95】
- **FPGA Builds** – `make` synthesizes the SoC for the Tang Nano 20K by default, compiling the BIOS beforehand. Use `make load` with `openFPGALoader` to program the board, and `make clean` between builds when RTL changes. 【F:docs/README.md†L75-L87】

## Coding & Contribution Practices

- Clarity is preferred over micro-optimizations—write code that is easy to follow. 【F:docs/CONTRIBUTING.md†L11-L16】
- Every new feature should include a testbench and be guarded by a configuration flag (`SUPPORT_*`) when applicable, keeping optional IP disabled by default. 【F:docs/CONTRIBUTING.md†L18-L19】【F:docs/CONTRIBUTING.md†L41-L75】
- Before contributing, skim the TODO list in [`docs/CONTRIBUTING.md`](./CONTRIBUTING.md) to find open areas like TileLink-UH support, CSR expansion, BIOS enhancements, and peripheral additions. 【F:docs/CONTRIBUTING.md†L21-L75】

## Suggested Learning Path

1. **Review Documentation** – Read `docs/README.md` for the architectural overview and tool requirements, then study the in-line comments in `tl_cpu.sv` and `tl_soc.sv` to understand module responsibilities.
2. **Run the Simulations** – Build and simulate with `make run_cpu` and `make run_soc` to observe the waveforms and logs. Experiment with toggling `XLEN` and extension flags to see how configuration parameters propagate.
3. **Explore Testbenches** – Inspect a unit test like `test/cpu_alu_tb.sv` to learn the project's verification patterns before writing your own.
4. **Tackle a TODO Item** – Pick an item from the CONTRIBUTING guide that matches your interests (e.g., extending CSR support, adding a new peripheral, or improving the BIOS loader).

Following this path will provide a solid understanding of how the modules interact, how to validate changes, and where you can make impactful contributions next.
