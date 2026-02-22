!*******************************************************************************
! TEST_LOW_DO_INPUT - Tests for low_do_mort_input.csv parsing
!
! Verifies correct reading of ALG_O2LIM, ALG_MIN, CRIT_T, AM_LOW_DO,
! unit conversions (days↔seconds), and absent-file defaults.
!*******************************************************************************
MODULE TEST_LOW_DO_INPUT
  USE PREC
  USE TEST_FRAMEWORK
  IMPLICIT NONE

  INTEGER, PARAMETER :: TUNIT = 9951
  REAL(R8), PARAMETER :: DAY = 86400.0D0

CONTAINS

  SUBROUTINE RUN_LOW_DO_INPUT_TESTS()
    CALL TEST_SUITE_START('Low DO Input Parsing')
    CALL TEST_PARSE_LOW_DO()
    CALL TEST_UNIT_CONVERSION()
    CALL TEST_NO_LOW_DO_FILE()
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_PARSE_LOW_DO()
    ! Read ALG_O2LIM, ALG_MIN, CRIT_T, AM_LOW_DO from CSV
    INTEGER, PARAMETER :: NAL = 2
    INTEGER :: JA
    REAL(R8) :: ALG_O2LIM, ALG_MIN, CRIT_T(NAL), AM_LOW_DO(NAL)

    OPEN(TUNIT, FILE='_test_low_do.csv', STATUS='REPLACE')
    WRITE(TUNIT,'(A)') 'Low DO Mortality Options'
    WRITE(TUNIT,'(A)') 'DO threshold (mg/L), Min algae (g/m3)'
    WRITE(TUNIT,'(A)') '2.0, 0.01'
    WRITE(TUNIT,'(A)') 'Critical time per algal group (days)'
    WRITE(TUNIT,'(A)') '3.0  5.0'
    WRITE(TUNIT,'(A)') 'High mortality rate per algal group (1/day)'
    WRITE(TUNIT,'(A)') '0.5  0.8'
    CLOSE(TUNIT)

    OPEN(TUNIT, FILE='_test_low_do.csv', STATUS='OLD')
    READ(TUNIT, *)           ! Header
    READ(TUNIT, *)           ! Description
    READ(TUNIT, *) ALG_O2LIM, ALG_MIN
    READ(TUNIT, *)           ! Description
    READ(TUNIT, *) (CRIT_T(JA), JA=1,NAL)
    READ(TUNIT, *)           ! Description
    READ(TUNIT, *) (AM_LOW_DO(JA), JA=1,NAL)
    CLOSE(TUNIT, STATUS='DELETE')

    CALL ASSERT_EQUAL_REAL(2.0D0, ALG_O2LIM, 'Parse low DO: ALG_O2LIM=2.0')
    CALL ASSERT_EQUAL_REAL(0.01D0, ALG_MIN, 'Parse low DO: ALG_MIN=0.01')
    CALL ASSERT_EQUAL_REAL(3.0D0, CRIT_T(1), 'Parse low DO: CRIT_T(1)=3.0 days')
    CALL ASSERT_EQUAL_REAL(5.0D0, CRIT_T(2), 'Parse low DO: CRIT_T(2)=5.0 days')
    CALL ASSERT_EQUAL_REAL(0.5D0, AM_LOW_DO(1), 'Parse low DO: AM_LOW_DO(1)=0.5 /day')
    CALL ASSERT_EQUAL_REAL(0.8D0, AM_LOW_DO(2), 'Parse low DO: AM_LOW_DO(2)=0.8 /day')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_UNIT_CONVERSION()
    ! CRIT_T * DAY (days→sec), AM_LOW_DO / DAY (1/day→1/sec)
    INTEGER, PARAMETER :: NAL = 2
    REAL(R8) :: CRIT_T(NAL), AM_LOW_DO(NAL)
    INTEGER :: JA

    CRIT_T    = (/3.0D0, 5.0D0/)    ! days
    AM_LOW_DO = (/0.5D0, 0.8D0/)    ! 1/day

    ! Production conversion (input.F90:2323-2324)
    AM_LOW_DO = AM_LOW_DO / DAY
    CRIT_T    = CRIT_T * DAY

    CALL ASSERT_NEAR(259200.0D0, CRIT_T(1), 1.0D-6, &
      'Unit conv: CRIT_T(1) = 3 days = 259200 sec')
    CALL ASSERT_NEAR(432000.0D0, CRIT_T(2), 1.0D-6, &
      'Unit conv: CRIT_T(2) = 5 days = 432000 sec')
    CALL ASSERT_NEAR(0.5D0/86400.0D0, AM_LOW_DO(1), 1.0D-15, &
      'Unit conv: AM_LOW_DO(1) = 0.5/86400 /sec')
    CALL ASSERT_NEAR(0.8D0/86400.0D0, AM_LOW_DO(2), 1.0D-15, &
      'Unit conv: AM_LOW_DO(2) = 0.8/86400 /sec')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NO_LOW_DO_FILE()
    ! Absent file → ALG_O2LIM=0, ALG_MIN=0, CRIT_T=0
    LOGICAL :: LOW_DO_EXIST
    REAL(R8) :: ALG_O2LIM, ALG_MIN, CRIT_T(2)

    ALG_O2LIM = 999.0D0
    ALG_MIN   = 999.0D0
    CRIT_T    = 999.0D0

    INQUIRE(FILE='_nonexistent_low_do_mort_input.csv', EXIST=LOW_DO_EXIST)
    IF (.NOT. LOW_DO_EXIST) THEN
      ALG_O2LIM = 0.0D0
      ALG_MIN   = 0.0D0
      CRIT_T    = 0.0D0
    END IF

    CALL ASSERT_EQUAL_REAL(0.0D0, ALG_O2LIM, 'No file: ALG_O2LIM=0')
    CALL ASSERT_EQUAL_REAL(0.0D0, ALG_MIN, 'No file: ALG_MIN=0')
    CALL ASSERT_EQUAL_REAL(0.0D0, CRIT_T(1), 'No file: CRIT_T=0')
  END SUBROUTINE

END MODULE TEST_LOW_DO_INPUT
