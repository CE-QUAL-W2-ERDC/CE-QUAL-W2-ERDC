# Changelog

All notable changes to this version of CE-QUAL-W2 are recorded in this file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Releases are numbered by year and month, vYYYY.MM. A second release in the same month adds a sequence number, as in vYYYY.MM.1. Each release is a git tag, and its executables are attached to the matching GitHub release. W2VER, the model version written into output headers, remains 4.5.

## [2026.10] - 2026-10-09

Model results are unchanged from v2026.02: on the verification models, v2026.10 reproduces the water levels, velocities, temperatures, dissolved oxygen, and all other constituents of v2026.02 built with the same compiler and flags. The detailed notes and the verification are in [docs/release-notes/v2026.10.md](docs/release-notes/v2026.10.md).

### Fixed

- A run that stops on an error now reports failure. It prints the Julian day, the error message, and the first lines of `w2.err`, sets `w2_status.json` to "failed", and ends with exit status 1. Previously every run ended with exit status 0 and printed "Simulation completed."
- Kinetic-flux output (`kflux_wb*.csv`, `flx*.opt`) no longer counts a surface cell's accumulated mass twice when a layer is added, and the reset after each output covers the whole waterbody. The model state was not affected.
- The wind-function conversion BCONV is defined for every value of CFW (`heat-exchange.f90`).
- The released-bubble count in sediment diagenesis is converted to an 8-byte integer, matching its declaration.
- Iteration counts above 999,999 print in full.
- The day of the last algal-rate update (`iday`) starts from a defined value.

### Changed

- The console banner and `W2CodeCompilerVersion.opt` give the release, and `W2CodeCompilerVersion.opt` records the compiler version and options.
- The Fortran runtime libraries are linked statically, so an executable does not depend on the compiler installed on the computer that runs it.
- `w2_status.json` is written at most once per second of wall-clock time instead of at every time step.
- The source code is reformatted; results are unchanged.

### Added

- Optional floating-point exception trapping: `make FPE_TRAP=1`.
- `make test` in `src` builds and runs the HAB unit tests.

## [2026.02] - 2026-02-22

### Added

- Builds on Windows with MinGW-w64 gfortran: `Makefile.win` for `mingw32-make`, and `build.bat` for building without make.
- `MODULE PLATFORM` in `w2modules.F90`, which sets the path separator and the file copy and directory commands for Windows or Unix at compile time.
- Instructions for compiling on Windows (`docs/compiling/compiling_for_Windows.md`) and a README.

### Changed

- Hard-coded Windows path separators and copy and directory commands in `time-varying-data.f90` and `Diagenesis Input 02.f90` are replaced with the platform settings, and `fishhabitat.f90` recognizes both separators.
- `SLEEPQQ` now pauses on Unix as it does on Windows; it previously returned immediately (`unix_stubs.f90`).

## [2026.01] - 2026-02-22

The first release of this version: CE-QUAL-W2 v4.5 from Portland State University (PSU), July 2025, merged with ERDC's version of the model, which adds harmful algal bloom (HAB) features and builds with gfortran on macOS and Linux. ERDC led the HAB development. The HAB features were developed by LimnoTech for ERDC, and ERDC revised and extended them.

### Added

- HAB features, each turned on by placing its input file in the run directory (see `docs/HAB_Features_User_Manual.md`):
  - low dissolved oxygen algal mortality and a minimum algae concentration (`low_do_mort_input.csv`)
  - nitrogen fixation (`nfix_option_input.csv`)
  - algal harvesting (`harvest_option_input.csv` and a harvest time series)
- Harvesting extensions by ERDC: a maximum harvest depth for each harvest segment (HADEP; the default, 0, harvests all layers), and the harvested mass for each event and in total, written to `harvest_mass_output.csv`.
- gfortran build for macOS and Linux, with a Unix main program, console output, and the run status file `w2_status.json`.
- HAB unit tests in `tests/hab` (82 tests).
- HAB user manual and example input files in `docs/`.

### Fixed

- Algal harvesting was never applied, because the mapping of harvest segments to branches (JBHA) had been lost when the code was merged.
- With several harvest segments, only the first was fully processed.
- The harvest fraction is again limited to the range 0 to 1.
- Reaching the end of a harvest time-series file stops harvesting instead of stopping the run.
- Models without BOD groups (NBOD = 0) stopped under gfortran's run-time checks; arrays that are not allocated in that case are no longer accessed. DERIVED_CONSTITUENTS is no longer called inside a loop over waterbodies, because it runs its own loop over waterbodies with the same module variable.
- Total dissolved gas target operation (`TDGtarget.f90`): the minimum spillway flow fraction was indexed by gate number instead of by target, and the powerhouse test used the spillway gate flow.
- The sediment diagenesis flux output files contained only labels; the values are now written, as is the aerobic layer thickness (H1) file.
- Rows of the time-series (TSR) output have the same columns as the header whether or not epiphyton is computed.
- W2L output is written as a stream file, matching the layout of Intel Fortran's BINARY files.
- Withdrawal output file names may contain either `/` or `\` path separators.

## Base: CE-QUAL-W2 v4.5, PSU source of 2025-07-07

The base of this version, tagged `psu-v4.5-2025-07-07`, is the CE-QUAL-W2 v4.5 source released by PSU (Dr. Scott Wells and Dr. Zhong Zhang). PSU's v4.5 already includes processes for cyanobacteria, among them vertical migration through variable, buoyancy-driven algal settling (Overman 2019) and algal toxin production (Garstecki 2021, 2023), as described in Part 1 of the PSU user manual. The manual notes that many v4.5 features were supported by the ERDC Environmental Laboratory and the Portland District of the U.S. Army Corps of Engineers. `git diff psu-v4.5-2025-07-07 v2026.10 -- src` shows every change made to the PSU source.
