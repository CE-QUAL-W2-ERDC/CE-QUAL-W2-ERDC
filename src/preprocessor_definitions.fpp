      MODULE BUILDVERSION !
      ! Modified for gfortran compatibility - Intel-specific macros removed
      INTEGER :: INTEL_COMPILER_VERSION= 0  ! gfortran (not Intel)
      INTEGER :: INTEL_COMPILER_BUILD_DATE= 0  ! gfortran (not Intel)
      CHARACTER(20) :: compiler_build_date=__DATE__
      CHARACTER(20) :: COMPILER_BUILD_TIME=__TIME__
      CHARACTER(40) :: BUILDTIME=__DATE__//' '//__TIME__    ! V4.5 gfortran build
      END MODULE BUILDVERSION