# CE-QUAL-W2 (ERDC HAB Version)

CE-QUAL-W2 is a two-dimensional, laterally averaged hydrodynamic and water quality model for rivers, lakes, reservoirs, and estuaries. This version (4.5) includes Harmful Algal Bloom (HAB) capabilities developed under the lead of the U.S. Army Engineer Research and Development Center (ERDC).

## Features

- 2D laterally averaged hydrodynamics (momentum, continuity, free surface)
- Water quality kinetics: algae, nutrients, organic matter, dissolved oxygen, sediment diagenesis
- HAB capabilities: low DO mortality, algal harvesting, nitrogen fixation, minimum algae seeding
- Structures: gates, spillways, pipes, pumps
- Total dissolved gas (TDG) modeling
- Fish habitat and bioenergetics
- Cross-platform: builds with gfortran on Windows, macOS, and Linux

## Building

### Prerequisites

- **gfortran** (GCC 9.0+)
  - macOS: `brew install gcc`
  - Linux: `sudo apt-get install gfortran`
  - Windows: Install [MinGW-w64](https://www.mingw-w64.org) and add to PATH

### macOS / Linux

```bash
cd src
make clean && make
```

Produces the `ce-qual-w2` executable.

### Windows (with mingw32-make)

```cmd
cd src
mingw32-make -f Makefile.win all
```

### Windows (without make)

```cmd
cd src
build
```

Produces the `ce-qual-w2.exe` executable.

## Testing

The HAB unit tests build and run with:

```bash
cd src
make test
```

or, equivalently, `make test` in `tests/hab`.

## Running

```bash
cd /path/to/model/case    # directory containing w2_con.npt or w2_con.csv
/path/to/ce-qual-w2       # or ce-qual-w2.exe on Windows
```

For large models on Unix, increase the stack size first:
```bash
ulimit -s unlimited
```

## Releases

Releases are numbered by year and month (for example, v2026.10) and are tagged in git. Executables for each release are attached to the corresponding GitHub release. Changes in each release are listed in [CHANGELOG.md](CHANGELOG.md).

## Repository Structure

```
src/                       Source code
  w2modules.F90              Module definitions (all shared data structures)
  w2_4_unix.f90              Main program
  input.F90                  Control file parsing
  water-quality.f90          KINETICS subroutine
  transport.f90              TVD advection-dispersion
  time-varying-data.f90      Time-varying boundary conditions
  Makefile                   Build system (macOS/Linux)
  Makefile.win               Build system (Windows)
  build.bat                  Build script (Windows, no make required)
tests/hab/                 HAB unit tests
docs/
  compiling/                 Compiling on Windows
  examples/hab/              Example HAB input files
  release-notes/             Detailed release notes
  HAB_Features_User_Manual.md
CHANGELOG.md               Changes in each release
```

## HAB Features

Four optional HAB features, activated by placing the corresponding CSV file in the model run directory:

| Feature | Input File | Description |
|---------|-----------|-------------|
| Low DO mortality | `low_do_mort_input.csv` | Enhanced algal mortality under low dissolved oxygen |
| Minimum algae (seed) | `low_do_mort_input.csv` | Maintains minimum algal concentration |
| Algal harvesting | `harvest_option_input.csv` | Removes algae from specified segments/depths |
| Nitrogen fixation | `nfix_option_input.csv` | Cyanobacteria nitrogen fixation under low N:P ratios |

See `docs/HAB_Features_User_Manual.md` for details.

## Credits

CE-QUAL-W2 is developed at Portland State University (PSU). This version is based on the PSU v4.5 source of July 7, 2025. ERDC led the development of the HAB features in this version: they were developed by LimnoTech for ERDC, and ERDC revised and extended them and ported the model to gfortran.

## Maintainers

- Dr. Scott Wells (wellss@pdx.edu), Portland State University
- Dr. Zhong Zhang, Portland State University
- Dr. Todd Steissberg, ERDC

## License

This repository is released under the BSD 3-Clause License; see [LICENSE](LICENSE). The CE-QUAL-W2 v4.5 source from PSU is under the MIT License, and its notice is kept in the header of `src/w2modules.F90`.
