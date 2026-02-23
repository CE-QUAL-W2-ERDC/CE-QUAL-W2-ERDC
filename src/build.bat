@echo off
REM ******************************************************************************
REM CE-QUAL-W2 Build Script for gfortran on Windows
REM
REM Usage:
REM   build           - Build the executable
REM   build clean     - Remove object files and modules
REM   build distclean - Remove all generated files including executable
REM
REM Prerequisites:
REM   - gfortran (MinGW-w64) in PATH
REM
REM Created: February 2026
REM ******************************************************************************

setlocal enabledelayedexpansion

REM Compiler and flags
set FC=gfortran
set PROGRAM=ce-qual-w2.exe
set FFLAGS=-O2 -ffree-form -ffree-line-length-none -fbacktrace -fall-intrinsics -fno-align-commons -cpp -fdefault-real-8 -fdefault-double-8 -fmax-stack-var-size=0

REM Debug flags (comment out for production builds)
set DEBUG_FLAGS=-g -finit-local-zero -fcheck=all -fcheck=bounds
set FFLAGS=%FFLAGS% %DEBUG_FLAGS%

REM Parse command
if "%1"=="clean" goto :clean
if "%1"=="distclean" goto :distclean
if "%1"=="help" goto :help
goto :build

REM ******************************************************************************
:build
REM ******************************************************************************

echo ==================================================
echo  CE-QUAL-W2 Build for Windows gfortran
echo ==================================================
echo.

REM Verify gfortran is available
where gfortran >nul 2>&1
if errorlevel 1 (
    echo ERROR: gfortran not found in PATH.
    echo Install MinGW-w64 and add its bin directory to PATH.
    exit /b 1
)

REM Step 1: Compile modules (must be first)
echo [1/4] Compiling modules...
%FC% %FFLAGS% -c w2modules.F90
if errorlevel 1 goto :error
%FC% %FFLAGS% -c preprocessor_definitions.fpp
if errorlevel 1 goto :error

REM Step 2: Compile subroutines
echo [2/4] Compiling subroutines...
for %%f in (date.f90 density.f90 systdg.f90 tdg.f90 TDGtarget.f90 MetFileRegion.f90 ReduceReaerAlgae.f90 Plunge_Point.f90 shading.f90 gas-transfer.f90 heat-exchange.f90 macrophyte-aux.f90 aerate.f90 envir_perf.f90 fishhabitat.f90 particle.f90 az.f90) do (
    echo   Compiling: %%f
    %FC% %FFLAGS% -c "%%f"
    if errorlevel 1 goto :error
)

REM Diagenesis files (have spaces in names)
for %%f in ("Diagenesis Input Files Read 01.f90" "Diagenesis Input 02.f90" "Diagenesis FFT Layer 01.f90" "Diagenesis Sediment Flux Model 05.f90" "Diagenesis Sediment Model 03.f90" "Diagenesis Bubbles Code 01.f90" "Diagenesis Output 02.f90") do (
    echo   Compiling: %%~f
    %FC% %FFLAGS% -c %%f
    if errorlevel 1 goto :error
)

REM Preprocessed F90 and remaining f90 files
echo [3/4] Compiling remaining sources...
for %%f in (wqconstituents.F90 water-quality.f90 transport.f90 temperature.F90 gate-spill-pipe.f90 withdrawal.f90 waterbody.f90 init-u-elws.f90 init-geom.F90 init-cond.F90 hydroinout.F90 time-varying-data.f90 layeraddsub.F90 balances.F90 update.F90 restart.f90 output.f90 outputa2w2tools.F90 outputinitw2tools.F90 endsimulation.F90 init.F90 input.F90 screen_output_unix.f90 status_output.f90 unix_stubs.f90) do (
    echo   Compiling: %%f
    %FC% %FFLAGS% -c "%%f"
    if errorlevel 1 goto :error
)

REM Main program
echo   Compiling: w2_4_unix.f90
%FC% %FFLAGS% -c w2_4_unix.f90
if errorlevel 1 goto :error

REM Step 4: Link
echo [4/4] Linking %PROGRAM%...
%FC% %FFLAGS% -o %PROGRAM% w2modules.o preprocessor_definitions.o date.o density.o systdg.o tdg.o TDGtarget.o MetFileRegion.o ReduceReaerAlgae.o Plunge_Point.o shading.o gas-transfer.o heat-exchange.o macrophyte-aux.o aerate.o envir_perf.o fishhabitat.o particle.o az.o "Diagenesis Input Files Read 01.o" "Diagenesis Input 02.o" "Diagenesis FFT Layer 01.o" "Diagenesis Sediment Flux Model 05.o" "Diagenesis Sediment Model 03.o" "Diagenesis Bubbles Code 01.o" "Diagenesis Output 02.o" wqconstituents.o water-quality.o transport.o temperature.o gate-spill-pipe.o withdrawal.o waterbody.o init-u-elws.o init-geom.o init-cond.o hydroinout.o time-varying-data.o layeraddsub.o balances.o update.o restart.o output.o outputa2w2tools.o outputinitw2tools.o endsimulation.o init.o input.o screen_output_unix.o status_output.o unix_stubs.o w2_4_unix.o
if errorlevel 1 goto :error

echo.
echo ==================================================
echo  Build successful! Executable: %PROGRAM%
echo ==================================================
goto :eof

REM ******************************************************************************
:clean
REM ******************************************************************************
echo Cleaning object files and modules...
if exist *.o del /q *.o
if exist *.mod del /q *.mod
if exist *.smod del /q *.smod
echo Clean complete.
goto :eof

REM ******************************************************************************
:distclean
REM ******************************************************************************
call :clean
echo Removing executable...
if exist %PROGRAM% del /q %PROGRAM%
if exist *.dwf del /q *.dwf
if exist *.pdb del /q *.pdb
echo Distclean complete.
goto :eof

REM ******************************************************************************
:help
REM ******************************************************************************
echo CE-QUAL-W2 Build Script for gfortran on Windows
echo.
echo Usage:
echo   build           - Build the CE-QUAL-W2 executable
echo   build clean     - Remove object files and modules
echo   build distclean - Remove all generated files
echo   build help      - Show this help message
echo.
goto :eof

REM ******************************************************************************
:error
REM ******************************************************************************
echo.
echo ==================================================
echo  BUILD FAILED - see errors above
echo ==================================================
exit /b 1
