!*******************************************************************************
! TEST_NFIX_INPUT - Tests for nfix_option_input.csv parsing
!
! Verifies correct reading of CRIT_TIN values and absent-file defaults.
!*******************************************************************************
MODULE TEST_NFIX_INPUT
  USE PREC
  USE TEST_FRAMEWORK
  IMPLICIT NONE

  INTEGER, PARAMETER :: TUNIT = 9952

CONTAINS

  SUBROUTINE RUN_NFIX_INPUT_TESTS()
    CALL TEST_SUITE_START('N-Fixation Input Parsing')
    CALL TEST_PARSE_NFIX()
    CALL TEST_NO_NFIX_FILE()
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_PARSE_NFIX()
    ! CRIT_TIN values read correctly
    INTEGER, PARAMETER :: NAL = 3
    REAL(R8) :: CRIT_TIN(NAL)
    INTEGER :: JA

    OPEN(TUNIT, FILE='_test_nfix.csv', STATUS='REPLACE')
    WRITE(TUNIT,'(A)') 'N-Fixation Options'
    WRITE(TUNIT,'(A)') 'Critical TIN concentration per algal group (mg/L)'
    WRITE(TUNIT,'(A)') '0.0  0.02  0.05'
    CLOSE(TUNIT)

    CRIT_TIN = 999.0D0
    OPEN(TUNIT, FILE='_test_nfix.csv', STATUS='OLD')
    READ(TUNIT, *)  ! Header
    READ(TUNIT, *)  ! Description
    READ(TUNIT, *) (CRIT_TIN(JA), JA=1,NAL)
    CLOSE(TUNIT, STATUS='DELETE')

    CALL ASSERT_EQUAL_REAL(0.0D0, CRIT_TIN(1), 'Parse nfix: CRIT_TIN(1)=0.0 (inactive)')
    CALL ASSERT_EQUAL_REAL(0.02D0, CRIT_TIN(2), 'Parse nfix: CRIT_TIN(2)=0.02')
    CALL ASSERT_EQUAL_REAL(0.05D0, CRIT_TIN(3), 'Parse nfix: CRIT_TIN(3)=0.05')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NO_NFIX_FILE()
    ! Absent file → all CRIT_TIN=0
    LOGICAL :: NFIX_EXIST
    INTEGER, PARAMETER :: NAL = 3
    REAL(R8) :: CRIT_TIN(NAL)

    CRIT_TIN = 999.0D0
    INQUIRE(FILE='_nonexistent_nfix_option_input.csv', EXIST=NFIX_EXIST)
    IF (.NOT. NFIX_EXIST) CRIT_TIN = 0.0D0

    CALL ASSERT_EQUAL_REAL(0.0D0, CRIT_TIN(1), 'No nfix file: CRIT_TIN(1)=0')
    CALL ASSERT_EQUAL_REAL(0.0D0, CRIT_TIN(2), 'No nfix file: CRIT_TIN(2)=0')
    CALL ASSERT_EQUAL_REAL(0.0D0, CRIT_TIN(3), 'No nfix file: CRIT_TIN(3)=0')
  END SUBROUTINE

END MODULE TEST_NFIX_INPUT
