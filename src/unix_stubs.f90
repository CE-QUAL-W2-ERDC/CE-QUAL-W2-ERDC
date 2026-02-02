!***********************************************************************************************************************************
!**                                        Unix/MacOS Stub Subroutines                                                            **
!**                                                                                                                                   **
!**  This file contains stub implementations of Intel Fortran specific functions that don't exist in gfortran.                      **
!**                                                                                                                                   **
!**  Created: November 2025 for gfortran compatibility                                                                               **
!***********************************************************************************************************************************

SUBROUTINE SLEEPQQ(MILLISECONDS)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: MILLISECONDS
  ! Stub for Intel's SLEEPQQ function
  ! Could implement with CALL SLEEP(MILLISECONDS/1000) if needed
  RETURN
END SUBROUTINE SLEEPQQ

