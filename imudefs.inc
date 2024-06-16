;-------------------------------------------------------------------------------
; File:             imudefs.inc
; Description:      This file contains definitions for IMU setup and communication.
;
; Author:           Gavin Hua
; Revision History: 2024/06/01 - Initial revision
;-------------------------------------------------------------------------------

#ifndef IMUDEFS_INC ; include guard since test code also includes this file
#define IMUDEFS_INC

; IMU accelerometer register addresses
.equ IMU_AX_HIGH            = 59
.equ IMU_AX_LOW             = 60
.equ IMU_AY_HIGH            = 61
.equ IMU_AY_LOW             = 62
.equ IMU_AZ_HIGH            = 63
.equ IMU_AZ_LOW             = 64

; Patterns for reading and writing to the IMU
.equ IMU_READ               = 0x80  ; OR with register address to read
.equ IMU_READ_IGNORE        = 0xFF  ; second byte sent to IMU when reading

; IMU configuration registers
.equ IMU_GENERAL_CONFIG     = 26
.equ IMU_ACCEL_CONFIG0      = 28
.equ IMU_ACCEL_CONFIG1      = 29
.equ IMU_CONFIG_RESET       = 0x00


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
; Registers changed:    r16, r17
;
; Stack Depth:          0 bytes.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/01

.macro GetAccel
    ldi r16, @0
    rcall IMURead
    mov r17, r16
    ldi r16, @1
    rcall IMURead
.endm

#endif ; IMUDEFS_INC
