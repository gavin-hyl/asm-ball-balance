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



;***************************************************************************
;*
;* "div8s" - 8/8 Bit Signed Division
;*
;* This subroutine divides the two register variables "dd8s" (dividend) and 
;* "dv8s" (divisor). The result is placed in "dres8s" and the remainder in
;* "drem8s".
;*  
;* Number of words	:22
;* Number of cycles	:103
;* Low registers used	:2 (d8s,drem8s)
;* High registers used  :3 (dres8s/dd8s,dv8s,dcnt8s)
;*
;***************************************************************************

;***** Subroutine Register Variables

.def	d8s	=r14		;sign register
.def	drem8s	=r15		;remainder
.def	dres8s	=r16		;result
.def	dd8s	=r16		;dividend
.def	dv8s	=r17		;divisor
.def	dcnt8s	=r18		;loop counter

;***** Code

div8s:	mov	d8s,dd8s	;move dividend to sign register
	eor	d8s,dv8s	;xor sign with divisor
	sbrc	dv8s,7		;if MSB of divisor set
	neg	dv8s		;    change sign of divisor
	sbrc	dd8s,7		;if MSB of dividend set
	neg	dd8s		;    change sign of divisor
	sub	drem8s,drem8s	;clear remainder and carry
	ldi	dcnt8s,9	;init loop counter
d8s_1:	rol	dd8s		;shift left dividend
	dec	dcnt8s		;decrement counter
	brne	d8s_2		;if done
	sbrc	d8s,7		;    if MSB of sign register set
	neg	dres8s		;        change sign of result
	ret			;    return
d8s_2:	rol	drem8s		;shift dividend into remainder
	sub	drem8s,dv8s	;remainder = remainder - divisor
	brcc	d8s_3		;if result negative
	add	drem8s,dv8s	;    restore remainder
	clc			;    clear carry to be shifted into result			
	rjmp	d8s_1		;else
d8s_3:	sec			;    set carry to be shifted into result
	rjmp	d8s_1