;-------------------------------------------------------------------------------
; File:             displaydefs.inc
; Description:      This file contains the definitions for the display routines.
;
; Author:           Gavin Hua
; Revision History: 5/16/2024 - Initial revision
;                   5/18/2024 - Debug and test
;-------------------------------------------------------------------------------


.equ    LOW_HEX_DIG         = 0x0F  ; mask for low nibble
.equ    HIGH_HEX_DIG        = 0xF0  ; mask for high nibble

.equ    DISP_BUFF_LEN       = 14    ; length of display buffer

.equ    LED_OFF             = 0x00  ; LED off pattern for GPIO port

.equ    DISP_ON_T_INIT      = 1     ; display on time (max 255)
.equ    DISP_OFF_T_INIT     = 0     ; display off time (max 255)

.equ    SEG_BUF_OFFSET      = 10    ; offset of 7-segment in the main buffer
.equ    MODE_BTN_IDX        = 71    ; index for mode button
.equ    START_BTN_IDX       = 72    ; index for start button

.equ    GAME_LED_IDX_MAX    = 70    ; maximum game LED index
.equ    LED_IDX_MAX         = 72    ; maximum game LED index
.equ    LED_IDX_MIN         = 0     ; minimum game LED index x >= 0