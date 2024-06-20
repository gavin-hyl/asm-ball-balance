;-------------------------------------------------------------------------------
; displaydefs.inc
;
; Description:
;   This file contains the definitions for the display routines.
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/05/16 - Initial revision
;   2024/05/18 - Debug and test
;   2024/06/19 - Update comments and add LED_MASK_INIT
;-------------------------------------------------------------------------------



.equ    LOW_HEX_DIG         = 0x0F  ; mask for low nibble
.equ    HIGH_HEX_DIG        = 0xF0  ; mask for high nibble

.equ    DISP_BUF_LEN        = 14    ; length of display buffer
.equ    SEG_BUF_OFFSET      = 10    ; position of 7seg buffer in the main buffer
.equ    SEG_BUF_LEN         = 4     ; length of the 7-segment buffer

.equ    LED_OFF             = 0x00  ; LED off pattern for sink/source ports

.equ    DISP_ON_T_INIT      = 1     ; initial display on time (max 255)
.equ    DISP_OFF_T_INIT     = 0     ; initial display off time (max 255)

.equ    MODE_BTN_IDX        = 71    ; index for mode button
.equ    START_BTN_IDX       = 72    ; index for start button

.equ    GAME_LED_IDX_MAX    = 70    ; maximum game LED index
.equ    LED_IDX_MAX         = 72    ; maximum game LED index
.equ    LED_IDX_MIN         = 0     ; minimum game LED index x >= 0

.equ    LED_MASK_INIT       = 0b10000000    ; initial mask for the source port
                                            ; in displaying gameLEDs