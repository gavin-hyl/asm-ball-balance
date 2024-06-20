;-------------------------------------------------------------------------------
; File:             sounddefs.inc
; Description:      This file contains definitions for sound generation
;
; Author:           Gavin Hua
; Revision History: 2024/06/01 - Initial revision
;-------------------------------------------------------------------------------


; frequency that the speaker will be turned off
.equ FREQ_OFF   = 0x00

; Timer 1 frequency for division = 8 MHz / 64(prescaler) / 2 = 62.5 kHz
.equ FREQ_DIV   = 62500