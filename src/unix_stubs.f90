!***********************************************************************************************************************************
!**                                     Platform Stub Subroutines                                                                **
!**                                                                                                                                   **
!**  This file contains implementations of Intel Fortran specific functions for gfortran compatibility.                             **
!**  Works on all gfortran platforms: Windows (MinGW), macOS, and Linux.                                                           **
!**                                                                                                                                   **
!**  Created: November 2025 for gfortran compatibility                                                                               **
!**  Updated: February 2026 for cross-platform Windows/Unix support                                                                 **
!***********************************************************************************************************************************

SUBROUTINE SLEEPQQ(MILLISECONDS)
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: MILLISECONDS
  INTEGER :: SECONDS
  ! Replacement for Intel's SLEEPQQ function
  ! gfortran's SLEEP() intrinsic takes integer seconds, works on all platforms
  SECONDS = MILLISECONDS / 1000
  IF (SECONDS > 0) CALL SLEEP(SECONDS)
END SUBROUTINE SLEEPQQ

