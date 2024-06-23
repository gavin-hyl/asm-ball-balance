;-------------------------------------------------------------------------------
; generaldefs.inc
;
; Description:
;   This file contains general definitions and macros.
;
; Macros:
;   byteTabOffsetY - point Y to a byte table with an offset
;   wordTabOffsetZ - point Z to a word table with an offset
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/05/16 - Initial revision
;   2024/06/01 - Add general macros
;   2024/06/19 - Update comments
;-------------------------------------------------------------------------------



.equ	TRUE		    = 0b00000001    ; boolean true
.equ	FALSE   	    = 0b00000000    ; boolean false
.equ    MOD_8           = 0b00000111    ; andi MOD_8 to perform modulo 8

.equ    LOW_HEX_DIG     = 0x0F  ; mask for low nibble
.equ    HIGH_HEX_DIG    = 0xF0  ; mask for high nibble



;-------------------------------------------------------------------------------
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
; Local Variables:      zero (r1) - used to propagate carry in 16-bit addition.
;                       tmp (r0) - used to save SREG.
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
; Last Modified:        2024/06/19

.macro      byteTabOffsetY
    push    r0              ; push r0 to to prepare for SREG save
    in      r0, SREG        ; save SREG
    push    r0
    push    r1              ; push r1 to prepare for clearing

    ldi     YL, low(@0)     ; load YL with the low byte of the table address
    ldi     YH, high(@0)    ; load YH with the high byte of the table address
    add     YL, @1          ; add the offset to YL
    clr     r1              ; clear r1 to propagate carry
    adc     YH, r1          ; add the carry to YH

    pop     r1              ; restore r1
    pop     r0              ; restore SREG
    out     SREG, r0
    pop     r0              ; restore r0
.endmacro



;-------------------------------------------------------------------------------
; Macro: wordTabOffsetZ
; Description:          This macro calculates the offset of a word table and 
;                       sets the Z register to the address of the table+offset.
; Operation:            Z = 2 * @0 + @1
;
; Arguments:            @0 - the table address
;                       @1 - the offset
; Return Value:         Z register set to the address of the table + offset
;
; Global Variables:     ZL, ZH
; Shared Variables:     None.
; Local Variables:      zero (r1) - used to propagate carry in 16-bit addition.
;                       tmp (r0) - used to save SREG.
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
; Last Modified:        2024/06/19

.macro      wordTabOffsetZ
    push    r0                  ; push r0 to to prepare for SREG save
    in      r0, SREG            ; save SREG
    push    r0
    push    r1                  ; push r1 to prepare for clearing

    ldi     ZL, low(2 * @0)     ; load ZL with the low byte of the table address
                                ; we multiply by 2 because the table address is
                                ; a word address, while LPM takes byte addresses
    ldi     ZH, high(2 * @0)    ; load ZH with the high byte of the table address
    add     ZL, @1              ; add the offset to ZL
    clr     r1                  ; clear r1 to propagate carry
    adc     ZH, r1              ; add the carry to ZH
    
    pop     r1                  ; restore r1
    pop     r0                  ; restore SREG
    out     SREG, r0
    pop     r0                  ; restore r0
.endmacro