!*******************************************************************************
! TEST_HARVEST_ALGO - Tests for algal harvesting algorithm (update.F90:96-121)
!
! Verifies H-01 (multi-segment FHA persistence), H-02 (depth-limited
! harvesting), and ALG_MIN clamping after harvest.
!*******************************************************************************
MODULE TEST_HARVEST_ALGO
  USE PREC
  USE TEST_FRAMEWORK
  IMPLICIT NONE
CONTAINS

  SUBROUTINE RUN_HARVEST_ALGO_TESTS()
    CALL TEST_SUITE_START('Harvest Algorithm')
    CALL TEST_ZERO_FHA()
    CALL TEST_FULL_HARVEST()
    CALL TEST_PARTIAL_HARVEST()
    CALL TEST_MULTI_SEGMENT()
    CALL TEST_H01_FHA_PERSISTS()
    CALL TEST_H02_DEPTH_UNLIMITED()
    CALL TEST_H02_DEPTH_LIMITED()
    CALL TEST_H02_DEPTH_BOUNDARY()
    CALL TEST_H02_DEPTH_JUST_BELOW()
    CALL TEST_ALG_MIN_CLAMP_AFTER_HARVEST()
    CALL TEST_NON_ALGAE_UNTOUCHED()
  END SUBROUTINE

  !---------------------------------------------------------------------------
  ! Helper: apply harvest algorithm for a single cell (replicates update.F90)
  !---------------------------------------------------------------------------
  SUBROUTINE APPLY_HARVEST(C1_VAL, FHA_VAL, HADEP_VAL, ELWS_VAL, &
                           EL_VAL, H_VAL, IS_ALGAE, ALG_MIN_VAL, &
                           BH1_VAL, DLX_VAL, MASS_OUT)
    REAL(R8), INTENT(INOUT) :: C1_VAL
    REAL(R8), INTENT(IN)    :: FHA_VAL, HADEP_VAL, ELWS_VAL, EL_VAL, H_VAL
    LOGICAL,  INTENT(IN)    :: IS_ALGAE
    REAL(R8), INTENT(IN)    :: ALG_MIN_VAL, BH1_VAL, DLX_VAL
    REAL(R8), INTENT(OUT)   :: MASS_OUT
    REAL(R8) :: DEPTH_BELOW_SURFACE, REMOVED, CELL_VOL

    MASS_OUT = 0.0D0

    IF (IS_ALGAE) THEN
      IF (FHA_VAL /= 0.0D0) THEN
        ! H-02: Depth-limited harvesting
        IF (HADEP_VAL > 0.0D0) THEN
          DEPTH_BELOW_SURFACE = ELWS_VAL - (EL_VAL - H_VAL * 0.5D0)
          IF (DEPTH_BELOW_SURFACE > HADEP_VAL) THEN
            ! Skip harvest, still apply ALG_MIN clamp
            IF (C1_VAL < ALG_MIN_VAL) C1_VAL = ALG_MIN_VAL
            RETURN
          END IF
        END IF
        ! H-03: mass tracking
        REMOVED  = C1_VAL * FHA_VAL
        CELL_VOL = BH1_VAL * DLX_VAL
        MASS_OUT = REMOVED * CELL_VOL
        ! Apply harvest
        C1_VAL = C1_VAL - REMOVED
      END IF
      ! ALG_MIN clamp
      IF (C1_VAL < ALG_MIN_VAL) C1_VAL = ALG_MIN_VAL
    END IF
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_ZERO_FHA()
    REAL(R8) :: C1, MASS
    C1 = 5.0D0
    CALL APPLY_HARVEST(C1, 0.0D0, 0.0D0, 100.0D0, 99.0D0, 2.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(5.0D0, C1, 'FHA=0 leaves C1 unchanged')
    CALL ASSERT_EQUAL_REAL(0.0D0, MASS, 'FHA=0 produces zero mass')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_FULL_HARVEST()
    REAL(R8) :: C1, MASS
    C1 = 5.0D0
    CALL APPLY_HARVEST(C1, 1.0D0, 0.0D0, 100.0D0, 99.0D0, 2.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(0.0D0, C1, 'FHA=1.0 removes all algae')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_PARTIAL_HARVEST()
    REAL(R8) :: C1, MASS
    C1 = 10.0D0
    CALL APPLY_HARVEST(C1, 0.3D0, 0.0D0, 100.0D0, 99.0D0, 2.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(7.0D0, C1, 'FHA=0.3 reduces C1 by 30%')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_MULTI_SEGMENT()
    ! Two segments with different FHA, each reduced independently
    REAL(R8) :: C1_A, C1_B, MASS_A, MASS_B
    C1_A = 10.0D0
    C1_B = 20.0D0
    CALL APPLY_HARVEST(C1_A, 0.2D0, 0.0D0, 100.0D0, 99.0D0, 2.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS_A)
    CALL APPLY_HARVEST(C1_B, 0.5D0, 0.0D0, 100.0D0, 99.0D0, 2.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS_B)
    CALL ASSERT_EQUAL_REAL(8.0D0, C1_A, 'Multi-segment: seg A reduced by 20%')
    CALL ASSERT_EQUAL_REAL(10.0D0, C1_B, 'Multi-segment: seg B reduced by 50%')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_H01_FHA_PERSISTS()
    ! H-01 fix: FHA not zeroed between segments in inner loop
    ! Simulate processing two segments with same FHA (not zeroed between them)
    REAL(R8) :: C1_1, C1_2, FHA_VAL, MASS
    FHA_VAL = 0.4D0
    C1_1 = 10.0D0
    C1_2 = 15.0D0
    ! Process segment 1
    CALL APPLY_HARVEST(C1_1, FHA_VAL, 0.0D0, 100.0D0, 99.0D0, 2.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    ! FHA_VAL still 0.4 (not zeroed) — this is the H-01 fix
    CALL APPLY_HARVEST(C1_2, FHA_VAL, 0.0D0, 100.0D0, 99.0D0, 2.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(6.0D0, C1_1, 'H-01: seg 1 harvested with FHA=0.4')
    CALL ASSERT_EQUAL_REAL(9.0D0, C1_2, 'H-01: seg 2 also harvested (FHA persists)')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_H02_DEPTH_UNLIMITED()
    ! HADEP=0 means all layers are harvested
    REAL(R8) :: C1, MASS
    ! Deep layer: EL=50, H=2, center=49, ELWS=100, depth=51m
    C1 = 10.0D0
    CALL APPLY_HARVEST(C1, 0.5D0, 0.0D0, 100.0D0, 50.0D0, 2.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(5.0D0, C1, 'H-02: HADEP=0 harvests deep layer')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_H02_DEPTH_LIMITED()
    ! HADEP=3.0m — only shallow layers harvested
    ! Shallow layer: ELWS=100, EL=99.5, H=1.0 → center = 99.0 → depth = 1.0m (harvested)
    ! Deep layer:    ELWS=100, EL=95.0, H=2.0 → center = 94.0 → depth = 6.0m (skipped)
    REAL(R8) :: C1_SHALLOW, C1_DEEP, MASS
    C1_SHALLOW = 10.0D0
    C1_DEEP    = 10.0D0
    CALL APPLY_HARVEST(C1_SHALLOW, 0.5D0, 3.0D0, 100.0D0, 99.5D0, 1.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL APPLY_HARVEST(C1_DEEP, 0.5D0, 3.0D0, 100.0D0, 95.0D0, 2.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(5.0D0, C1_SHALLOW, 'H-02: shallow layer harvested')
    CALL ASSERT_EQUAL_REAL(10.0D0, C1_DEEP, 'H-02: deep layer skipped')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_H02_DEPTH_BOUNDARY()
    ! Layer center exactly at HADEP → harvested (depth <= HADEP since > is the skip condition)
    ! ELWS=100, EL=98.5, H=1.0 → center = 98.0 → depth = 2.0m, HADEP=2.0m
    ! depth(2.0) > HADEP(2.0) is FALSE → harvested
    REAL(R8) :: C1, MASS
    C1 = 10.0D0
    CALL APPLY_HARVEST(C1, 0.5D0, 2.0D0, 100.0D0, 98.5D0, 1.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(5.0D0, C1, 'H-02: layer at exact HADEP boundary harvested')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_H02_DEPTH_JUST_BELOW()
    ! Layer center slightly past HADEP → skipped
    ! ELWS=100, EL=98.4, H=1.0 → center = 97.9 → depth = 2.1m, HADEP=2.0m
    ! depth(2.1) > HADEP(2.0) is TRUE → skipped
    REAL(R8) :: C1, MASS
    C1 = 10.0D0
    CALL APPLY_HARVEST(C1, 0.5D0, 2.0D0, 100.0D0, 98.4D0, 1.0D0, &
                       .TRUE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(10.0D0, C1, 'H-02: layer just past HADEP skipped')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_ALG_MIN_CLAMP_AFTER_HARVEST()
    ! Harvest reduces below ALG_MIN → clamped to ALG_MIN
    REAL(R8) :: C1, MASS
    C1 = 0.02D0
    CALL APPLY_HARVEST(C1, 0.9D0, 0.0D0, 100.0D0, 99.0D0, 2.0D0, &
                       .TRUE., 0.01D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(0.01D0, C1, 'Harvest below ALG_MIN clamped to ALG_MIN')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_NON_ALGAE_UNTOUCHED()
    ! Constituent that is not algae (IS_ALGAE=.FALSE.) should not be modified
    REAL(R8) :: C1, MASS
    C1 = 10.0D0
    CALL APPLY_HARVEST(C1, 0.5D0, 0.0D0, 100.0D0, 99.0D0, 2.0D0, &
                       .FALSE., 0.0D0, 50.0D0, 100.0D0, MASS)
    CALL ASSERT_EQUAL_REAL(10.0D0, C1, 'Non-algae constituent unchanged')
  END SUBROUTINE

END MODULE TEST_HARVEST_ALGO
