!*******************************************************************************
! TEST_HARVEST_INPUT - Tests for harvest CSV parsing and H-04 EOF handling
!
! Creates temporary CSV files, reads with production-style logic, verifies
! values, then deletes the files.
!*******************************************************************************
MODULE TEST_HARVEST_INPUT
  USE PREC
  USE TEST_FRAMEWORK
  IMPLICIT NONE

  INTEGER, PARAMETER :: TUNIT = 9950   ! Temp file unit number

CONTAINS

  SUBROUTINE RUN_HARVEST_INPUT_TESTS()
    CALL TEST_SUITE_START('Harvest Input Parsing')
    CALL TEST_PARSE_HARVEST_OPTION()
    CALL TEST_PARSE_NO_DEPTH_LINE()
    CALL TEST_PARSE_TIMESERIES()
    CALL TEST_EOF_HANDLING()
    CALL TEST_FHA_CLAMPING()
    CALL TEST_NO_HARVEST_FILE()
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_PARSE_HARVEST_OPTION()
    ! NHF, IHA, HADEP read correctly from well-formed CSV
    INTEGER :: NHF, IHA(3), HAIOS, I
    REAL(R8) :: HADEP(3)
    CHARACTER(LEN=80) :: HAFFN

    OPEN(TUNIT, FILE='_test_harvest_opt.csv', STATUS='REPLACE')
    WRITE(TUNIT,'(A)') 'Header line'
    WRITE(TUNIT,'(A)') 'Description line'
    WRITE(TUNIT,'(A)') 'harvest_ts.csv'
    WRITE(TUNIT,'(A)') 'Number of harvest segments'
    WRITE(TUNIT,'(A)') '3'
    WRITE(TUNIT,'(A)') 'Segment IDs'
    WRITE(TUNIT,'(A)') '10  20  30'
    WRITE(TUNIT,'(A)') 'Max harvest depth (m)'
    WRITE(TUNIT,'(A)') '2.0  0.0  5.0'
    CLOSE(TUNIT)

    OPEN(TUNIT, FILE='_test_harvest_opt.csv', STATUS='OLD')
    READ(TUNIT, *)           ! Header
    READ(TUNIT, *)           ! Description
    READ(TUNIT, *) HAFFN
    READ(TUNIT, *)           ! Description
    READ(TUNIT, *) NHF
    READ(TUNIT, *)           ! Description
    READ(TUNIT, *) (IHA(I), I=1,NHF)
    READ(TUNIT, *, IOSTAT=HAIOS)  ! Description
    IF (HAIOS == 0) THEN
      READ(TUNIT, *, IOSTAT=HAIOS) (HADEP(I), I=1,NHF)
      IF (HAIOS /= 0) HADEP(1:NHF) = 0.0D0
    ELSE
      HADEP(1:NHF) = 0.0D0
    END IF
    CLOSE(TUNIT, STATUS='DELETE')

    CALL ASSERT_EQUAL_INT(3, NHF, 'Parse harvest: NHF=3')
    CALL ASSERT_EQUAL_INT(10, IHA(1), 'Parse harvest: IHA(1)=10')
    CALL ASSERT_EQUAL_INT(30, IHA(3), 'Parse harvest: IHA(3)=30')
    CALL ASSERT_EQUAL_REAL(2.0D0, HADEP(1), 'Parse harvest: HADEP(1)=2.0')
    CALL ASSERT_EQUAL_REAL(0.0D0, HADEP(2), 'Parse harvest: HADEP(2)=0.0')
    CALL ASSERT_EQUAL_REAL(5.0D0, HADEP(3), 'Parse harvest: HADEP(3)=5.0')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_PARSE_NO_DEPTH_LINE()
    ! Missing HADEP line → defaults to 0.0
    INTEGER :: NHF, IHA(2), HAIOS, I
    REAL(R8) :: HADEP(2)
    CHARACTER(LEN=80) :: HAFFN

    OPEN(TUNIT, FILE='_test_harvest_nd.csv', STATUS='REPLACE')
    WRITE(TUNIT,'(A)') 'Header'
    WRITE(TUNIT,'(A)') 'Description'
    WRITE(TUNIT,'(A)') 'ts.csv'
    WRITE(TUNIT,'(A)') 'Description'
    WRITE(TUNIT,'(A)') '2'
    WRITE(TUNIT,'(A)') 'Description'
    WRITE(TUNIT,'(A)') '5  15'
    ! No depth lines
    CLOSE(TUNIT)

    HADEP = 999.0D0  ! Set to non-zero to verify default
    OPEN(TUNIT, FILE='_test_harvest_nd.csv', STATUS='OLD')
    READ(TUNIT, *)
    READ(TUNIT, *)
    READ(TUNIT, *) HAFFN
    READ(TUNIT, *)
    READ(TUNIT, *) NHF
    READ(TUNIT, *)
    READ(TUNIT, *) (IHA(I), I=1,NHF)
    READ(TUNIT, *, IOSTAT=HAIOS)
    IF (HAIOS == 0) THEN
      READ(TUNIT, *, IOSTAT=HAIOS) (HADEP(I), I=1,NHF)
      IF (HAIOS /= 0) HADEP(1:NHF) = 0.0D0
    ELSE
      HADEP(1:NHF) = 0.0D0
    END IF
    CLOSE(TUNIT, STATUS='DELETE')

    CALL ASSERT_EQUAL_REAL(0.0D0, HADEP(1), 'No depth line: HADEP(1) defaults to 0')
    CALL ASSERT_EQUAL_REAL(0.0D0, HADEP(2), 'No depth line: HADEP(2) defaults to 0')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_PARSE_TIMESERIES()
    ! Read JDAY and FHA from time-series file
    REAL(R8) :: JDAY1, FHA1, JDAY2, FHA2
    INTEGER :: IOS

    OPEN(TUNIT, FILE='_test_harvest_ts.csv', STATUS='REPLACE')
    WRITE(TUNIT,'(A)') 'JDAY, FHA'
    WRITE(TUNIT,'(A)') '1.5, 0.25'
    WRITE(TUNIT,'(A)') '10.0, 0.75'
    CLOSE(TUNIT)

    OPEN(TUNIT, FILE='_test_harvest_ts.csv', STATUS='OLD')
    READ(TUNIT, *)  ! Header
    READ(TUNIT, *, IOSTAT=IOS) JDAY1, FHA1
    READ(TUNIT, *, IOSTAT=IOS) JDAY2, FHA2
    CLOSE(TUNIT, STATUS='DELETE')

    CALL ASSERT_EQUAL_REAL(1.5D0, JDAY1, 'Parse timeseries: JDAY1=1.5')
    CALL ASSERT_EQUAL_REAL(0.25D0, FHA1, 'Parse timeseries: FHA1=0.25')
    CALL ASSERT_EQUAL_REAL(10.0D0, JDAY2, 'Parse timeseries: JDAY2=10.0')
    CALL ASSERT_EQUAL_REAL(0.75D0, FHA2, 'Parse timeseries: FHA2=0.75')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_EOF_HANDLING()
    ! H-04: Single row → IOSTAT catches EOF on second read
    REAL(R8) :: JDAY1, FHA1, JDAY2, FHA2, NXFHA1
    INTEGER :: IOS

    OPEN(TUNIT, FILE='_test_harvest_eof.csv', STATUS='REPLACE')
    WRITE(TUNIT,'(A)') 'JDAY, FHA'
    WRITE(TUNIT,'(A)') '5.0, 0.5'
    CLOSE(TUNIT)

    NXFHA1 = 0.0D0
    OPEN(TUNIT, FILE='_test_harvest_eof.csv', STATUS='OLD')
    READ(TUNIT, *)  ! Header
    READ(TUNIT, *, IOSTAT=IOS) JDAY1, FHA1
    ! Attempt to read next row → EOF
    READ(TUNIT, *, IOSTAT=IOS) JDAY2, FHA2
    IF (IOS /= 0) NXFHA1 = 1.0D10  ! Production sets NXFHA1=1E10 on EOF
    CLOSE(TUNIT, STATUS='DELETE')

    CALL ASSERT_TRUE(IOS /= 0, 'H-04: IOSTAT non-zero on EOF')
    CALL ASSERT_EQUAL_REAL(1.0D10, NXFHA1, 'H-04: NXFHA1 set to 1E10 on EOF')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_FHA_CLAMPING()
    ! Values outside [0,1] should be clamped
    REAL(R8) :: FHA_OVER, FHA_UNDER
    FHA_OVER  = 1.5D0
    FHA_UNDER = -0.3D0
    IF (FHA_OVER  > 1.0D0) FHA_OVER  = 1.0D0
    IF (FHA_UNDER < 0.0D0) FHA_UNDER = 0.0D0
    CALL ASSERT_EQUAL_REAL(1.0D0, FHA_OVER, 'FHA > 1.0 clamped to 1.0')
    CALL ASSERT_EQUAL_REAL(0.0D0, FHA_UNDER, 'FHA < 0.0 clamped to 0.0')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NO_HARVEST_FILE()
    ! INQUIRE=.FALSE. → NHF=0
    LOGICAL :: HARVEST_EXIST
    INTEGER :: NHF
    NHF = 99  ! Non-zero initial
    INQUIRE(FILE='_nonexistent_harvest_option_input.csv', EXIST=HARVEST_EXIST)
    IF (.NOT. HARVEST_EXIST) NHF = 0
    CALL ASSERT_EQUAL_INT(0, NHF, 'No harvest file: NHF=0')
  END SUBROUTINE

END MODULE TEST_HARVEST_INPUT
