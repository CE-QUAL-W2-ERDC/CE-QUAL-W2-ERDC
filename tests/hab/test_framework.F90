!*******************************************************************************
! TEST_FRAMEWORK - Lightweight unit testing framework for CE-QUAL-W2
!
! Provides assert functions, pass/fail tracking, and summary reporting.
!*******************************************************************************
MODULE TEST_FRAMEWORK
  USE PREC
  IMPLICIT NONE

  INTEGER :: TESTS_RUN    = 0
  INTEGER :: TESTS_PASSED = 0
  INTEGER :: TESTS_FAILED = 0

  REAL(R8), PARAMETER :: DEFAULT_TOL = 1.0D-10

CONTAINS

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_SUITE_START(NAME)
    CHARACTER(*), INTENT(IN) :: NAME
    WRITE(*,'(A)') ''
    WRITE(*,'(A,A)') '=== Test Suite: ', TRIM(NAME)
    WRITE(*,'(A)') REPEAT('-', 60)
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE ASSERT_TRUE(CONDITION, MSG)
    LOGICAL, INTENT(IN) :: CONDITION
    CHARACTER(*), INTENT(IN) :: MSG
    TESTS_RUN = TESTS_RUN + 1
    IF (CONDITION) THEN
      TESTS_PASSED = TESTS_PASSED + 1
      WRITE(*,'(A,A)') 'PASS: ', TRIM(MSG)
    ELSE
      TESTS_FAILED = TESTS_FAILED + 1
      WRITE(*,'(A,A)') 'FAIL: ', TRIM(MSG)
    END IF
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE ASSERT_FALSE(CONDITION, MSG)
    LOGICAL, INTENT(IN) :: CONDITION
    CHARACTER(*), INTENT(IN) :: MSG
    CALL ASSERT_TRUE(.NOT. CONDITION, MSG)
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE ASSERT_EQUAL_INT(EXPECTED, ACTUAL, MSG)
    INTEGER, INTENT(IN) :: EXPECTED, ACTUAL
    CHARACTER(*), INTENT(IN) :: MSG
    TESTS_RUN = TESTS_RUN + 1
    IF (EXPECTED == ACTUAL) THEN
      TESTS_PASSED = TESTS_PASSED + 1
      WRITE(*,'(A,A)') 'PASS: ', TRIM(MSG)
    ELSE
      TESTS_FAILED = TESTS_FAILED + 1
      WRITE(*,'(A,A,A,I0,A,I0,A)') 'FAIL: ', TRIM(MSG), &
        ' [expected ', EXPECTED, ', got ', ACTUAL, ']'
    END IF
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE ASSERT_EQUAL_REAL(EXPECTED, ACTUAL, MSG, TOL)
    REAL(R8), INTENT(IN) :: EXPECTED, ACTUAL
    CHARACTER(*), INTENT(IN) :: MSG
    REAL(R8), INTENT(IN), OPTIONAL :: TOL
    REAL(R8) :: T
    T = DEFAULT_TOL
    IF (PRESENT(TOL)) T = TOL
    TESTS_RUN = TESTS_RUN + 1
    IF (ABS(EXPECTED - ACTUAL) <= T) THEN
      TESTS_PASSED = TESTS_PASSED + 1
      WRITE(*,'(A,A)') 'PASS: ', TRIM(MSG)
    ELSE
      TESTS_FAILED = TESTS_FAILED + 1
      WRITE(*,'(A,A,A,ES14.6,A,ES14.6,A)') 'FAIL: ', TRIM(MSG), &
        ' [expected ', EXPECTED, ', got ', ACTUAL, ']'
    END IF
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE ASSERT_NEAR(EXPECTED, ACTUAL, TOL, MSG)
    REAL(R8), INTENT(IN) :: EXPECTED, ACTUAL, TOL
    CHARACTER(*), INTENT(IN) :: MSG
    CALL ASSERT_EQUAL_REAL(EXPECTED, ACTUAL, MSG, TOL)
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE ASSERT_GT(A, B, MSG)
    REAL(R8), INTENT(IN) :: A, B
    CHARACTER(*), INTENT(IN) :: MSG
    TESTS_RUN = TESTS_RUN + 1
    IF (A > B) THEN
      TESTS_PASSED = TESTS_PASSED + 1
      WRITE(*,'(A,A)') 'PASS: ', TRIM(MSG)
    ELSE
      TESTS_FAILED = TESTS_FAILED + 1
      WRITE(*,'(A,A,A,ES14.6,A,ES14.6,A)') 'FAIL: ', TRIM(MSG), &
        ' [', A, ' not > ', B, ']'
    END IF
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE ASSERT_LE(A, B, MSG)
    REAL(R8), INTENT(IN) :: A, B
    CHARACTER(*), INTENT(IN) :: MSG
    TESTS_RUN = TESTS_RUN + 1
    IF (A <= B) THEN
      TESTS_PASSED = TESTS_PASSED + 1
      WRITE(*,'(A,A)') 'PASS: ', TRIM(MSG)
    ELSE
      TESTS_FAILED = TESTS_FAILED + 1
      WRITE(*,'(A,A,A,ES14.6,A,ES14.6,A)') 'FAIL: ', TRIM(MSG), &
        ' [', A, ' not <= ', B, ']'
    END IF
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_SUMMARY()
    WRITE(*,'(A)') ''
    WRITE(*,'(A)') REPEAT('=', 60)
    WRITE(*,'(A,I0)') 'Tests run:    ', TESTS_RUN
    WRITE(*,'(A,I0)') 'Tests passed: ', TESTS_PASSED
    WRITE(*,'(A,I0)') 'Tests failed: ', TESTS_FAILED
    WRITE(*,'(A)') REPEAT('=', 60)
    IF (TESTS_FAILED > 0) THEN
      WRITE(*,'(A)') 'RESULT: FAILURE'
      STOP 1
    ELSE
      WRITE(*,'(A)') 'RESULT: SUCCESS'
    END IF
  END SUBROUTINE

END MODULE TEST_FRAMEWORK
