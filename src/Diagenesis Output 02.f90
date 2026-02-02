Module CEMAOutputRoutines
    Use MAIN 
    Use GLOBAL
    Use SCREENC
    Use GEOMC
    Use KINETIC
    USE NAMESC
    Use CEMAVars 
    USE CEMASedimentDiagenesis
    
    ! Type declarations
    IMPLICIT NONE

    Integer nGas
    
    contains
    !
    !
    Subroutine WriteCEMASedimentModelOutput
    
        !Bed Elevation
        If(WriteBESnp)Then
            Write(CEMASNPOutFilN,'("Bed elevation(m)")')
            Write(CEMASNPOutFilN,'("JDAY = ",f14.6)')JDAY
            DO SegNumI = 1, IMX
  WRITE(CEMASNPOutFilN,'(i10)', ADVANCE='NO') SegNumI
END DO
WRITE(CEMASNPOutFilN,'(A)') ''  ! End line
            DO SegNumI = 1, IMX
  WRITE(CEMASNPOutFilN,'(f10.4)', ADVANCE='NO') BedElevation(SegNumI)
END DO
WRITE(CEMASNPOutFilN,'(A)') ''  ! End line
            
            Write(CEMASNPOutFilN,'("Bed elevation layer(m)")')
            Write(CEMASNPOutFilN,'("JDAY = ",f14.6)')JDAY
            DO SegNumI = 1, IMX
  WRITE(CEMASNPOutFilN,'(i10)', ADVANCE='NO') SegNumI
END DO
WRITE(CEMASNPOutFilN,'(A)') ''  ! End line
            DO SegNumI = 1, IMX
  WRITE(CEMASNPOutFilN,'(f10.4)', ADVANCE='NO') BedElevationLayer(SegNumI)
END DO
WRITE(CEMASNPOutFilN,'(A)') ''  ! End line 
        End If
        
        !Bed porosity
        If(WritePWSnp)Then
            Write(CEMASNPOutFilN,'("Bed porosity (%)")')
            Write(CEMASNPOutFilN,'("JDAY = ",f8.2)')JDAY
            DO SegNumI = 1, IMX
  WRITE(CEMASNPOutFilN,'(i10)', ADVANCE='NO') SegNumI
END DO
WRITE(CEMASNPOutFilN,'(A)') ''  ! End line
            DO SegNumI = 1, IMX
  WRITE(CEMASNPOutFilN,'(f10.4)', ADVANCE='NO') BedPorosity(SegNumI)*100
END DO
WRITE(CEMASNPOutFilN,'(A)') ''  ! End line
            Write(CEMASNPOutFilN,'("Total Volume of Sediments = ",e14.6," m3")')TotalSedimentsInBed
            Write(CEMASNPOutFilN,'("Total Porewater Volume = ",e14.6," m3")')TotalPoreWatVolume
            Write(CEMASNPOutFilN,'("Total Porewater Removed = ",e14.6," m3")')TotalPoreWatRemoved
!            Write(CEMATSR1OutFilN,'(f14.6 , "," ,i5,",",i5, ",", f14.6, ",", f14.6, ",", f14.6, ",", f14.6, ",", f14.6, ",", f14.6, ",", f14.6, ",", f14.6)')JDAY, KTWB(1), KB(4), z(4), BedElevation(4), BedElevationLayer(4), PorewaterRelRate(4)*86400.d0, BedPorosity(4)*100, BedConsolidRate(4)*86400.d0, EL(KTWB(1),4)-Z(4), CEMACumPWRelease(4)
        End If
        
    End Subroutine
        
    Subroutine WriteCEMASedimentFluxOutput
        
        If(WriteCEMAMFTSedFlx)Then

            WRITE(CEMASedFlxFilN4,'(A,f12.4,A)', ADVANCE='NO') 'SOD(gO2m-2d-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN4,'(f10.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,4)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN4,'(f10.4,",")', ADVANCE='NO') KFSFAV(SegNumI,1)
            END DO
            WRITE(CEMASedFlxFilN4,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN5,'(A,f12.4,A)', ADVANCE='NO') 'POCG1(gm-3),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN5,'(f12.4,",")', ADVANCE='NO') C2SF(KBI(SegNumI),SegNumI,19)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN5,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,2)
            END DO
            WRITE(CEMASedFlxFilN5,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN6,'(A,f12.4,A)', ADVANCE='NO') 'POCG2(gm-3),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN6,'(f12.4,",")', ADVANCE='NO') C2SF(KBI(SegNumI),SegNumI,20)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN6,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,3)
            END DO
            WRITE(CEMASedFlxFilN6,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN7,'(A,f12.4,A)', ADVANCE='NO') 'JC(gCm-2d-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN7,'(f12.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,7)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN7,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,4)
            END DO
            WRITE(CEMASedFlxFilN7,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN8,'(A,f12.4,A)', ADVANCE='NO') 'JN(gNm-2d-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN8,'(f12.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,8)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN8,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,5)
            END DO
            WRITE(CEMASedFlxFilN8,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN9,'(A,f12.4,A)', ADVANCE='NO') 'PONG1(gm-3),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN9,'(f12.4,",")', ADVANCE='NO') C2SF(KBI(SegNumI),SegNumI,22)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN9,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,6)
            END DO
            WRITE(CEMASedFlxFilN9,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN10,'(A,f12.4,A)', ADVANCE='NO') 'PONG2(gm-3),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN10,'(f12.4,",")', ADVANCE='NO') C2SF(KBI(SegNumI),SegNumI,23)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN10,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,7)
            END DO
            WRITE(CEMASedFlxFilN10,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN11,'(A,f12.4,A)', ADVANCE='NO') 'JCH4(gO2m-2d-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN11,'(f12.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,10)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN11,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,8)
            END DO
            WRITE(CEMASedFlxFilN11,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN12,'(A,f12.4,A)', ADVANCE='NO') 'JNH4(gNm-2d-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN12,'(f12.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,14)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN12,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,9)
            END DO
            WRITE(CEMASedFlxFilN12,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN13,'(A,f12.4,A)', ADVANCE='NO') 'JNO3(gNm-2d-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN13,'(f12.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,15)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN13,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,10)
            END DO
            WRITE(CEMASedFlxFilN13,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN14,'(A,f12.4,A)', ADVANCE='NO') 'JPO4(gPm-2d-1), ,',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN14,'(f12.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,16)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN14,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,11)
            END DO
            WRITE(CEMASedFlxFilN14,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN15,'(A,f12.4,A)', ADVANCE='NO') 'POPG1(gm-3),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN15,'(f12.4,",")', ADVANCE='NO') C2SF(KBI(SegNumI),SegNumI,25)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN15,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,12)
            END DO
            WRITE(CEMASedFlxFilN15,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN16,'(A,f12.4,A)', ADVANCE='NO') 'POPG2(gm-3),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN16,'(f12.4,",")', ADVANCE='NO') C2SF(KBI(SegNumI),SegNumI,26)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN16,'(f12.4,",")', ADVANCE='NO') KFSFAV(SegNumI,13)
            END DO
            WRITE(CEMASedFlxFilN16,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN17,'(A,f12.4,A)', ADVANCE='NO') 'CSOD(gO2m-2d-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN17,'(f10.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,5)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN17,'(f10.4,",")', ADVANCE='NO') KFSFAV(SegNumI,14)
            END DO
            WRITE(CEMASedFlxFilN17,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN18,'(A,f12.4,A)', ADVANCE='NO') 'NSOD(gO2m-2d-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN18,'(f10.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,6)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN18,'(f10.4,",")', ADVANCE='NO') KFSFAV(SegNumI,15)
            END DO
            WRITE(CEMASedFlxFilN18,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN19,'(A,f12.4,A)', ADVANCE='NO') 'JP(gPm-2d-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN19,'(f10.4,",")', ADVANCE='NO') KFSF(KBI(SegNumI),SegNumI,9)
            END DO
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN19,'(f10.4,",")', ADVANCE='NO') KFSFAV(SegNumI,16)
            END DO
            WRITE(CEMASedFlxFilN19,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN21,'(A,f10.3,A)', ADVANCE='NO') 'Temperature_KB_Layer1(C),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN21,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN22,'(A,f10.3,A)', ADVANCE='NO') 'Temperature_KB_Layer2(C),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN22,'(A)') ''  ! End line
            
            WRITE(CEMASedFlxFilN23,'(A,f10.3,A)', ADVANCE='NO') 'NO3PorewaterAerobic_KB_Layer1(mgNL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN23,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN24,'(A,f10.3,A)', ADVANCE='NO') 'NO3PorewaterAnaerobic_KB_Layer2(mgNL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN24,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN25,'(A,f10.3,A)', ADVANCE='NO') 'NH3PorewaterAerobic_KB_Layer1(mgNL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN25,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN26,'(A,f10.3,A)', ADVANCE='NO') 'NH3PorewaterAnaerobic_KB_Layer2(mgNL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN26,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN27,'(A,f10.3,A)', ADVANCE='NO') 'PO4PorewaterAerobic_KB_Layer1(mgPL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN27,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN28,'(A,f10.3,A)', ADVANCE='NO') 'PO4PorewaterAnaerobic_KB_Layer2(mgPL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN28,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN29,'(A,f10.3,A)', ADVANCE='NO') 'SO4PorewaterAerobic_KB_Layer1(mgSL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN29,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN30,'(A,f10.3,A)', ADVANCE='NO') 'SO4PorewaterAnaerobic_KB_Layer2(mgSL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN30,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN31,'(A,f10.3,A)', ADVANCE='NO') 'FEIIPorewaterAerobic_KB_Layer1(mgFeL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN31,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN32,'(A,f10.3,A)', ADVANCE='NO') 'FEIIPorewaterAnaerobic_KB_Layer2(mgFeL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN32,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN33,'(A,f10.3,A)', ADVANCE='NO') 'MnIIPorewaterAerobic_KB_Layer1(mgMnL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN33,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN34,'(A,f10.3,A)', ADVANCE='NO') 'MnIIPorewaterAnaerobic_KB_Layer2(mgMnL-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN34,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN35,'(A,f10.3,A)', ADVANCE='NO') 'CH4PorewaterAerobic_KB_Layer1(mgO2L-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN35,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN36,'(A,f10.3,A)', ADVANCE='NO') 'CH4PorewaterAnaerobic_KB_Layer2(mgO2L-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN36,'(A)') ''  ! End line

            WRITE(CEMASedFlxFilN37,'(A,f10.3,A)', ADVANCE='NO') 'pHPorewaterAerobic_KB_Layer1,',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN37,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN38,'(A,f10.3,A)', ADVANCE='NO') 'pHPorewaterAnaerobic_KB_Layer2,',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN38,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN39,'(A,f10.3,A)', ADVANCE='NO') 'SulfidePorewaterAerobic_KB_Layer1(mgO2L-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN39,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN40,'(A,f10.3,A)', ADVANCE='NO') 'SulfidePorewaterAnaerobic_KB_Layer2(mgO2L-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN40,'(A)') ''  ! End line
            WRITE(CEMASedFlxFilN41,'(A,f10.3,A)', ADVANCE='NO') 'TransferVelocitySedimentLayer1_to_Water(md-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN41,'(A)') ''  ! End line
            !Write(CEMASedFlxFilN42,'("TransferVelocitySedimentLayer1_to_Layer2(md-1),",f10.3,",",A,",",<IMX>(f10.5,","),A,",",<IMX>(f10.5,","))')JDAY,'SD_KL12',(C2SF(KBI(SegNumI),SegNumI,39), SegNumI = 1, IMX),'SD_W12',(C2SF(KBI(SegNumI),SegNumI,40), SegNumI = 1, IMX)
            WRITE(CEMASedFlxFilN42,'(A,f10.3,A)', ADVANCE='NO') 'TransferVelocitySedimentLayer1_to_Layer2_KL12(md-1),',JDAY,','
            DO SegNumI = 1, IMX
            END DO
            WRITE(CEMASedFlxFilN42,'(A)') ''  ! End line
            ! Write header and JDAY
            WRITE(CEMASedFlxFilN43,'(A,f10.3,A)', ADVANCE='NO') 'TransferVelocitySedimentLayer1_to_Layer2_W12(md-1),',JDAY,','
            DO SegNumI = 1, IMX
              WRITE(CEMASedFlxFilN43,'(f10.5,",")', ADVANCE='NO') C2SF(KBI(SegNumI),SegNumI,40)
            END DO
            WRITE(CEMASedFlxFilN43,'(A)') ''  ! End line
            IF(Bubbles_Calculation) Call CEMATempOutput
	        
        End If
    
    End Subroutine
        
    Subroutine CEMATempOutput
        !
        Implicit none
        Character(3) CrackStatus(IMX)
        !
        CrackStatus = " NO"
        Do SegNumI = 1, IMX
            If(CrackOpen(SegNumI))CrackStatus(SegNumI) = "YES"
        End Do !SegNumI
        
        DO SegNumI=1,IMX
            Write(CEMAOutFilN1,'(f12.4,",",i5,",",4(f12.4,","),a10,",")')JDAY,SegNumI,BubbleRadiusSed(SegNumI)*1000,CgSed(SegNumI),C0Sed(SegNumI),CtSed(SegNumI),CrackStatus(SegNumI)
        ENDDO
        
        !End Do !nGas
        DO SegNumI=1,IMX
            ! Write JDAY and SegNumI
            WRITE(CEMAOutFilN2,'(f12.4,",",i5,",")', ADVANCE='NO') JDAY,SegNumI
            ! Write TConc for nGas = 1 to 4
            DO nGas = 1, 4
              WRITE(CEMAOutFilN2,'(f12.4,",")', ADVANCE='NO') TConc(nGas,KB(SegNumI),SegNumI)
            END DO
            WRITE(CEMAOutFilN2,'(A)') ''  ! End line
        ENDDO
        
        
        !nGas=2 ! CH4 write
        !!Write(CEMASedFlxFilN8,'(f8.2,<IMX>f10.2)')JDAY,(TConc(nGas,SegNumI), SegNumI = 1, IMX)
        ! Commented out - incomplete code section
        !nGas=1 ! H2S write
        !!Write(CEMASedFlxFilN9,'(f8.2,<IMX>f10.2)')JDAY,(TConc(nGas,SegNumI), SegNumI = 1, IMX)
        ! Commented out - incomplete code section

        ! Commented out - incomplete code section:
        !Do nGas = 1, 4
        !    If(nGas == 1)Write(CEMAOutFilN6,'("H2S Concentration (gm/m�")')
        !    If(nGas == 2)Write(CEMAOutFilN6,'("CH4  Concentration (gm/m�")')
        !    If(nGas == 3)Write(CEMAOutFilN6,'("NH3  Concentration (gm/m�")')
        !    If(nGas == 4)Write(CEMAOutFilN6,'("CO2  Concentration (gm/m�")')
        !    DO SegNumI = 1, IMX
        !      WRITE(CEMAOutFilN6,'(f10.3)', ADVANCE='NO') DissolvedGasSediments(nGas,SegNumI)
        !    END DO
        !    WRITE(CEMAOutFilN6,'(A)') ''  ! End line
        !End Do !nGas
        DO SegNumI=1,IMX
            ! Write JDAY and SegNumI
            WRITE(CEMAOutFilN4,'(f12.4,",",i5,",")', ADVANCE='NO') JDAY,SegNumI
            ! Write DissolvedGasSediments for nGas = 1 to 4
            DO nGas = 1, 4
              WRITE(CEMAOutFilN4,'(f12.4,",")', ADVANCE='NO') DissolvedGasSediments(nGas,KB(SegNumI),SegNumI)
            END DO
            WRITE(CEMAOutFilN4,'(A)') ''  ! End line
        ENDDO
        
        ! Commented out - incomplete code section:
        !Write(CEMAOutFilN3,'("Gas Release to Atmosphere at JDAY = ",f8.2)')JDAY
        !DO SegNumI = 1, IMX
        !  WRITE(CEMAOutFilN3,'(i10)', ADVANCE='NO') SegNumI
        !END DO
        !WRITE(CEMAOutFilN3,'(A)') ''  ! End line
        !Do nGas = 1, 4
        !    If(nGas == 1)Write(CEMAOutFilN3,'("H2S Release(gm/s)")')
        !    If(nGas == 2)Write(CEMAOutFilN3,'("CH4 Release (gm/s)")')
        !    If(nGas == 3)Write(CEMAOutFilN3,'("NH3 Release (gm/s)")')
        !    If(nGas == 4)Write(CEMAOutFilN3,'("CO2 Release (gm/s)")')
        !    DO SegNumI = 1, IMX
        !      WRITE(CEMAOutFilN3,'(f10.3)', ADVANCE='NO') BRRateAGasNet(SegNumI, nGas)
        !    END DO
        !    WRITE(CEMAOutFilN3,'(A)') ''  ! End line
        !End Do !nGas
        DO SegNumI=1,IMX
            ! Write JDAY and SegNumI
            WRITE(CEMAOutFilN3,'(f12.4,",",i5,",")', ADVANCE='NO') JDAY,SegNumI
            ! Write BRRateAGasNet for nGas = 1 to 4
            DO nGas = 1, 4
              WRITE(CEMAOutFilN3,'(f12.4,",")', ADVANCE='NO') BRRateAGasNet(SegNumI, nGas)
            END DO
            WRITE(CEMAOutFilN3,'(A)') ''  ! End line
        ENDDO
        
        DO JW=1,NWB
        Write(CEMAOutFilBub,'(F12.4,",",I5,",",6(E12.5,","))')JDAY,JW,(BubbleRelWB(JW,J),J=1,4), GasReleaseCH4/1000.   !,GasReleaseCO2/1000.   ! SW 7/1/2017 BubbleRelWB kg  GasReleaseCH4 kg C
        END DO
        
        !Write(CEMAOutFilN4,'(<5>f10.3)')JDAY,(BRRateAGasNet(5, nGas), nGas = 1, 4)
        !Write(227,'(f10.5, ",",f10.5)')jday, c1(kb(6),6,7)/1000.d0
        
    End Subroutine
        
End Module CEMAOutputRoutines
