#******************************************************************************
# CE-QUAL-W2 HAB Unit Tests Makefile
#
# Usage:
#   make test    - Build and run all tests
#   make build   - Build test executable only
#   make clean   - Remove generated files
#******************************************************************************

FC = gfortran
PROGRAM = run_hab_tests

# Match production precision flags; use -O0 and full debug for tests
FFLAGS = -O0 \
         -ffree-form \
         -ffree-line-length-none \
         -fbacktrace \
         -fall-intrinsics \
         -cpp \
         -fdefault-real-8 \
         -fdefault-double-8 \
         -g \
         -finit-local-zero \
         -fcheck=all \
         -fcheck=bounds

# Source directory for shared modules
SRC_DIR = ../../src

#******************************************************************************
# Source files — order matters due to module dependencies
#******************************************************************************

# Only need PREC module from w2modules.F90
MODULE_SRC = $(SRC_DIR)/w2modules.F90

# Test sources in dependency order
TEST_SRCS = test_framework.F90 \
            test_harvest_algo.F90 \
            test_harvest_mass.F90 \
            test_harvest_input.F90 \
            test_low_do_mort.F90 \
            test_low_do_input.F90 \
            test_alg_min.F90 \
            test_nfix.F90 \
            test_nfix_input.F90

MAIN_SRC = run_all_tests.F90

# Object files
MODULE_OBJ = w2modules.o
TEST_OBJS = $(TEST_SRCS:.F90=.o)
MAIN_OBJ = run_all_tests.o

ALL_OBJS = $(MODULE_OBJ) $(TEST_OBJS) $(MAIN_OBJ)

#******************************************************************************
# Targets
#******************************************************************************

.PHONY: test build clean

test: build
	@echo ""
	@echo "Running HAB unit tests..."
	@echo ""
	@./$(PROGRAM)

build: $(PROGRAM)

$(PROGRAM): $(ALL_OBJS)
	@echo "Linking $(PROGRAM)..."
	$(FC) $(FFLAGS) -o $@ $(ALL_OBJS)

# Compile w2modules from parent source directory
$(MODULE_OBJ): $(MODULE_SRC)
	@echo "Compiling modules: $<"
	$(FC) $(FFLAGS) -c $< -o $@

# Pattern rule for test sources
%.o: %.F90
	@echo "Compiling: $<"
	$(FC) $(FFLAGS) -c $<

# Dependencies
$(TEST_OBJS): $(MODULE_OBJ)
test_harvest_algo.o test_harvest_mass.o test_harvest_input.o \
test_low_do_mort.o test_low_do_input.o test_alg_min.o \
test_nfix.o test_nfix_input.o: test_framework.o
$(MAIN_OBJ): $(MODULE_OBJ) $(TEST_OBJS)

clean:
	@echo "Cleaning test build files..."
	rm -f *.o *.mod *.smod $(PROGRAM)
	rm -f _test_*.csv
	@echo "Clean complete."
