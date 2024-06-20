;-------------------------------------------------------------------------------
; random.asm
;
; Description:
;   This file contains functions for pseudo-random number generator.
;
; Public Functions:
;   InitRandom - initialize the LFSR with the seed value (0x01FF)
;   Random - generate a pseudo-random number using the LFSR
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/06/17 - initial revision
;   2024/06/19 - update comments
;-------------------------------------------------------------------------------



.dseg
lfsr:  .byte 2  ; two bytes are needed for a 9-bit LFSR

;-------------------------------------------------------------------------------
.cseg

; InitRandom
;
; Description:          This function initializes the LFSR with the seed value 
;                       (0x01FF).
; Operation:            This function loads the seed value into the LFSR.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None. 
; Shared Variables:     lfsr - set to the seed value (0x01FF)
; Local Variables:      tmp (r16) - used to load variables
;
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r16
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

InitRandom:
    ldi     r16, low(LFSR_SEED)
    sts     lfsr, r16
    ldi     r16, high(LFSR_SEED)
    sts     lfsr+1, r16



;-------------------------------------------------------------------------------
; Random
;
; Description:          This function generates a pseudo-random number using the
;                       LFSR.
; Operation:            This function generates a pseudo-random number using the
;                       LFSR using the maximum length Fibonacci LFSR algorithm.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     lfsr - updated with the next LFSR value
; Local Variables:      None.
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           Maximum length Fibonacci LFSR algorithm.
; Data Structures:      None.
;
; Registers changed:    r16, r17, r18, r19
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17
Random:
    lds     r16, lfsr
    lds     r17, lfsr+1
    mov     r18, r16
    swap    r18
    andi    r18, 0x01
    mov     r19, r17
    andi    r19, 0x01
    eor     r18, r19
    andi    r18, 0x01  ; r18 is the feedback bit
    lsl     r16
    or      r16, r18
    rol     r17
    andi    r17, 0x01
    sts     lfsr, r16
    sts     lfsr+1, r17
    ret