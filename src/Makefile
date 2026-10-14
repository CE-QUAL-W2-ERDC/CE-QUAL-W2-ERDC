#******************************************************************************
# CE-QUAL-W2 Makefile for gfortran on MacOS/Unix
#
# This Makefile compiles the CE-QUAL-W2 model using gfortran instead of
# the Intel Fortran compiler (ifort).
#
# Release v2026.10
#
# Usage:
#   make            - Build the executable
#   make FPE_TRAP=1 - Build with floating-point exception trapping (see below)
#   make clean      - Remove object files, modules, and executable
#   make distclean  - Remove all generated files including backup files
#
# Run "make clean" before switching between FPE_TRAP=1 and the default build; the
# object files do not record the flags they were compiled with.
#
# Created: November 2025
#******************************************************************************

# Compiler and flags
FC = gfortran
PROGRAM = ce-qual-w2

# Compiler flags
FFLAGS = -O2 \
         -ffree-form \
         -ffree-line-length-none \
         -fbacktrace \
         -fall-intrinsics \
         -fno-align-commons \
         -cpp \
         -fdefault-real-8 \
         -fdefault-double-8 \
         -fmax-stack-var-size=0

# Part of the release configuration; do not remove for production builds.
# -finit-local-zero sets local scalars to zero on entry and static local arrays once.
# -fcheck=all stops the run with a message at an out-of-bounds index or other run-time error.
# With gfortran 16.2 the checks also change the generated floating-point code: a build without
# them gave different results within the first model day of the 2001 baseline
# (docs/release-notes/v2026.10.md). Keeping these flags keeps the numerics of the v2026.02 builds,
# which use the same flags. -g adds debug information only. The checks roughly double the run time.
DEBUG_FLAGS = -g  -finit-local-zero -fcheck=all -fcheck=bounds
FFLAGS += $(DEBUG_FLAGS)

# Link the Fortran runtime statically so that a later Homebrew GCC upgrade cannot change
# the runtime used by an existing executable (a dynamically linked build loads libgfortran
# from /opt/homebrew/opt/gcc/lib/gcc/current at run time). Check with: otool -L ce-qual-w2
LDFLAGS = -static-libgfortran -static-libgcc -static-libquadmath

# Optional floating-point exception trapping, off by default:  make FPE_TRAP=1
# Stops the run at the first invalid operation, division by zero or overflow, as the Intel
# Release|x64 build does with /fpe:0 (underflow does not trap). The trap does not change the
# arithmetic, so a run that completes without a trap gives the same results as the default build.
# On Apple Silicon the trap arrives as SIGILL (exit status 132), not SIGFPE; the gfortran
# backtrace names the routine, but its line number can be that of the last call before the
# trapping instruction. Run under lldb for the exact line:
#   lldb --batch -o "process launch" -k "bt 20" -k "quit 1" -- ./ce-qual-w2
ifeq ($(FPE_TRAP),1)
FFLAGS += -ffpe-trap=invalid,zero,overflow
endif

# Optional OpenMP support (currently not used)
# FFLAGS += -fopenmp

#******************************************************************************
# Source files - ORDER MATTERS due to module dependencies
#******************************************************************************

# Module definition file (MUST be compiled first)
MODULE_SRC = w2modules.F90

# Subroutine source files (in approximate dependency order)
SUBROUTINE_SRCS = \
	preprocessor_definitions.fpp \
	date.f90 \
	density.f90 \
	systdg.f90 \
	tdg.f90 \
	TDGtarget.f90 \
	MetFileRegion.f90 \
	ReduceReaerAlgae.f90 \
	Plunge_Point.f90 \
	shading.f90 \
	gas-transfer.f90 \
	heat-exchange.f90 \
	macrophyte-aux.f90 \
	aerate.f90 \
	envir_perf.f90 \
	fishhabitat.f90 \
	particle.f90 \
	az.f90 \
	Diagenesis\ Input\ Files\ Read\ 01.f90 \
	Diagenesis\ Input\ 02.f90 \
	Diagenesis\ FFT\ Layer\ 01.f90 \
	Diagenesis\ Sediment\ Flux\ Model\ 05.f90 \
	Diagenesis\ Sediment\ Model\ 03.f90 \
	Diagenesis\ Bubbles\ Code\ 01.f90 \
	Diagenesis\ Output\ 02.f90 \
	wqconstituents.F90 \
	water-quality.f90 \
	transport.f90 \
	temperature.F90 \
	gate-spill-pipe.f90 \
	withdrawal.f90 \
	waterbody.f90 \
	init-u-elws.f90 \
	init-geom.F90 \
	init-cond.F90 \
	hydroinout.F90 \
	time-varying-data.f90 \
	layeraddsub.F90 \
	balances.F90 \
	update.F90 \
	restart.f90 \
	output.f90 \
	outputa2w2tools.F90 \
	outputinitw2tools.F90 \
	endsimulation.F90 \
	init.F90 \
	input.F90 \
	screen_output_unix.f90 \
	status_output.f90 \
	unix_stubs.f90

# Main program
MAIN_SRC = w2_4_unix.f90

# All source files
ALL_SRCS = $(MODULE_SRC) $(SUBROUTINE_SRCS) $(MAIN_SRC)

# Object files (derived from source files)
MODULE_OBJ = $(MODULE_SRC:.F90=.o)
SUBROUTINE_OBJS = $(SUBROUTINE_SRCS:.f90=.o)
SUBROUTINE_OBJS := $(SUBROUTINE_OBJS:.F90=.o)
SUBROUTINE_OBJS := $(SUBROUTINE_OBJS:.fpp=.o)
MAIN_OBJ = $(MAIN_SRC:.f90=.o)

ALL_OBJS = $(MODULE_OBJ) $(SUBROUTINE_OBJS) $(MAIN_OBJ)

#******************************************************************************
# Targets
#******************************************************************************

# Default target
all: $(PROGRAM)

# Link all object files to create executable
$(PROGRAM): $(ALL_OBJS)
	@echo "=================================================="
	@echo "Linking $(PROGRAM)..."
	@echo "=================================================="
	$(FC) $(FFLAGS) $(LDFLAGS) -o $@ $(ALL_OBJS)
	@echo ""
	@echo "Build successful! Executable: $(PROGRAM)"
	@echo ""

# Compile module file first (creates .mod files needed by other sources)
$(MODULE_OBJ): $(MODULE_SRC)
	@echo "Compiling modules: $<"
	$(FC) $(FFLAGS) -c $<

# Pattern rules for compiling source files
%.o: %.f90
	@echo "Compiling: $<"
	$(FC) $(FFLAGS) -c $<

%.o: %.F90
	@echo "Compiling (preprocessed): $<"
	$(FC) $(FFLAGS) -c $<

%.o: %.fpp
	@echo "Compiling (preprocessed): $<"
	$(FC) $(FFLAGS) -c $<

# Special handling for files with spaces in names
Diagenesis\ Input\ Files\ Read\ 01.o: Diagenesis\ Input\ Files\ Read\ 01.f90
	@echo "Compiling: $<"
	$(FC) $(FFLAGS) -c "$<"

Diagenesis\ Input\ 02.o: Diagenesis\ Input\ 02.f90
	@echo "Compiling: $<"
	$(FC) $(FFLAGS) -c "$<"

Diagenesis\ FFT\ Layer\ 01.o: Diagenesis\ FFT\ Layer\ 01.f90
	@echo "Compiling: $<"
	$(FC) $(FFLAGS) -c "$<"

Diagenesis\ Sediment\ Model\ 03.o: Diagenesis\ Sediment\ Model\ 03.f90
	@echo "Compiling: $<"
	$(FC) $(FFLAGS) -c "$<"

Diagenesis\ Sediment\ Flux\ Model\ 05.o: Diagenesis\ Sediment\ Flux\ Model\ 05.f90
	@echo "Compiling: $<"
	$(FC) $(FFLAGS) -c "$<"

Diagenesis\ Bubbles\ Code\ 01.o: Diagenesis\ Bubbles\ Code\ 01.f90
	@echo "Compiling: $<"
	$(FC) $(FFLAGS) -c "$<"

Diagenesis\ Output\ 02.o: Diagenesis\ Output\ 02.f90
	@echo "Compiling: $<"
	$(FC) $(FFLAGS) -c "$<"

# Dependency rules (ensures modules are compiled before files that use them)
$(SUBROUTINE_OBJS): $(MODULE_OBJ)
$(MAIN_OBJ): $(MODULE_OBJ) $(SUBROUTINE_OBJS)

#******************************************************************************
# Clean targets
#******************************************************************************

clean:
	@echo "Cleaning object files and modules..."
	rm -f *.o *.mod *.smod
	@echo "Clean complete."

distclean: clean
	@echo "Removing executable and backup files..."
	rm -f $(PROGRAM)
	rm -f *.dwf *.pdb
	@echo "Distclean complete."

#******************************************************************************
# Help target
#******************************************************************************

help:
	@echo "CE-QUAL-W2 Makefile for gfortran"
	@echo ""
	@echo "Available targets:"
	@echo "  make           - Build the CE-QUAL-W2 executable"
	@echo "  make clean     - Remove object files and modules"
	@echo "  make distclean - Remove all generated files"
	@echo "  make help      - Show this help message"
	@echo "  make test      - Build and run the HAB unit tests"
	@echo ""
	@echo "Options:"
	@echo "  make FPE_TRAP=1 - Trap invalid, divide-by-zero and overflow"
	@echo ""
	@echo "Compiler: $(FC)"
	@echo "Flags: $(FFLAGS)"
	@echo "Link flags: $(LDFLAGS)"
	@echo ""

test:
	$(MAKE) -C ../tests/hab test

.PHONY: all clean distclean help test
