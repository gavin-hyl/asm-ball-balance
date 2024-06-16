;-------------------------------------------------------------------------------
; File:         div.asm
; Description:  This file contains a function for doing division of 16-bit
;               unsigned values.
; Public Functions: Div16    - divide 16-bit unsigned values
;
; Author:       Glen George
; Revision History:     4/16/18  Glen George      initial revision
;-------------------------------------------------------------------------------

.cseg


; div16
;
;
; Description:  This function divides the 16-bit unsigned value passed in
;               r17|r16 by the 16-bit unsigned value passed in r21|r20.
;               The quotient is returned in r17|r16 and the remainder is
;               returned in r3|r2.
;
; Operation:    The function divides r17|r16 by r21|r20 using a restoring
;               division algorithm with a 16-bit temporary register r3|r2
;               and shifting the quotient into r17|r16 as the dividend is
;               shifted out.  Note that the carry flag is the inverted
;               quotient bit (and this is what is shifted into the
;               quotient) so at the end the entire quotient is inverted.
;
; Arguments:        r17|r16 - 16-bit unsigned dividend.
;                   r21|r20 - 16-bit unsigned divisor.
; Return Values:    r17|r16 - 16-bit quotient.
;                   r3|r2   - 16-bit remainder.
;
; Local Variables:  bitcnt (r22) - number of bits left in division.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           None.
;
; Error Handling:   None.
;
; Registers Changed:    flags, r2, r3, r16, r17, r22
; Stack Depth:          0 bytes
;
; Algorithms:       Restoring division.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      None.
;
; Revision History:   4/15/18   Glen George      initial revision

Div16:
    ldi     r22, 16         ;number of bits to divide into
    clr     r3              ;clear temporary register (remainder)
    clr     r2

Div16loop:                  ;loop doing the division
    rol     r16             ;rotate bit into temp (and quotient
    rol     r17             ;   into r17|r16)
    rol     r2
    rol     r3
    cp      r2, r20         ;check if can subtract divisor
    cpc     r3, r21
    brcs    Div16SkipSub    ;cannot subtract, don't do it
    sub     r2, r20         ;otherwise subtract the divisor
    sbc     r3, r21
Div16SkipSub:               ;C = 0 if subtracted, C = 1 if not
    dec     r22             ;decrement loop counter
    brne    Div16loop           ;if not done, keep looping
    rol     r16             ;otherwise shift last quotient bit in
    rol     r17
    com     r16             ;and invert quotient (carry flag is
    com     r17             ;   inverse of quotient bit)
    ;rjmp   enddiv16        ;and done (remainder is in r3|r2)

EndDiv16:                   ;all done, just return
    ret



; Div16by8
;
;
; Description:       This function divides the 16-bit unsigned value passed in
;                    R17|R16 by the 8-bit unsigned value passed in r20.  The
;                    quotient is returned in R17|R16 and the remainder is
;                    returned in r2.
;
; Operation:         The function divides R17|R16 by r20 using a restoring
;                    division algorithm with an 8-bit temporary register r2
;                    and shifting the quotient into R17|R16 as the dividend is
;                    shifted out.  Note that the carry flag is the inverted
;                    quotient bit (and this is what is shifted into the
;                    quotient) so at the end the entire quotient is inverted.
;
; Arguments:         R17|R16 - 16-bit unsigned dividend.
;                    r20     - 8-bit unsigned divisor.
; Return Values:     R17|R16 - 16-bit quotient.
;                    r2      - 8-bit remainder.
;
; Local Variables:   bitcnt (r22) - number of bits left in division.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Registers Changed: flags, r2, R16, R17, r22
; Stack Depth:       0 bytes
;
; Algorithms:        Restoring division.
; Data Structures:   None.
;
; Known Bugs:        None.
; Limitations:       None.
;
; Revision History:   4/15/18   Glen George      initial revision

Div16by8:
    ldi     r22, 16                 ;number of bits to divide into
    clr     r2                      ;clear temporary register (remainder)

Div16by8Loop:                       ;loop doing the division
    rol     r16                     ;rotate bit into temp (and quotient
    rol     r17                     ;   into R17|R16)
    rol     r2
    cp      r2, r20                 ;check if can subtract divisor
    brcs    Div16by8SkipSub         ;cannot subtract, don't do it
    sub     r2, r20                 ;otherwise subtract the divisor

Div16by8SkipSub:                    ;C = 0 if subtracted, C = 1 if not
    dec     r22                     ;decrement loop counter
    brne    Div16by8Loop            ;if not done, keep looping
    rol     r16                     ;otherwise shift last quotient bit in
    rol     r17
    com     r16                     ;and invert quotient (carry flag is
    com     r17                     ;   inverse of quotient bit)
    ;rjmp   EndDiv16by8             ;and done (remainder is in r2)

EndDiv16by8:                        ;all done, just return
    ret