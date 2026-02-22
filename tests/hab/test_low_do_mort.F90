!*******************************************************************************
! TEST_LOW_DO_MORT - Tests for low DO mortality algorithm
!
! Replicates water-quality.f90:302-307 (DO4 switch, DELT_LOW_DO accumulation)
! and water-quality.f90:704 (mortality override).
!*******************************************************************************
MODULE TEST_LOW_DO_MORT
  USE PREC
  USE TEST_FRAMEWORK
  IMPLICIT NONE
CONTAINS

  SUBROUTINE RUN_LOW_DO_MORT_TESTS()
    CALL TEST_SUITE_START('Low DO Mortality')
    CALL TEST_DO4_BELOW_THRESHOLD()
    CALL TEST_DO4_ABOVE_THRESHOLD()
    CALL TEST_DO4_AT_THRESHOLD()
    CALL TEST_DO4_INACTIVE()
    CALL TEST_DELT_ACCUMULATION()
    CALL TEST_DELT_RESET_ON_RECOVERY()
    CALL TEST_MORTALITY_SWITCH()
    CALL TEST_MORTALITY_BELOW_CRIT()
    CALL TEST_MULTI_ALGAE_GROUPS()
  END SUBROUTINE

  !---------------------------------------------------------------------------
  ! Helper: compute DO4 exactly as production code
  !---------------------------------------------------------------------------
  REAL(R8) FUNCTION COMPUTE_DO4(ALG_O2LIM, O2)
    REAL(R8), INTENT(IN) :: ALG_O2LIM, O2
    IF (ALG_O2LIM > 0.0D0) THEN
      COMPUTE_DO4 = (1.0D0 + SIGN(1.0D0, ALG_O2LIM - O2)) * 0.5D0
    ELSE
      COMPUTE_DO4 = 0.0D0
    END IF
  END FUNCTION

  !---------------------------------------------------------------------------
  ! Helper: accumulate DELT_LOW_DO exactly as production code
  !---------------------------------------------------------------------------
  REAL(R8) FUNCTION ACCUMULATE_DELT(DELT_LOW_DO_PREV, DLT, DO4)
    REAL(R8), INTENT(IN) :: DELT_LOW_DO_PREV, DLT, DO4
    ACCUMULATE_DELT = (DELT_LOW_DO_PREV + DLT) * DO4
  END FUNCTION

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_DO4_BELOW_THRESHOLD()
    ! O2 < ALG_O2LIM → DO4=1.0
    REAL(R8) :: DO4
    DO4 = COMPUTE_DO4(2.0D0, 1.0D0)  ! O2=1 < threshold=2
    CALL ASSERT_EQUAL_REAL(1.0D0, DO4, 'DO4=1.0 when O2 below threshold')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_DO4_ABOVE_THRESHOLD()
    ! O2 > ALG_O2LIM → DO4=0.0
    REAL(R8) :: DO4
    DO4 = COMPUTE_DO4(2.0D0, 5.0D0)  ! O2=5 > threshold=2
    CALL ASSERT_EQUAL_REAL(0.0D0, DO4, 'DO4=0.0 when O2 above threshold')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_DO4_AT_THRESHOLD()
    ! O2 = ALG_O2LIM → SIGN(1.0, 0.0) = +1.0 → DO4=1.0
    REAL(R8) :: DO4
    DO4 = COMPUTE_DO4(2.0D0, 2.0D0)
    CALL ASSERT_EQUAL_REAL(1.0D0, DO4, 'DO4=1.0 when O2 equals threshold (SIGN convention)')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_DO4_INACTIVE()
    ! ALG_O2LIM=0 → feature inactive → DO4=0.0
    REAL(R8) :: DO4
    DO4 = COMPUTE_DO4(0.0D0, 1.0D0)
    CALL ASSERT_EQUAL_REAL(0.0D0, DO4, 'DO4=0.0 when feature inactive (ALG_O2LIM=0)')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_DELT_ACCUMULATION()
    ! 3 timesteps with low DO → DELT_LOW_DO = 3*DLT
    REAL(R8) :: DELT_LOW_DO, DLT, DO4
    INTEGER :: I
    DLT = 60.0D0  ! 60 second timestep
    DELT_LOW_DO = 0.0D0
    DO4 = 1.0D0   ! Continuously low DO
    DO I = 1, 3
      DELT_LOW_DO = ACCUMULATE_DELT(DELT_LOW_DO, DLT, DO4)
    END DO
    CALL ASSERT_EQUAL_REAL(180.0D0, DELT_LOW_DO, &
      'DELT_LOW_DO = 3*DLT after 3 low-DO timesteps')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_DELT_RESET_ON_RECOVERY()
    ! DO rises → DO4=0 → DELT_LOW_DO resets to 0
    REAL(R8) :: DELT_LOW_DO, DLT
    DLT = 60.0D0
    DELT_LOW_DO = 300.0D0  ! Was accumulating
    ! DO recovers: DO4=0
    DELT_LOW_DO = ACCUMULATE_DELT(DELT_LOW_DO, DLT, 0.0D0)
    CALL ASSERT_EQUAL_REAL(0.0D0, DELT_LOW_DO, &
      'DELT_LOW_DO resets to 0 when DO recovers (DO4=0)')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_MORTALITY_SWITCH()
    ! DELT_LOW_DO > CRIT_T → AMR = AM_LOW_DO
    REAL(R8) :: AMR, AM_NORMAL, AM_LOW_DO, CRIT_T, DELT_LOW_DO
    REAL(R8) :: ATRMR, ATRMF, AM
    AM = 0.01D0        ! Normal base mortality rate (1/sec)
    ATRMR = 1.0D0      ! Temperature rate multiplier
    ATRMF = 1.0D0      ! Temperature factor
    AM_LOW_DO = 0.5D0  ! High mortality (1/sec, after unit conversion)
    CRIT_T = 86400.0D0 ! 1 day in seconds
    DELT_LOW_DO = 90000.0D0  ! Exceeds CRIT_T

    ! Standard mortality calculation
    AMR = (ATRMR + 1.0D0 - ATRMF) * AM
    AM_NORMAL = AMR
    ! Override if critical time exceeded
    IF (DELT_LOW_DO > CRIT_T) AMR = AM_LOW_DO

    CALL ASSERT_EQUAL_REAL(AM_LOW_DO, AMR, &
      'AMR = AM_LOW_DO when DELT_LOW_DO > CRIT_T')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_MORTALITY_BELOW_CRIT()
    ! DELT_LOW_DO < CRIT_T → AMR = normal mortality
    REAL(R8) :: AMR, AM_LOW_DO, CRIT_T, DELT_LOW_DO
    REAL(R8) :: ATRMR, ATRMF, AM, EXPECTED
    AM = 0.01D0
    ATRMR = 1.0D0
    ATRMF = 1.0D0
    AM_LOW_DO = 0.5D0
    CRIT_T = 86400.0D0
    DELT_LOW_DO = 50000.0D0  ! Below CRIT_T

    AMR = (ATRMR + 1.0D0 - ATRMF) * AM
    EXPECTED = AMR
    IF (DELT_LOW_DO > CRIT_T) AMR = AM_LOW_DO

    CALL ASSERT_EQUAL_REAL(EXPECTED, AMR, &
      'AMR = normal when DELT_LOW_DO < CRIT_T')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_MULTI_ALGAE_GROUPS()
    ! 3 algae groups, different CRIT_T, only exceeded group switches
    INTEGER, PARAMETER :: NAL = 3
    REAL(R8) :: AMR(NAL), AM(NAL), AM_LOW_DO(NAL), CRIT_T(NAL)
    REAL(R8) :: DELT_LOW_DO, ATRMR, ATRMF
    INTEGER :: JA

    AM        = (/0.01D0, 0.02D0, 0.015D0/)
    AM_LOW_DO = (/0.5D0, 0.6D0, 0.7D0/)
    CRIT_T    = (/86400.0D0, 172800.0D0, 259200.0D0/)  ! 1, 2, 3 days
    DELT_LOW_DO = 100000.0D0  ! Exceeds CRIT_T(1) only
    ATRMR = 1.0D0
    ATRMF = 1.0D0

    DO JA = 1, NAL
      AMR(JA) = (ATRMR + 1.0D0 - ATRMF) * AM(JA)
      IF (DELT_LOW_DO > CRIT_T(JA)) AMR(JA) = AM_LOW_DO(JA)
    END DO

    CALL ASSERT_EQUAL_REAL(0.5D0, AMR(1), &
      'Multi-group: group 1 exceeded CRIT_T → AM_LOW_DO')
    CALL ASSERT_EQUAL_REAL(AM(2), AMR(2), &
      'Multi-group: group 2 below CRIT_T → normal')
    CALL ASSERT_EQUAL_REAL(AM(3), AMR(3), &
      'Multi-group: group 3 below CRIT_T → normal')
  END SUBROUTINE

END MODULE TEST_LOW_DO_MORT
