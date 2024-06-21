;-------------------------------------------------------------------------------
; shift16.asm
;
; Description:
;   This file contains a function that shifts r17|r16 right by 4 bits.
;
; Public Functions:
;   Shift16Right - shifts r17|r16 right by 4 bits.
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/06/19 - initial revision
;-------------------------------------------------------------------------------



; Shift16Right
; 
; Description:          This function shifts r17|r16 right by 4 bits.
; Operation:            The function swaps the high and low nibbles of r17 and
;                       r16, then masks the low nibble of r16 and the high nibble
;                       of r17. The two nibbles are then added together to form
;                       the final result. See extra credit response.
;
; Arguments:            r17|r16 - the 16-bit value to be shifted right by 4 bits
; Return Value:         r17|r16 - the 16-bit value shifted right by 4 bits
;
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      tmp (r18) - temporary storage for the low nibble of r17
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, r18
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

Shift16Right:
    swap    r17                 ; let r17|r16 = ABCD. r17=BA
    mov     r18, r17            ; r18=BA
    swap    r16                 ; r16=DC
    andi    r16, LOW_HEX_DIG    ; r16=0C
    andi    r18, HIGH_HEX_DIG   ; r18=B0
    add     r16, r18            ; r16=BC
    ret                         ; r17|r16 = BABC