!*******************************************************************************
! RUN_ALL_TESTS - Main driver for CE-QUAL-W2 HAB unit tests
!
! Calls all test suites, then prints summary and exits with non-zero
! status on any failure.
!*******************************************************************************
PROGRAM RUN_ALL_TESTS
  USE TEST_FRAMEWORK
  USE TEST_HARVEST_ALGO
  USE TEST_HARVEST_MASS
  USE TEST_HARVEST_INPUT
  USE TEST_LOW_DO_MORT
  USE TEST_LOW_DO_INPUT
  USE TEST_ALG_MIN
  USE TEST_NFIX
  USE TEST_NFIX_INPUT
  IMPLICIT NONE

  WRITE(*,'(A)') '============================================================'
  WRITE(*,'(A)') ' CE-QUAL-W2 HAB Unit Tests'
  WRITE(*,'(A)') '============================================================'

  CALL RUN_HARVEST_ALGO_TESTS()
  CALL RUN_HARVEST_MASS_TESTS()
  CALL RUN_HARVEST_INPUT_TESTS()
  CALL RUN_LOW_DO_MORT_TESTS()
  CALL RUN_LOW_DO_INPUT_TESTS()
  CALL RUN_ALG_MIN_TESTS()
  CALL RUN_NFIX_TESTS()
  CALL RUN_NFIX_INPUT_TESTS()

  CALL TEST_SUMMARY()

END PROGRAM RUN_ALL_TESTS
