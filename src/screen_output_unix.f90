!***********************************************************************************************************************************
!**                                    S C R E E N   O U T P U T   -   U N I X / M a c O S                                        **
!***********************************************************************************************************************************
!**                                                                                                                                   **
!**  Console-based screen output for Unix/MacOS systems                                                                              **
!**  Replaces Windows dialog box updates with console text output                                                                    **
!**                                                                                                                                   **
!**  Modified: November 2025 for gfortran compilation                                                                                **
!***********************************************************************************************************************************

SUBROUTINE SCREEN_UPDATE_UNIX()
  USE GEOMC; USE GLOBAL; USE GDAYC; USE SCREENC; USE SURFHE; USE TVDC; USE LOGICC; USE NAMESC
  USE STRUCTURES; USE MAIN, ONLY:TMSTRT, TMEND; USE MetFileRegion
  IMPLICIT NONE

  CHARACTER(8)    :: TIME
  INTEGER         :: IPROG
  REAL            :: PERCENT_COMPLETE

  ! Get current time
  CALL DATE_AND_TIME (CDATE,CCTIME)
  CALL CPU_TIME (CURRENT)
  TIME = CCTIME(1:2)//':'//CCTIME(3:4)//':'//CCTIME(5:6)

  ! Calculate progress
  PERCENT_COMPLETE = ((JDAY-TMSTRT)/(TMEND-TMSTRT))*100.0
  IPROG = INT(PERCENT_COMPLETE)

  ! Print compact progress update (overwrites previous line)
  WRITE(*,'(A)',ADVANCE='NO') CHAR(13)  ! Carriage return to overwrite line
  WRITE(*,'(A,I0,A,I0,A,F6.2,A,I3,A,I6,A,I6,A,F8.0,A,F6.1,A)',ADVANCE='NO') &
    'JDay:', INT(JDAY), &
    ' Hr:', INT((JDAY-INT(JDAY))*24.0), &
    ' Elap:', ELTMJD, &
    ' % ', IPROG, &
    ' NIT:', NIT, &
    ' NV:', NV, &
    ' DLT:', DLTS1, &
    ' CPU:', CURRENT/60.0, &
    ' min  '

  ! Flush output buffer to ensure immediate display
  CALL FLUSH(6)

END SUBROUTINE SCREEN_UPDATE_UNIX

!***********************************************************************************************************************************

SUBROUTINE SCREEN_DETAIL_UNIX()
  ! Detailed screen output (called less frequently)
  USE GEOMC; USE GLOBAL; USE GDAYC; USE SCREENC; USE SURFHE; USE TVDC; USE LOGICC; USE NAMESC
  USE STRUCTURES; USE MAIN, ONLY:TMSTRT, TMEND; USE MetFileRegion
  IMPLICIT NONE

  CHARACTER(8)    :: TIME
  INTEGER         :: IPROG
  REAL            :: PERCENT_COMPLETE

  CALL DATE_AND_TIME (CDATE,CCTIME)
  CALL CPU_TIME (CURRENT)
  TIME = CCTIME(1:2)//':'//CCTIME(3:4)//':'//CCTIME(5:6)
  PERCENT_COMPLETE = ((JDAY-TMSTRT)/(TMEND-TMSTRT))*100.0
  IPROG = INT(PERCENT_COMPLETE)

  ! Print detailed progress information
  WRITE(*,'(/A)') '--------------------------------------------------------'
  WRITE(*,'(A,A)')         '  Date/Time:           ', MONTH//' '//TRIM(ADJUSTL(INTTOCHAR(GDAY)))//','//TRIM(ADJUSTL(INTTOCHAR(YEAR)))//' '//TIME
  WRITE(*,'(A,I0,A,F6.2)') '  Julian Day/Hour:     ', INT(JDAY), ' / ', (JDAY-INT(JDAY))*24.0
  WRITE(*,'(A,I0,A,F6.2)') '  Elapsed Day/Hour:    ', INT(ELTMJD), ' / ', (ELTMJD-INT(ELTMJD))*24.0
  WRITE(*,'(A,F6.1,A)')    '  Progress:            ', PERCENT_COMPLETE, '%'
  WRITE(*,'(A,I0)')        '  Iterations:          ', NIT
  WRITE(*,'(A,I0)')        '  Timestep Violations: ', NV
  IF (NIT > 0) THEN
    WRITE(*,'(A,F6.2,A)')  '  Violation %:         ', FLOAT(NV)/FLOAT(NIT)*100.0, '%'
  END IF
  WRITE(*,'(A,F8.0,A,I0,A,I0,A)') '  Current Timestep:    ', DLTS1, ' sec  (', KLOC, ',', ILOC, ')'
  WRITE(*,'(A,F8.0,A,I0,A,I0,A)') '  Min Timestep:        ', MINDLT, ' sec  (', KMIN, ',', IMIN, ')'
  WRITE(*,'(A,F8.0)')      '  Avg Timestep:        ', DLTAV
  WRITE(*,'(A,F8.2,A)')    '  CPU Time:            ', CURRENT/60.0, ' minutes'

  ! Meteorological data
  IF (.NOT. Met_Regions) THEN
    WRITE(*,'(A,F8.2)')    '  Air Temperature:     ', TAIR(JW)
    WRITE(*,'(A,F8.2)')    '  Dew Point:           ', TDEW(JW)
    WRITE(*,'(A,F8.2)')    '  Wind Speed:          ', WIND(JW)
    WRITE(*,'(A,F8.1)')    '  Solar Radiation:     ', SRON(JW)
  ELSE
    WRITE(*,'(A,F8.2)')    '  Air Temperature:     ', TAIR(1)
    WRITE(*,'(A,F8.2)')    '  Dew Point:           ', TDEW(1)
    WRITE(*,'(A,F8.2)')    '  Wind Speed:          ', WIND(1)
    WRITE(*,'(A,F8.1)')    '  Solar Radiation:     ', SRON(1)
  END IF

  ! Surface layer info
  WRITE(*,'(A,I0)')        '  Surface Layer:       ', KTWB(JW)
  WRITE(*,'(A,F8.2)')      '  Surface Elevation:   ', ELKT(JW)
  WRITE(*,'(A)') '--------------------------------------------------------'

CONTAINS

  ! Helper function to convert integer to string
  FUNCTION INTTOCHAR(I) RESULT(STR)
    INTEGER, INTENT(IN) :: I
    CHARACTER(LEN=12) :: STR
    WRITE(STR,'(I0)') I
  END FUNCTION INTTOCHAR

END SUBROUTINE SCREEN_DETAIL_UNIX
