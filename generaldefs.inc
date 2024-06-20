;-------------------------------------------------------------------------------
; File:             generaldef.inc
; Description:      This file contains general definitions and macros.
;
; Author:           Gavin Hua
; Revision History: 5/16/2024 - Initial revision
;                   6/01/2024 - Add general macros
;-------------------------------------------------------------------------------


.equ	TRUE		= 0b00000001    ; boolean true
.equ	FALSE   	= 0b00000000    ; boolean false
.equ    MOD_8       = 0b00000111    ; and with this constant to perform modulo 8

.equ    LOW_HEX_DIG         = 0x0F  ; mask for low nibble
.equ    HIGH_HEX_DIG        = 0xF0  ; mask for high nibble


; Macro: byteTabOffsetY
; Description:          This macro calculates the offset of a byte table and sets the Y
;                       register to the address of the table plus the offset.
; Operation:            Y = @0 + @1
; 
; Arguments:            @0 - the table address
;                       @1 - the offset
; Return Value:         Y register set to the address of the table plus the offset
;
; Global Variables:     YL, YH
; Shared Variables:     None.
; Local Variables:      zero register (r0)
;
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    Y.
;
; Author:               Gavin Hua
; Last Modified:        5/16/2024

.macro      byteTabOffsetY
    push    r0
    ldi     YL, low(@0)
    ldi     YH, high(@0)
    add     YL, @1
    clr     r0
    adc     YH, r0
    pop     r0
.endmacro



; Macro: wordTabOffsetZ
; Description:          This macro calculates the offset of a word table and 
;                       sets the Z register to the address of the table + offset.
; Operation:            Z = 2 * @0 + @1
;
; Arguments:            @0 - the table address
;                       @1 - the offset
; Return Value:         Z register set to the address of the table plus the offset
;
; Global Variables:     ZL, ZH
; Shared Variables:     None.
; Local Variables:      zero register (r0)
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    Z.
;
; Author:               Gavin Hua
; Last Modified:        5/16/2024

.macro      wordTabOffsetZ
    push r0
    ldi     ZL, low(2 * @0)
    ldi     ZH, high(2 * @0)
    add     ZL, @1
    clr     r0
    adc     ZH, r0
    pop r0
.endmacro