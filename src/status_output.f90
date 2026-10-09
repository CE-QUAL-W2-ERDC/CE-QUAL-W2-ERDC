!***********************************************************************************************************************************
!**                              S U B R O U T I N E   W R I T E _ S T A T U S _ F I L E                                     **
!**                                                                                                                           **
!**  Writes simulation status to a JSON file for external monitoring (e.g., Python GUI)                                       **
!**  This replaces the Windows-specific SCREEN_UPDATE for cross-platform status display                                       **
!***********************************************************************************************************************************

SUBROUTINE WRITE_STATUS_FILE
  USE GEOMC, ONLY : ELWS, Z
  USE GLOBAL, ONLY : NWB, NBR, NTR, NWD, NSP, NGT, NPI, NPU, KTWB, ELKT, DLT, MODDIR, CCTIME, CDATE
  USE GDAYC, ONLY : MONTH, GDAY, YEAR, JDAYG
  USE SCREENC, ONLY : JDAY, DLTS1, JDMIN, MINDLT, DLTAV, NIT, NV, ILOC, KLOC, IMIN, KMIN, ZMIN, IZMIN
  USE SURFHE, ONLY : ET, CSHE, WIND
  USE TVDC, ONLY : QIN, TIN, QDTR, TDTR, QTR, TTR, QWD, SRON, CLOUD, TAIR, TDEW, PHI
  USE STRUCTURES, ONLY : QSP, QGT, QPI, QPU
  USE LOGICC, ONLY : TERM_BY_TERM
  USE MAIN, ONLY : TMSTRT, TMEND
  USE PREC, ONLY : R8
  IMPLICIT NONE

  INTEGER :: I, ISTAT
  INTEGER, PARAMETER :: STATUS_UNIT = 9999
  REAL :: PROGRESS_PCT, CPU_CURRENT, RHOWCP_LOCAL
  REAL(R8) :: CURRENT_CPU
  CHARACTER(8) :: TIME_STR
  CHARACTER(256) :: STATUS_FILE
  CHARACTER(32) :: FMT_REAL, FMT_INT

  ! Parameter for heat capacity
  RHOWCP_LOCAL = 4186000.0  ! J/(m3*degC)

  ! Get current CPU time
  CALL CPU_TIME(CURRENT_CPU)
  CPU_CURRENT = REAL(CURRENT_CPU)

  ! Format current time
  TIME_STR = CCTIME(1:2) // ':' // CCTIME(3:4) // ':' // CCTIME(5:6)

  ! Calculate progress percentage
  IF (TMEND > TMSTRT) THEN
    PROGRESS_PCT = ((JDAY - TMSTRT) / (TMEND - TMSTRT)) * 100.0
    IF (PROGRESS_PCT < 0.0) PROGRESS_PCT = 0.0
    IF (PROGRESS_PCT > 100.0) PROGRESS_PCT = 100.0
  ELSE
    PROGRESS_PCT = 0.0
  END IF

  ! Write to status file (in current directory)
  STATUS_FILE = 'w2_status.json'

  OPEN(UNIT = STATUS_UNIT, FILE = TRIM(STATUS_FILE), STATUS = 'REPLACE', ACTION = 'WRITE', IOSTAT = ISTAT)
  IF (ISTAT /= 0) RETURN  ! Silently fail if cannot open

  WRITE(STATUS_UNIT, '(A)') '{'

  ! Time parameters
  WRITE(STATUS_UNIT, '(A)') '  "time_parameters": {'
  WRITE(STATUS_UNIT, '(A,A,A,I0,A,I0,A)') '    "gregorian_date": "', TRIM(MONTH), ' ', GDAY, ', ', YEAR, '",'
  WRITE(STATUS_UNIT, '(A,F12.4,A)') '    "julian_day": ', JDAY, ','
  WRITE(STATUS_UNIT, '(A,F10.2,A)') '    "julian_hours": ', (JDAY - INT(JDAY)) * 24.0, ','
  WRITE(STATUS_UNIT, '(A,F12.4,A)') '    "elapsed_days": ', JDAY - TMSTRT, ','
  WRITE(STATUS_UNIT, '(A,F10.2,A)') '    "elapsed_hours": ', ((JDAY - TMSTRT) - INT(JDAY - TMSTRT)) * 24.0, ','
  WRITE(STATUS_UNIT, '(A,F10.3,A)') '    "timestep_sec": ', DLTS1, ','
  WRITE(STATUS_UNIT, '(A,I0,A,I0,A)') '    "timestep_location": [', KLOC, ', ', ILOC, '],'
  WRITE(STATUS_UNIT, '(A,F10.4,A)') '    "min_timestep_sec": ', MINDLT, ','
  WRITE(STATUS_UNIT, '(A,I0,A,I0,A)') '    "min_timestep_location": [', KMIN, ', ', IMIN, '],'
  WRITE(STATUS_UNIT, '(A,F12.4,A)') '    "min_timestep_day": ', JDMIN, ','
  WRITE(STATUS_UNIT, '(A,F10.3,A)') '    "avg_timestep_sec": ', DLTAV, ','
  WRITE(STATUS_UNIT, '(A,I0,A)') '    "iterations": ', NIT, ','
  WRITE(STATUS_UNIT, '(A,I0,A)') '    "timestep_violations": ', NV, ','
  IF (NIT > 0) THEN
    WRITE(STATUS_UNIT, '(A,F8.4)') '    "violation_percent": ', FLOAT(NV) / FLOAT(NIT) * 100.0
  ELSE
    WRITE(STATUS_UNIT, '(A)') '    "violation_percent": 0.0'
  END IF
  WRITE(STATUS_UNIT, '(A)') '  },'

  ! Meteorological parameters (for first waterbody)
  WRITE(STATUS_UNIT, '(A)') '  "meteorology": {'
  WRITE(STATUS_UNIT, '(A,F8.2,A)') '    "air_temp_c": ', TAIR(1), ','
  WRITE(STATUS_UNIT, '(A,F8.2,A)') '    "dew_point_c": ', TDEW(1), ','
  WRITE(STATUS_UNIT, '(A,F8.2,A)') '    "wind_speed_ms": ', WIND(1), ','
  WRITE(STATUS_UNIT, '(A,F8.2,A)') '    "wind_direction_rad": ', PHI(1), ','
  WRITE(STATUS_UNIT, '(A,F6.2,A)') '    "cloud_cover": ', CLOUD(1), ','
  WRITE(STATUS_UNIT, '(A,F8.2,A)') '    "solar_radiation_wm2": ', SRON(1), ','
  ! Equilibrium temperature and surface heat exchange depend on segment
  ! Use downstream segment of first branch of first waterbody as representative
  WRITE(STATUS_UNIT, '(A,F8.2,A)') '    "equilibrium_temp_c": ', ET(1), ','
  WRITE(STATUS_UNIT, '(A,F10.2)') '    "surface_heat_exchange_wm2c": ', CSHE(1) * RHOWCP_LOCAL
  WRITE(STATUS_UNIT, '(A)') '  },'

  ! Run times
  WRITE(STATUS_UNIT, '(A)') '  "run_times": {'
  WRITE(STATUS_UNIT, '(A,A,A)') '    "current_time": "', TIME_STR, '",'
  WRITE(STATUS_UNIT, '(A,F12.2,A)') '    "cpu_time_min": ', CPU_CURRENT / 60.0, ','
  WRITE(STATUS_UNIT, '(A,F8.3)') '    "progress_percent": ', PROGRESS_PCT
  WRITE(STATUS_UNIT, '(A)') '  },'

  ! Water surface (first waterbody)
  WRITE(STATUS_UNIT, '(A)') '  "water_surface": {'
  WRITE(STATUS_UNIT, '(A,I0,A)') '    "surface_layer": ', KTWB(1), ','
  WRITE(STATUS_UNIT, '(A,F10.3,A)') '    "water_surface_elevation_m": ', ELKT(1), ','
  WRITE(STATUS_UNIT, '(A,F10.4,A)') '    "min_deviation_m": ', ZMIN(1), ','
  WRITE(STATUS_UNIT, '(A,I0)') '    "min_deviation_segment": ', IZMIN(1)
  WRITE(STATUS_UNIT, '(A)') '  },'

  ! Inflows/Outflows - write as arrays
  WRITE(STATUS_UNIT, '(A)') '  "flows": {'

  ! Branch inflows
  WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "branch_inflow_m3s": ['
  DO I = 1, NBR
    IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
    WRITE(STATUS_UNIT, '(F10.3)', ADVANCE = 'NO') QIN(I)
  END DO
  WRITE(STATUS_UNIT, '(A)') '],'

  WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "branch_inflow_temp_c": ['
  DO I = 1, NBR
    IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
    WRITE(STATUS_UNIT, '(F8.2)', ADVANCE = 'NO') TIN(I)
  END DO
  WRITE(STATUS_UNIT, '(A)') '],'

  ! Distributed tributaries
  WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "dist_trib_flow_m3s": ['
  DO I = 1, NBR
    IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
    WRITE(STATUS_UNIT, '(F10.3)', ADVANCE = 'NO') QDTR(I)
  END DO
  WRITE(STATUS_UNIT, '(A)') '],'

  WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "dist_trib_temp_c": ['
  DO I = 1, NBR
    IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
    WRITE(STATUS_UNIT, '(F8.2)', ADVANCE = 'NO') TDTR(I)
  END DO
  WRITE(STATUS_UNIT, '(A)') '],'

  ! Tributaries
  IF (NTR > 0) THEN
    WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "tributary_flow_m3s": ['
    DO I = 1, NTR
      IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
      WRITE(STATUS_UNIT, '(F10.3)', ADVANCE = 'NO') QTR(I)
    END DO
    WRITE(STATUS_UNIT, '(A)') '],'

    WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "tributary_temp_c": ['
    DO I = 1, NTR
      IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
      WRITE(STATUS_UNIT, '(F8.2)', ADVANCE = 'NO') TTR(I)
    END DO
    WRITE(STATUS_UNIT, '(A)') '],'
  ELSE
    WRITE(STATUS_UNIT, '(A)') '    "tributary_flow_m3s": [],'
    WRITE(STATUS_UNIT, '(A)') '    "tributary_temp_c": [],'
  END IF

  ! Spillways
  IF (NSP > 0) THEN
    WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "spillway_flow_m3s": ['
    DO I = 1, NSP
      IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
      WRITE(STATUS_UNIT, '(F10.3)', ADVANCE = 'NO') QSP(I)
    END DO
    WRITE(STATUS_UNIT, '(A)') '],'
  ELSE
    WRITE(STATUS_UNIT, '(A)') '    "spillway_flow_m3s": [],'
  END IF

  ! Gates
  IF (NGT > 0) THEN
    WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "gate_flow_m3s": ['
    DO I = 1, NGT
      IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
      WRITE(STATUS_UNIT, '(F10.3)', ADVANCE = 'NO') QGT(I)
    END DO
    WRITE(STATUS_UNIT, '(A)') '],'
  ELSE
    WRITE(STATUS_UNIT, '(A)') '    "gate_flow_m3s": [],'
  END IF

  ! Pipes
  IF (NPI > 0) THEN
    WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "pipe_flow_m3s": ['
    DO I = 1, NPI
      IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
      WRITE(STATUS_UNIT, '(F10.3)', ADVANCE = 'NO') QPI(I)
    END DO
    WRITE(STATUS_UNIT, '(A)') '],'
  ELSE
    WRITE(STATUS_UNIT, '(A)') '    "pipe_flow_m3s": [],'
  END IF

  ! Pumps
  IF (NPU > 0) THEN
    WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "pump_flow_m3s": ['
    DO I = 1, NPU
      IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
      WRITE(STATUS_UNIT, '(F10.3)', ADVANCE = 'NO') QPU(I)
    END DO
    WRITE(STATUS_UNIT, '(A)') '],'
  ELSE
    WRITE(STATUS_UNIT, '(A)') '    "pump_flow_m3s": [],'
  END IF

  ! Withdrawals
  IF (NWD > 0) THEN
    WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') '    "withdrawal_flow_m3s": ['
    DO I = 1, NWD
      IF (I > 1) WRITE(STATUS_UNIT, '(A)', ADVANCE = 'NO') ', '
      WRITE(STATUS_UNIT, '(F10.3)', ADVANCE = 'NO') QWD(I)
    END DO
    WRITE(STATUS_UNIT, '(A)') ']'
  ELSE
    WRITE(STATUS_UNIT, '(A)') '    "withdrawal_flow_m3s": []'
  END IF

  WRITE(STATUS_UNIT, '(A)') '  },'

  ! Simulation info
  WRITE(STATUS_UNIT, '(A)') '  "simulation": {'
  WRITE(STATUS_UNIT, '(A,F12.4,A)') '    "start_day": ', TMSTRT, ','
  WRITE(STATUS_UNIT, '(A,F12.4,A)') '    "end_day": ', TMEND, ','
  WRITE(STATUS_UNIT, '(A,F12.4,A)') '    "current_day": ', JDAY, ','
  WRITE(STATUS_UNIT, '(A,I0,A)') '    "num_waterbodies": ', NWB, ','
  WRITE(STATUS_UNIT, '(A,I0,A)') '    "num_branches": ', NBR, ','
  WRITE(STATUS_UNIT, '(A,I0,A)') '    "num_tributaries": ', NTR, ','
  WRITE(STATUS_UNIT, '(A,A,A)') '    "model_directory": "', TRIM(MODDIR), '",'
  WRITE(STATUS_UNIT, '(A)') '    "status": "running"'
  WRITE(STATUS_UNIT, '(A)') '  }'

  WRITE(STATUS_UNIT, '(A)') '}'

  CLOSE(STATUS_UNIT)

END SUBROUTINE WRITE_STATUS_FILE


!***********************************************************************************************************************************
!**                         S U B R O U T I N E   W R I T E _ S T A T U S _ F I L E _ T I M E D                                **
!**                                                                                                                           **
!**  Calls WRITE_STATUS_FILE on the first call, whenever FORCE is true, and otherwise only when at least                       **
!**  STATUS_INTERVAL_S seconds of wall-clock time have passed since the last write. The time loop calls this once per         **
!**  time step; writing the file every step (up to about 2,000 open-write-close cycles per second of run time when the        **
!**  time step is small) added file-system load without giving a monitor that polls the file any more information. The       **
!**  file content and layout are those of WRITE_STATUS_FILE; the end-of-run record is still written by                        **
!**  WRITE_STATUS_COMPLETE.                                                                                                   **
!***********************************************************************************************************************************

SUBROUTINE WRITE_STATUS_FILE_TIMED(FORCE)
  IMPLICIT NONE

  LOGICAL, INTENT(IN) :: FORCE
  EXTERNAL WRITE_STATUS_FILE

  ! Minimum wall-clock interval between status-file writes, s
  INTEGER(8), PARAMETER :: STATUS_INTERVAL_S = 1
  INTEGER(8), SAVE :: LAST_COUNT = 0
  LOGICAL, SAVE :: WRITTEN = .FALSE.
  INTEGER(8) :: CLOCK_COUNT, CLOCK_RATE

  ! INTEGER(8) arguments select the high-resolution system clock; CLOCK_RATE is in counts per second
  CALL SYSTEM_CLOCK(CLOCK_COUNT, CLOCK_RATE)
  IF (FORCE .OR. .NOT. WRITTEN .OR. CLOCK_COUNT - LAST_COUNT >= STATUS_INTERVAL_S * CLOCK_RATE) THEN
    CALL WRITE_STATUS_FILE()
    LAST_COUNT = CLOCK_COUNT
    WRITTEN = .TRUE.
  END IF

END SUBROUTINE WRITE_STATUS_FILE_TIMED


!***********************************************************************************************************************************
!**                              S U B R O U T I N E   W R I T E _ S T A T U S _ C O M P L E T E                               **
!***********************************************************************************************************************************

SUBROUTINE WRITE_STATUS_COMPLETE(STATUS_MSG)
  USE GLOBAL, ONLY : CCTIME, CDATE
  USE SCREENC, ONLY : JDAY, NIT, NV
  USE MAIN, ONLY : TMSTRT, TMEND
  USE PREC, ONLY : R8
  IMPLICIT NONE

  CHARACTER(*), INTENT(IN) :: STATUS_MSG
  INTEGER :: ISTAT
  INTEGER, PARAMETER :: STATUS_UNIT = 9999
  REAL(R8) :: CURRENT_CPU, CPU_CURRENT
  REAL :: PROGRESS_PCT
  CHARACTER(8) :: TIME_STR
  CHARACTER(256) :: STATUS_FILE

  CALL CPU_TIME(CURRENT_CPU)
  CPU_CURRENT = REAL(CURRENT_CPU)
  TIME_STR = CCTIME(1:2) // ':' // CCTIME(3:4) // ':' // CCTIME(5:6)

  ! Share of the simulation period reached, percent: 100 when the run reached TMEND, less when it
  ! failed or was stopped (same clamp as WRITE_STATUS_FILE)
  PROGRESS_PCT = 100.0
  IF (TMEND > TMSTRT) PROGRESS_PCT = MIN(MAX((JDAY - TMSTRT) / (TMEND - TMSTRT) * 100.0, 0.0), 100.0)

  STATUS_FILE = 'w2_status.json'

  OPEN(UNIT = STATUS_UNIT, FILE = TRIM(STATUS_FILE), STATUS = 'REPLACE', ACTION = 'WRITE', IOSTAT = ISTAT)
  IF (ISTAT /= 0) RETURN

  WRITE(STATUS_UNIT, '(A)') '{'
  WRITE(STATUS_UNIT, '(A)') '  "simulation": {'
  WRITE(STATUS_UNIT, '(A,A,A)') '    "status": "', TRIM(STATUS_MSG), '",'
  WRITE(STATUS_UNIT, '(A,A,A)') '    "end_time": "', TIME_STR, '",'
  WRITE(STATUS_UNIT, '(A,F12.2,A)') '    "total_cpu_time_min": ', CPU_CURRENT / 60.0, ','
  WRITE(STATUS_UNIT, '(A,I0,A)') '    "total_iterations": ', NIT, ','
  WRITE(STATUS_UNIT, '(A,I0,A)') '    "total_violations": ', NV, ','
  WRITE(STATUS_UNIT, '(A,F12.4,A)') '    "final_day": ', JDAY, ','
  WRITE(STATUS_UNIT, '(A,F5.1)') '    "progress_percent": ', PROGRESS_PCT     ! F5.1 keeps the leading zero JSON needs
  WRITE(STATUS_UNIT, '(A)') '  }'
  WRITE(STATUS_UNIT, '(A)') '}'

  CLOSE(STATUS_UNIT)

END SUBROUTINE WRITE_STATUS_COMPLETE
