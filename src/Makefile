#******************************************************************************
# CE-QUAL-W2 Makefile for gfortran on MacOS/Unix
#
# This Makefile compiles the CE-QUAL-W2 model using gfortran instead of
# the Intel Fortran compiler (ifort).
#
# Usage:
#   make           - Build the executable
#   make clean     - Remove object files, modules, and executable
#   make distclean - Remove all generated files including backup files
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

# Optional flags for debugging (uncomment as needed)
DEBUG_FLAGS = -g  -finit-local-zero -fcheck=all -fcheck=bounds 
FFLAGS += $(DEBUG_FLAGS)

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
	$(FC) $(FFLAGS) -o $@ $(ALL_OBJS)
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
	@echo ""
	@echo "Compiler: $(FC)"
	@echo "Flags: $(FFLAGS)"
	@echo ""

.PHONY: all clean distclean help
