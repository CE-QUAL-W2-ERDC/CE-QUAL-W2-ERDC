# CE-QUAL-W2 HAB Features User Manual

## Overview

CE-QUAL-W2 Version 4.5 (ERDC/PSU) includes four optional features for Harmful Algal Bloom (HAB) simulation:

1. **Minimum Algae (Seed Population)** -- maintains a floor concentration so algae can regrow after crash events
2. **Low DO Mortality** -- increases algal mortality when dissolved oxygen stays low for an extended period
3. **Algal Harvesting** -- removes a fraction of algae from specified segments on a time-varying schedule
4. **Nitrogen Fixation** -- allows selected algal groups to fix atmospheric N2 when inorganic nitrogen is depleted

All four features use **file-existence-based activation**. None are controlled by settings in the main control file (`w2_con.npt` or `w2_con.csv`). Instead, each feature has its own dedicated CSV input file. If the file is present in the model run directory, the feature is active. If absent, the feature is off.

| Feature | Input File | Optional? |
|---------|-----------|-----------|
| Minimum algae + Low DO mortality | `low_do_mort_input.csv` | Yes |
| Nitrogen fixation | `nfix_option_input.csv` | Yes |
| Algal harvesting | `harvest_option_input.csv` + time-series file | Yes |

Example input files are provided in `docs/examples/hab/`.

---

## 1. Minimum Algae (Seed Population)

### Purpose

Prevents algal concentrations from dropping below a minimum "seed" value. This ensures a residual population exists for regrowth after die-off events such as hypoxic mortality or harvesting.

### Activation

This feature is controlled by the `ALG_MIN` parameter in `low_do_mort_input.csv`. If the file does not exist, `ALG_MIN` defaults to `0.0` and the feature has no effect.

### How It Works

After all transport, kinetics, and harvesting calculations are applied for a time step, the model checks every cell for every algal group:

```
IF C1(K,I,algae) < ALG_MIN THEN C1(K,I,algae) = ALG_MIN
```

This floor is applied uniformly to all algal groups and all cells.

### Parameters

| Parameter | Units | Description |
|-----------|-------|-------------|
| `ALG_MIN` | mg/L (or g/m3) | Minimum algal concentration. Set to `0.0` to disable. |

### Input File Format

See `low_do_mort_input.csv` below (Section 2), which contains both `ALG_MIN` and the low DO mortality parameters.

### Source Code References

- Read: `input.F90` ~line 2317
- Applied: `update.F90` ~line 120

---

## 2. Low DO Mortality (Hypoxic Conditions)

### Purpose

Simulates enhanced algal die-off under prolonged low dissolved oxygen (hypoxic) conditions. When DO drops below a threshold and stays low for longer than a critical duration, algal mortality rates are elevated.

### Activation

Place `low_do_mort_input.csv` in the model run directory. The feature activates when `ALG_O2LIM > 0.0`.

### How It Works

The model tracks hypoxia in two steps:

**Step 1 -- Track low DO duration (every time step, every cell):**

At each cell (K,I), the model checks whether current DO is below the threshold `ALG_O2LIM`. If yes, a cumulative low-DO timer (`DELT_LOW_DO`) accumulates. If DO recovers above the threshold, the timer resets to zero.

```
IF DO(K,I) < ALG_O2LIM THEN
    DELT_LOW_DO(K,I) = DELT_LOW_DO(K,I) + DLT    (accumulate)
ELSE
    DELT_LOW_DO(K,I) = 0.0                         (reset)
END IF
```

**Step 2 -- Override mortality rate (per algal group):**

For each algal group JA, if the cumulative low-DO duration exceeds the group-specific critical time `CRIT_T(JA)`, the normal mortality rate is replaced by the elevated rate `AM_LOW_DO(JA)`:

```
IF DELT_LOW_DO(K,I) > CRIT_T(JA) THEN
    mortality(K,I,JA) = AM_LOW_DO(JA)
END IF
```

### Parameters

| Parameter | Units | Per-group? | Description |
|-----------|-------|------------|-------------|
| `ALG_O2LIM` | mg/L | No (scalar) | DO concentration threshold. Cells with DO below this are considered hypoxic. |
| `ALG_MIN` | mg/L | No (scalar) | Minimum algae seed concentration (see Section 1). |
| `CRIT_T(JA)` | days | Yes (one per algal group) | How long DO must remain below `ALG_O2LIM` before elevated mortality activates. |
| `AM_LOW_DO(JA)` | 1/day | Yes (one per algal group) | Elevated mortality rate applied when the critical duration is exceeded. |

### Input File: `low_do_mort_input.csv`

```
Low DO - High Mortality and Minimum Algae Option Input File
ALG_O2LIM (mg/L) - DO threshold,  ALG_MIN (mg/L) - minimum algae seed concentration
2.0, 0.01
CRIT_T - Critical low-DO duration per algal group (days). One value per algal group (NAL).
5.0, 3.0, 7.0
AM_LOW_DO - Elevated mortality rate per algal group (1/day). One value per algal group (NAL).
0.5, 0.8, 0.3
```

**Line-by-line format:**

| Line | Content |
|------|---------|
| 1 | Header (skipped) |
| 2 | Description (skipped) |
| 3 | `ALG_O2LIM, ALG_MIN` -- two comma-separated values |
| 4 | Description (skipped) |
| 5 | `CRIT_T(1), CRIT_T(2), ... CRIT_T(NAL)` -- one value per algal group, in **days** |
| 6 | Description (skipped) |
| 7 | `AM_LOW_DO(1), AM_LOW_DO(2), ... AM_LOW_DO(NAL)` -- one value per algal group, in **1/day** |

The number of values on lines 5 and 7 must equal `NAL` (the number of algal groups defined in the main control file).

**Unit conversions (automatic):** `CRIT_T` is converted from days to seconds internally. `AM_LOW_DO` is converted from 1/day to 1/second internally.

### Source Code References

- Read: `input.F90` ~lines 2307-2325
- DO tracking: `water-quality.f90` ~lines 302-307
- Mortality override: `water-quality.f90` ~line 704

---

## 3. Algal Harvesting

### Purpose

Simulates physical removal of algae from specified segments at scheduled times. This can represent mechanical harvesting, skimming operations, or other management actions. Features include depth-limited harvesting and mass tracking.

### Activation

Place `harvest_option_input.csv` in the model run directory. The feature activates when `NHF > 0` (at least one harvest segment is defined). A second file containing the time-series of harvest events (named inside the option file) must also be present.

### How It Works

1. At each time step, the model checks whether the current Julian day (`JDAY`) has reached the next scheduled harvest event from the time-series file.
2. When a harvest event occurs, for each harvested segment and each active algal group, the model removes a fraction `FHA` of the algal concentration from each cell in the water column.
3. If a maximum harvest depth (`HADEP`) is specified for a segment, only cells with their center above that depth (measured from the water surface) are harvested.
4. The harvested mass is tracked per-event and cumulatively, and written to `harvest_mass_output.csv`.
5. After harvesting, the minimum algae floor (`ALG_MIN`) is applied, so algae cannot be harvested below the seed concentration.

**Harvesting is instantaneous** -- the fractional removal is applied once at the event JDAY, then `FHA` is reset to zero.

### Parameters

| Parameter | Source | Description |
|-----------|--------|-------------|
| `HAFFN` | `harvest_option_input.csv` | Filename of the time-series file |
| `NHF` | `harvest_option_input.csv` | Number of segments with harvesting |
| `IHA(1:NHF)` | `harvest_option_input.csv` | Segment indices where harvesting occurs |
| `HADEP(1:NHF)` | `harvest_option_input.csv` | Maximum harvest depth (m) per segment. `0` = all layers. Optional. |
| `FHA(1:NHF)` | Time-series file | Fraction of algae removed per segment (0.0 to 1.0) at each event |

### Input File: `harvest_option_input.csv`

```
Algal Harvesting Option Input File
Filename for time-varying harvesting data
harvest_timeseries.csv
Number of segments with harvesting (NHF)
2
Segment numbers where harvesting occurs (IHA). One value per harvested segment (NHF).
15, 22
Maximum harvest depth per segment in meters. 0 = harvest all layers. One value per harvested segment (NHF). This line and the next are optional.
3.0, 0.0
```

**Line-by-line format:**

| Line | Content |
|------|---------|
| 1 | Header (skipped) |
| 2 | Description (skipped) |
| 3 | `HAFFN` -- filename for time-series data (character string) |
| 4 | Description (skipped) |
| 5 | `NHF` -- integer, number of harvested segments |
| 6 | Description (skipped) |
| 7 | `IHA(1), IHA(2), ... IHA(NHF)` -- segment indices |
| 8 | Description (skipped) -- **optional line** |
| 9 | `HADEP(1), HADEP(2), ... HADEP(NHF)` -- max depth in meters -- **optional line** |

Lines 8-9 are optional. If missing or unreadable, `HADEP` defaults to `0.0` for all segments (harvest the full water column).

### Time-Series File (e.g., `harvest_timeseries.csv`)

```
Algal Harvesting Time Series Data
JDAY      FHA(1)    FHA(2)
150.0     0.50      0.30
165.0     0.00      0.80
200.0     0.25      0.00
250.0     0.10      0.10
```

**Line-by-line format:**

| Line | Content |
|------|---------|
| 1 | Header (skipped) |
| 2 | Column labels (skipped) |
| 3+ | `JDAY, FHA(1), FHA(2), ... FHA(NHF)` -- one row per harvest event |

- `JDAY` is the Julian day of the harvest event.
- `FHA` is the fractional removal (0.0 to 1.0). For example, `0.50` removes 50% of algae.
- Set `FHA = 0.0` for a segment to skip harvesting at that segment for that event.
- Rows must be in chronological order.
- The file is read sequentially; when the end of file is reached, no further harvesting occurs.

### Output File: `harvest_mass_output.csv`

The model automatically creates this file in the run directory when harvesting is active. It logs every harvest event with the following columns:

| Column | Description |
|--------|-------------|
| `JDAY` | Julian day of the event |
| `Segment` | Segment number |
| `Fraction` | Fraction removed (`FHA`) |
| `Event_Mass_kg` | Mass removed in this event (kg) |
| `Cumulative_Mass_kg` | Running total of mass removed at this segment (kg) |

### Example

In the example files, segment 15 is harvested to a maximum depth of 3.0 m, and segment 22 is harvested through the full water column. On JDAY 150, 50% of algae are removed from segment 15 (above 3 m depth) and 30% from segment 22 (all layers).

### Source Code References

- Static config read: `input.F90` ~lines 2341-2365
- Time-series initial read: `time-varying-data.f90` ~lines 475-494
- Time-series runtime update: `time-varying-data.f90` ~lines 1711-1730
- Branch mapping: `init-geom.F90` ~lines 221-226
- Harvesting applied: `update.F90` ~lines 96-145
- Mass output file opened: `init.F90` ~lines 134-137

---

## 4. Nitrogen Fixation

### Purpose

Simulates the ability of certain algal groups (e.g., cyanobacteria) to fix atmospheric nitrogen (N2) when dissolved inorganic nitrogen becomes scarce. When total inorganic nitrogen (TIN = NH4 + NO3) drops below a critical threshold, the algal group switches to N-fixation: nitrogen limitation is removed and the group stops consuming NH4 and NO3 from the water column.

### Activation

Place `nfix_option_input.csv` in the model run directory. Set `CRIT_TIN(JA) > 0` for any algal group that can fix nitrogen. Groups with `CRIT_TIN = 0.0` do not fix nitrogen.

### How It Works

The feature modifies three calculations in the water quality kinetics:

1. **Nitrogen limitation** -- When `NH4 + NO3 < CRIT_TIN(JA)`, the nitrogen half-saturation constant (`AHSN`) is effectively set to zero, making the nitrogen limitation factor approach 1.0 (no limitation). The algae grow as if nitrogen were abundant.

2. **NH4 uptake** -- When N-fixation is active for a group, that group's ammonium uptake from the water is suppressed. The algae are assumed to obtain nitrogen from the atmosphere instead.

3. **NO3 uptake** -- Similarly, nitrate uptake from the water is suppressed during N-fixation.

When TIN rises back above `CRIT_TIN(JA)`, the group returns to normal nitrogen-limited growth and resumes consuming NH4/NO3 from the water.

### Parameters

| Parameter | Units | Per-group? | Description |
|-----------|-------|------------|-------------|
| `CRIT_TIN(JA)` | mg/L | Yes (one per algal group) | TIN threshold below which N-fixation activates. Set to `0.0` for groups that cannot fix nitrogen. |

### Input File: `nfix_option_input.csv`

```
Nitrogen Fixation Option Input File
CRIT_TIN - Critical TIN (NH4+NO3) concentration per algal group (mg/L). One value per algal group (NAL). Set to 0.0 for groups that do not fix nitrogen.
0.0, 0.0, 0.05
```

**Line-by-line format:**

| Line | Content |
|------|---------|
| 1 | Header (skipped) |
| 2 | Description (skipped) |
| 3 | `CRIT_TIN(1), CRIT_TIN(2), ... CRIT_TIN(NAL)` -- one value per algal group, in **mg/L** |

The number of values must equal `NAL` (the number of algal groups defined in the main control file).

### Example

In the example file with 3 algal groups, only group 3 (e.g., a cyanobacteria) fixes nitrogen, with a threshold of 0.05 mg/L. When ambient NH4+NO3 drops below 0.05 mg/L, group 3 switches to N-fixation. Groups 1 and 2 have `CRIT_TIN = 0.0` and never fix nitrogen.

### Source Code References

- Read: `input.F90` ~lines 2328-2339
- N-limitation override: `water-quality.f90` ~line 694
- NH4 uptake suppression: `water-quality.f90` ~line 1512
- NO3 uptake suppression: `water-quality.f90` ~line 1586

---

## Quick Start Guide

To enable any combination of HAB features, copy the relevant CSV file(s) into your model run directory (the same directory containing `w2_con.npt` or `w2_con.csv`):

| To enable... | Copy these files to the run directory |
|--------------|---------------------------------------|
| Minimum algae only | `low_do_mort_input.csv` (set `ALG_O2LIM = 0.0`, set `ALG_MIN` to desired seed value) |
| Low DO mortality only | `low_do_mort_input.csv` (set `ALG_MIN = 0.0` if no seed needed) |
| Both minimum algae and low DO mortality | `low_do_mort_input.csv` (set both `ALG_O2LIM > 0` and `ALG_MIN > 0`) |
| Nitrogen fixation | `nfix_option_input.csv` |
| Algal harvesting | `harvest_option_input.csv` + the time-series file named inside it |
| All features | All three CSV files + the harvest time-series file |

To disable a feature, simply remove (or rename) its input file from the run directory. No changes to the main control file are needed.

### Important Notes

- The number of values in per-algal-group arrays must match `NAL` as defined in the main control file.
- Algal harvesting and minimum algae interact: harvesting is applied first, then the `ALG_MIN` floor is enforced. Algae will not be harvested below the seed concentration.
- All features are independent and can be used in any combination.
- Example input files are provided in `docs/examples/hab/`.
