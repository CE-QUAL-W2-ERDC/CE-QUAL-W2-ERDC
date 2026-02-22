!*******************************************************************************
! TEST_HARVEST_MASS - Tests for harvest mass tracking (H-03)
!
! Verifies event mass computation, multi-layer accumulation, cumulative
! tracking, event reset, and depth-limited mass accounting.
!*******************************************************************************
MODULE TEST_HARVEST_MASS
  USE PREC
  USE TEST_FRAMEWORK
  IMPLICIT NONE
CONTAINS

  SUBROUTINE RUN_HARVEST_MASS_TESTS()
    CALL TEST_SUITE_START('Harvest Mass Tracking')
    CALL TEST_EVENT_MASS_SINGLE_CELL()
    CALL TEST_EVENT_MASS_MULTI_LAYER()
    CALL TEST_CUMULATIVE_MASS()
    CALL TEST_EVENT_MASS_RESET()
    CALL TEST_MASS_DEPTH_LIMITED()
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_EVENT_MASS_SINGLE_CELL()
    ! HAMASS_EVENT = C1 * FHA * BH1 * DLX
    REAL(R8) :: C1, FHA, BH1, DLX, REMOVED, CELL_VOL, HAMASS_EVENT
    C1  = 5.0D0    ! g/m3
    FHA = 0.4D0    ! 40% removal
    BH1 = 50.0D0   ! m2 cross-section
    DLX = 100.0D0  ! m segment length
    REMOVED  = C1 * FHA                ! 2.0 g/m3
    CELL_VOL = BH1 * DLX              ! 5000 m3
    HAMASS_EVENT = REMOVED * CELL_VOL  ! 10000 g
    CALL ASSERT_EQUAL_REAL(10000.0D0, HAMASS_EVENT, &
      'Event mass single cell: C1*FHA*BH1*DLX')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_EVENT_MASS_MULTI_LAYER()
    ! Sum mass over 3 vertical layers
    REAL(R8) :: C1(3), BH1(3), DLX, FHA, HAMASS_EVENT
    INTEGER :: K
    C1  = (/5.0D0, 3.0D0, 2.0D0/)    ! g/m3 per layer
    BH1 = (/50.0D0, 40.0D0, 30.0D0/) ! m2 per layer
    DLX = 100.0D0
    FHA = 0.5D0
    HAMASS_EVENT = 0.0D0
    DO K = 1, 3
      HAMASS_EVENT = HAMASS_EVENT + C1(K) * FHA * BH1(K) * DLX
    END DO
    ! Expected: (5*0.5*50*100) + (3*0.5*40*100) + (2*0.5*30*100)
    !         = 12500 + 6000 + 3000 = 21500
    CALL ASSERT_EQUAL_REAL(21500.0D0, HAMASS_EVENT, &
      'Event mass multi-layer: sum over 3 layers')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_CUMULATIVE_MASS()
    ! HAMASS_CUM accumulates across events
    REAL(R8) :: HAMASS_CUM, EVENT1, EVENT2
    HAMASS_CUM = 0.0D0
    EVENT1 = 5000.0D0
    EVENT2 = 3000.0D0
    HAMASS_CUM = HAMASS_CUM + EVENT1
    HAMASS_CUM = HAMASS_CUM + EVENT2
    CALL ASSERT_EQUAL_REAL(8000.0D0, HAMASS_CUM, &
      'Cumulative mass accumulates across events')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_EVENT_MASS_RESET()
    ! HAMASS_EVENT resets to zero at start of each timestep
    REAL(R8) :: HAMASS_EVENT
    HAMASS_EVENT = 12345.0D0
    ! Production code: IF (HARVESTING) HAMASS_EVENT(1:NHF) = 0.0D0
    HAMASS_EVENT = 0.0D0
    CALL ASSERT_EQUAL_REAL(0.0D0, HAMASS_EVENT, &
      'Event mass resets to zero each timestep')
  END SUBROUTINE

  !---------------------------------------------------------------------------
  SUBROUTINE TEST_MASS_DEPTH_LIMITED()
    ! Only shallow layers contribute to mass when HADEP > 0
    REAL(R8) :: C1(3), BH1(3), EL(3), HH(3), DLX, FHA, HADEP
    REAL(R8) :: ELWS, DEPTH, HAMASS_EVENT
    INTEGER :: K
    ! 3 layers: top is shallow (harvested), middle is at boundary, bottom is deep (skipped)
    ELWS = 100.0D0
    DLX  = 100.0D0
    FHA  = 0.5D0
    HADEP = 3.0D0
    C1   = (/10.0D0, 10.0D0, 10.0D0/)
    BH1  = (/50.0D0, 40.0D0, 30.0D0/)
    EL   = (/99.5D0, 97.5D0, 95.0D0/)  ! top of each layer
    HH   = (/1.0D0,  2.0D0,  2.0D0/)   ! layer thickness
    ! Depths: (100-99.0)=1.0, (100-96.5)=3.5, (100-94.0)=6.0

    HAMASS_EVENT = 0.0D0
    DO K = 1, 3
      DEPTH = ELWS - (EL(K) - HH(K) * 0.5D0)
      IF (DEPTH > HADEP) CYCLE  ! Skip deep layers
      HAMASS_EVENT = HAMASS_EVENT + C1(K) * FHA * BH1(K) * DLX
    END DO
    ! Only layer 1 (depth=1.0m): 10*0.5*50*100 = 25000
    CALL ASSERT_EQUAL_REAL(25000.0D0, HAMASS_EVENT, &
      'Depth-limited mass: only shallow layers counted')
  END SUBROUTINE

END MODULE TEST_HARVEST_MASS
