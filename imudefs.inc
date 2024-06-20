;-------------------------------------------------------------------------------
; imudefs.inc
;
; Description:
;   This file contains definitions for IMU setup and communication.
;
; Macros:
;   GetAccel - read accelerometer data from the IMU and store it in r17|r16
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/06/01 - initial revision
;   2024/06/19 - update comments
;-------------------------------------------------------------------------------

#ifndef IMUDEFS_INC ; include guard since test code also includes this file
#define IMUDEFS_INC

; IMU accelerometer register addresses
.equ IMU_AX_HIGH            = 59    ; x-axis accelerometer high byte
.equ IMU_AX_LOW             = 60    ; x-axis accelerometer low byte
.equ IMU_AY_HIGH            = 61    ; y-axis accelerometer high byte
.equ IMU_AY_LOW             = 62    ; y-axis accelerometer low byte
.equ IMU_AZ_HIGH            = 63    ; z-axis accelerometer high byte
.equ IMU_AZ_LOW             = 64    ; z-axis accelerometer low byte

; Patterns for reading and writing to the IMU
.equ IMU_READ               = 0x80  ; OR with register address to read
.equ IMU_READ_IGNORE        = 0xFF  ; second byte sent to IMU when reading

; IMU configuration registers
.equ IMU_GENERAL_CONFIG     = 26    ; general configuration register
.equ IMU_ACCEL_CONFIG0      = 28    ; accelerometer configuration register 0
.equ IMU_ACCEL_CONFIG1      = 29    ; accelerometer configuration register 1
.equ IMU_CONFIG_RESET       = 0x00  ; configuration reset value (same as default)



;-------------------------------------------------------------------------------
; Macro: GetAccel
; Description:          This macro reads the accelerometer data from the IMU and
;                       stores it in r17|r16.
; Operation:            Reads the high byte of the accelerometer data into r17,
;                       then reads the low byte into r16.
; 
; Arguments:            @0 - the register address of the high byte
;                       @1 - the register address of the low byte
; Return Value:         r17|r16 - the accelerometer data, fixed point from -2 to
;                       2 g. 
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
; Registers changed:    r16, r17, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/01

.macro GetAccel
    ldi r16, @0     ; prepare to read high byte
    rcall IMURead   ; read high byte into r16
    mov r17, r16    ; move high byte to r17 because r16 will be overwritten
    ldi r16, @1     ; prepare to read low byte
    rcall IMURead   ; read low byte into r16
.endm

#endif ; IMUDEFS_INC
