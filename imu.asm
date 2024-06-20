;-------------------------------------------------------------------------------
; imu.asm
; Description:
;   This file contains the functions to interface with the IMU.
;
; Public Functions:
;   IMUInit - initializes the IMU
;   GetAccelX - gets the x-axis acceleration
;   GetAccelY - gets the y-axis acceleration
;   GetAccelZ - gets the z-axis acceleration
;
; Local Functions:
;   IMURead - reads a register from the IMU
;   IMUWrite - writes to a register of the IMU
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/06/01 - iniital revision
;   2024/06/19 - add comments
;-------------------------------------------------------------------------------



.cseg

; IMUInit
; 
; Description:          Initializes the config registers in the MPU6500.
; Operation:            This function writes 0x00 to the general config and
;                       accelerometer config registers of the MPU6500.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      None
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17
;
; Author:               Gavin Hua
; Last Modified:        6/01/2024

InitIMU:
    ldi     r17, IMU_CONFIG_RESET   ; the same reset value for all three
    ldi     r16, IMU_GENERAL_CONFIG ; reset the general config register
    rcall   IMUWrite                ; write reset valiue to the register
    ldi     r16, IMU_ACCEL_CONFIG0  ; reset the accelerometer config register 0
    rcall   IMUWrite                ; write reset valiue to the register
    ldi     r16, IMU_ACCEL_CONFIG1  ; reset the accelerometer config register 1
    rcall   IMUWrite                ; write reset valiue to the register
    ret                             ; all done, return



;-------------------------------------------------------------------------------
; GetAccelX
; 
; Description:          Reads the x-axis accelerometer value (16-bit signed).
; Operation:            This function applies the GetAccel macro to the x-axis
;                       accelerometer registers of the MPU6500. 
; 
; Arguments:            None.
; Return Value:         r17|r16 - a 16-bit fixed-point value (Q1.14, +/- 2 g's)
;                       representing the x-axis acceleration.
; 
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      None
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

GetAccelX:
    GetAccel    IMU_AX_HIGH, IMU_AX_LOW
    ret



;-------------------------------------------------------------------------------
; GetAccelY
; 
; Description:          Reads the y-axis accelerometer value (16-bit signed).
; Operation:            This function applies the GetAccel macro to the xy-axis
;                       accelerometer registers of the MPU6500. 
; 
; Arguments:            None.
; Return Value:         r17|r16 - a 16-bit fixed-point value (Q1.14, +/- 2 g's)
;                       representing the y-axis acceleration.
; 
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      None
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

GetAccelY:
    GetAccel    IMU_AY_HIGH, IMU_AY_LOW
    ret


; GetAccelX
; 
; Description:          Reads the z-axis accelerometer value (16-bit signed).
; Operation:            This function applies the GetAccel macro to the z-axis
;                       accelerometer registers of the MPU6500. 
; 
; Arguments:            None.
; Return Value:         r17|r16 - a 16-bit fixed-point value (Q1.14, +/- 2 g's)
;                       representing the z-axis acceleration.
; 
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      None
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

GetAccelZ:
    GetAccel    IMU_AZ_HIGH, IMU_AZ_LOW
    ret



;-------------------------------------------------------------------------------
; IMURead
;
; Description:          Reads a register from the IMU.
; Operation:            This function reads a register from the IMU by pulling
;                       the SS pin low, sending the register address with the
;                       read bit set, and then reading the data from the IMU.
;                       The second byte sent is ignored by the IMU. The SS pin
;                       is then pulled high to end the transmission.
;
; Arguments:            r16 - the address of the register to read.
; Return Value:         r16 - the data read from the register.
;
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      None.
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, SREG
; Stack Depth:          0
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

IMURead:
    ori     r16, IMU_READ           ; set the read bit
    cbi     SPI_PORT, SPI_SS_PIN    ; SS low, start transmission
    rcall   SPITxRx                 ; send the register address
    ldi     r16, IMU_READ_IGNORE    ; load a dummy byte to read the data
    rcall   SPITxRx                 ; send the dummy byte
    sbi     SPI_PORT, SPI_SS_PIN    ; SS high, end transmission
    ret                             ; return with the data in r16



;-------------------------------------------------------------------------------
; IMURead
;
; Description:          Writes a register of the IMU.
; Operation:            This function writes a register of the IMU by pulling
;                       the SS pin low, sending the register address with the
;                       read bit cleared, and then sending the byte to write to
;                       the IMU. SS is then pulled high to end the transmission.
;
; Arguments:            r16 - the address of the register to write to.
;                       r17 - the data to write to the register.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      None.
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

IMUWrite:
    andi    r16, ~IMU_READ          ; clear the read bit (write operation)
    cbi     SPI_PORT, SPI_SS_PIN    ; SS low, start transmission
    rcall   SPITxRx                 ; send the register address
    mov     r16, r17                ; prepare the SPITxRx call
    rcall   SPITxRx                 ; send the data to write
    sbi     SPI_PORT, SPI_SS_PIN    ; SS high, end transmission
    ret                             ; all done, return
