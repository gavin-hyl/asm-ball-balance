;-------------------------------------------------------------------------------
; File:             timerdefs.inc
; Description:      This file contains definitions for clock prescaling
;
; Author:           Gavin Hua
; Revision History: 2024/05/16 - Initial revision
;                   2024/05/18 - Debug and test
;                   2024/06/01 - Remove extra definitions
;-------------------------------------------------------------------------------


.equ    TIMER_CLK_STOP    = 0b00000000	;stop the timer
.equ    TIMER_CLK_1       = 0b00000001	;timer runs at CLK
.equ    TIMER_CLK_8       = 0b00000010	;timer runs at CLK/8
.equ    TIMER_CLK_64      = 0b00000011	;timer runs at CLK/64
.equ    TIMER_CLK_255     = 0b00000100	;timer runs at CLK/256
.equ    TIMER_CLK_1024    = 0b00000101	;timer runs at CLK/1024
