!*******************************************************************************
! TEST_NFIX - Tests for nitrogen fixation algorithm
!
! Replicates water-quality.f90:693-696 (ANLIM recalculation),
! :1512 (NH4 uptake), and :1586 (NO3 uptake).
!*******************************************************************************
MODULE TEST_NFIX
  USE PREC
  USE TEST_FRAMEWORK
  IMPLICIT NONE

  REAL(R8), PARAMETER :: NONZERO = 1.0D-20

CONTAINS

  SUBROUTINE RUN_NFIX_TESTS()
    CALL TEST_SUITE_START('Nitrogen Fixation')
    CALL TEST_NFIX_INACTIVE()
    CALL TEST_NFIX_TRIGGERED()
    CALL TEST_NFIX_NOT_TRIGGERED()
    CALL TEST_NFIX_AT_THRESHOLD()
    CALL TEST_NH4_UPTAKE_SKIPPED()
    CALL TEST_NH4_UPTAKE_NORMAL()
    CALL TEST_NO3_UPTAKE_SKIPPED()
    CALL TEST_NO3_UPTAKE_NORMAL()
    CALL TEST_MULTI_GROUP_SELECTIVE()
  END SUBROUTINE

  !---------------------------------------------------------------------------
  ! Helper: compute ANLIM exactly as production code (water-quality.f90:693-696)
  !---------------------------------------------------------------------------
  REAL(R8) FUNCTION COMPUTE_ANLIM(NH4, NO3, AHSN, CRIT_TIN)
    REAL(R8), INTENT(IN) :: NH4, NO3, AHSN, CRIT_TIN
    REAL(R8) :: TIN
    LOGICAL :: N_CALC

    TIN = NH4 + NO3
    N_CALC = .TRUE.  ! Assume nitrogen calculation is active

    ! Standard N limitation
    IF (AHSN /= 0.0D0 .AND. N_CALC) THEN
      COMPUTE_ANLIM = TIN / (TIN + AHSN + NONZERO)
    ELSE
      COMPUTE_ANLIM = 1.0D0  ! No N limitation if AHSN=0
    END IF

    ! N-fixation override
    IF (TIN < CRIT_TIN .AND. N_CALC) THEN
      COMPUTE_ANLIM = TIN / (TIN + 0.0D0 + NONZERO)
    END IF
  END FUNCTION

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NFIX_INACTIVE()
    ! CRIT_TIN=0 → standard ANLIM with AHSN
    REAL(R8) :: ANLIM, EXPECTED, NH4, NO3, AHSN
    NH4  = 0.05D0
    NO3  = 0.03D0
    AHSN = 0.014D0
    EXPECTED = (NH4+NO3) / (NH4+NO3+AHSN+NONZERO)
    ANLIM = COMPUTE_ANLIM(NH4, NO3, AHSN, 0.0D0)
    CALL ASSERT_EQUAL_REAL(EXPECTED, ANLIM, 'N-fix inactive: standard ANLIM with AHSN')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NFIX_TRIGGERED()
    ! TIN < CRIT_TIN → ANLIM recalculated with AHSN=0 (≈1.0)
    REAL(R8) :: ANLIM, NH4, NO3, AHSN, CRIT_TIN
    NH4      = 0.01D0
    NO3      = 0.005D0
    AHSN     = 0.014D0
    CRIT_TIN = 0.02D0  ! TIN=0.015 < 0.02 → triggered
    ANLIM = COMPUTE_ANLIM(NH4, NO3, AHSN, CRIT_TIN)
    ! With AHSN=0: ANLIM ≈ TIN/(TIN+NONZERO) ≈ 1.0
    CALL ASSERT_NEAR(1.0D0, ANLIM, 1.0D-10, &
      'N-fix triggered: ANLIM near 1.0 (AHSN=0 in denominator)')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NFIX_NOT_TRIGGERED()
    ! TIN > CRIT_TIN → standard ANLIM
    REAL(R8) :: ANLIM, EXPECTED, NH4, NO3, AHSN, CRIT_TIN
    NH4      = 0.05D0
    NO3      = 0.03D0
    AHSN     = 0.014D0
    CRIT_TIN = 0.02D0  ! TIN=0.08 > 0.02 → not triggered
    EXPECTED = (NH4+NO3) / (NH4+NO3+AHSN+NONZERO)
    ANLIM = COMPUTE_ANLIM(NH4, NO3, AHSN, CRIT_TIN)
    CALL ASSERT_EQUAL_REAL(EXPECTED, ANLIM, 'N-fix not triggered: standard ANLIM')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NFIX_AT_THRESHOLD()
    ! TIN = CRIT_TIN → NOT triggered (uses strict < not <=)
    REAL(R8) :: ANLIM, EXPECTED, NH4, NO3, AHSN, CRIT_TIN
    NH4      = 0.01D0
    NO3      = 0.01D0
    AHSN     = 0.014D0
    CRIT_TIN = 0.02D0  ! TIN=0.02 = CRIT_TIN → not triggered
    EXPECTED = (NH4+NO3) / (NH4+NO3+AHSN+NONZERO)
    ANLIM = COMPUTE_ANLIM(NH4, NO3, AHSN, CRIT_TIN)
    CALL ASSERT_EQUAL_REAL(EXPECTED, ANLIM, &
      'N-fix at threshold: NOT triggered (strict <)')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NH4_UPTAKE_SKIPPED()
    ! TIN < CRIT_TIN → NH4AG not accumulated
    REAL(R8) :: NH4AG, AGR, ALG, AN, NH4PR, NH4, NO3, AHSN, CRIT_TIN
    NH4AG    = 0.0D0
    AGR      = 0.1D0
    ALG      = 5.0D0
    AN       = 0.08D0
    NH4PR    = 0.7D0
    NH4      = 0.005D0
    NO3      = 0.003D0
    AHSN     = 0.014D0
    CRIT_TIN = 0.02D0  ! TIN=0.008 < 0.02

    ! Production code: IF (AHSN > 0 .AND. CRIT_TIN < (NH4+NO3)) NH4AG = ...
    IF (AHSN > 0.0D0 .AND. CRIT_TIN < (NH4+NO3)) THEN
      NH4AG = NH4AG + AGR*ALG*AN*NH4PR
    END IF

    CALL ASSERT_EQUAL_REAL(0.0D0, NH4AG, 'NH4 uptake skipped when TIN < CRIT_TIN')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NH4_UPTAKE_NORMAL()
    ! TIN > CRIT_TIN → NH4AG accumulated normally
    REAL(R8) :: NH4AG, AGR, ALG, AN, NH4PR, NH4, NO3, AHSN, CRIT_TIN, EXPECTED
    NH4AG    = 0.0D0
    AGR      = 0.1D0
    ALG      = 5.0D0
    AN       = 0.08D0
    NH4PR    = 0.7D0
    NH4      = 0.05D0
    NO3      = 0.03D0
    AHSN     = 0.014D0
    CRIT_TIN = 0.02D0  ! TIN=0.08 > 0.02

    IF (AHSN > 0.0D0 .AND. CRIT_TIN < (NH4+NO3)) THEN
      NH4AG = NH4AG + AGR*ALG*AN*NH4PR
    END IF
    EXPECTED = 0.1D0 * 5.0D0 * 0.08D0 * 0.7D0
    CALL ASSERT_EQUAL_REAL(EXPECTED, NH4AG, 'NH4 uptake normal when TIN > CRIT_TIN')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NO3_UPTAKE_SKIPPED()
    ! TIN < CRIT_TIN → NO3AG not accumulated
    REAL(R8) :: NO3AG, AGR, ALG, AN, NO3PR, NH4, NO3, AHSN, CRIT_TIN
    NO3AG    = 0.0D0
    AGR      = 0.1D0
    ALG      = 5.0D0
    AN       = 0.08D0
    NO3PR    = 0.3D0
    NH4      = 0.005D0
    NO3      = 0.003D0
    AHSN     = 0.014D0
    CRIT_TIN = 0.02D0  ! TIN=0.008 < 0.02

    IF (AHSN > 0.0D0 .AND. CRIT_TIN < (NH4+NO3)) THEN
      NO3AG = NO3AG + AGR*ALG*NO3PR*AN
    END IF

    CALL ASSERT_EQUAL_REAL(0.0D0, NO3AG, 'NO3 uptake skipped when TIN < CRIT_TIN')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NO3_UPTAKE_NORMAL()
    ! TIN > CRIT_TIN → NO3AG accumulated normally
    REAL(R8) :: NO3AG, AGR, ALG, AN, NO3PR, NH4, NO3, AHSN, CRIT_TIN, EXPECTED
    NO3AG    = 0.0D0
    AGR      = 0.1D0
    ALG      = 5.0D0
    AN       = 0.08D0
    NO3PR    = 0.3D0
    NH4      = 0.05D0
    NO3      = 0.03D0
    AHSN     = 0.014D0
    CRIT_TIN = 0.02D0  ! TIN=0.08 > 0.02

    IF (AHSN > 0.0D0 .AND. CRIT_TIN < (NH4+NO3)) THEN
      NO3AG = NO3AG + AGR*ALG*NO3PR*AN
    END IF
    EXPECTED = 0.1D0 * 5.0D0 * 0.3D0 * 0.08D0
    CALL ASSERT_EQUAL_REAL(EXPECTED, NO3AG, 'NO3 uptake normal when TIN > CRIT_TIN')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_MULTI_GROUP_SELECTIVE()
    ! Group 1: CRIT_TIN=0 (off), Group 2: CRIT_TIN=0.02 (on, triggered)
    REAL(R8) :: ANLIM(2), NH4, NO3, AHSN(2), CRIT_TIN(2)
    NH4  = 0.005D0
    NO3  = 0.003D0
    AHSN = (/0.014D0, 0.014D0/)
    CRIT_TIN = (/0.0D0, 0.02D0/)

    ANLIM(1) = COMPUTE_ANLIM(NH4, NO3, AHSN(1), CRIT_TIN(1))
    ANLIM(2) = COMPUTE_ANLIM(NH4, NO3, AHSN(2), CRIT_TIN(2))

    ! Group 1: standard → (0.008)/(0.008+0.014) = 0.3636...
    CALL ASSERT_NEAR((NH4+NO3)/(NH4+NO3+AHSN(1)+NONZERO), ANLIM(1), 1.0D-10, &
      'Multi-group: group 1 (off) uses standard ANLIM')
    ! Group 2: triggered → ≈1.0
    CALL ASSERT_NEAR(1.0D0, ANLIM(2), 1.0D-10, &
      'Multi-group: group 2 (on) has ANLIM near 1.0')
  END SUBROUTINE

END MODULE TEST_NFIX
