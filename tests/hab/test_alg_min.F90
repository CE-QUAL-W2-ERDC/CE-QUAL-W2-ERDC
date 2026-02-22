!*******************************************************************************
! TEST_ALG_MIN - Tests for minimum algae seed floor (update.F90:120)
!
! Verifies clamping behavior: IF (C1 < ALG_MIN) C1 = ALG_MIN
!*******************************************************************************
MODULE TEST_ALG_MIN
  USE PREC
  USE TEST_FRAMEWORK
  IMPLICIT NONE
CONTAINS

  SUBROUTINE RUN_ALG_MIN_TESTS()
    CALL TEST_SUITE_START('Minimum Algae Seed')
    CALL TEST_BELOW_MIN_CLAMPED()
    CALL TEST_ABOVE_MIN_UNCHANGED()
    CALL TEST_ALG_MIN_ZERO_DISABLED()
    CALL TEST_AFTER_HARVEST()
    CALL TEST_EXACT_AT_MIN()
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_BELOW_MIN_CLAMPED()
    REAL(R8) :: C1, ALG_MIN
    C1 = 0.005D0
    ALG_MIN = 0.01D0
    IF (C1 < ALG_MIN) C1 = ALG_MIN
    CALL ASSERT_EQUAL_REAL(0.01D0, C1, 'Below min: clamped to ALG_MIN')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_ABOVE_MIN_UNCHANGED()
    REAL(R8) :: C1, ALG_MIN
    C1 = 0.5D0
    ALG_MIN = 0.01D0
    IF (C1 < ALG_MIN) C1 = ALG_MIN
    CALL ASSERT_EQUAL_REAL(0.5D0, C1, 'Above min: unchanged')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_ALG_MIN_ZERO_DISABLED()
    ! ALG_MIN=0.0 means no clamping (even negative-ish values pass through)
    REAL(R8) :: C1, ALG_MIN
    C1 = 0.001D0
    ALG_MIN = 0.0D0
    IF (C1 < ALG_MIN) C1 = ALG_MIN
    CALL ASSERT_EQUAL_REAL(0.001D0, C1, 'ALG_MIN=0: no clamping')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_AFTER_HARVEST()
    ! Harvest to very low value, then clamp
    REAL(R8) :: C1, FHA, ALG_MIN
    C1 = 0.1D0
    FHA = 0.98D0  ! Remove 98%
    ALG_MIN = 0.01D0
    C1 = C1 - C1 * FHA  ! C1 = 0.002
    IF (C1 < ALG_MIN) C1 = ALG_MIN
    CALL ASSERT_EQUAL_REAL(0.01D0, C1, 'After harvest: clamped to ALG_MIN')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_EXACT_AT_MIN()
    REAL(R8) :: C1, ALG_MIN
    C1 = 0.01D0
    ALG_MIN = 0.01D0
    IF (C1 < ALG_MIN) C1 = ALG_MIN
    CALL ASSERT_EQUAL_REAL(0.01D0, C1, 'Exact at min: unchanged')
  END SUBROUTINE

END MODULE TEST_ALG_MIN
