.macro PlaySequence
    ldi     r16, low(@0 * 2)
    ldi     r17, high(@0 * 2)
    in      r0, SREG
    cli     
    sts     curr_sequence, r16
    sts     curr_sequence+1, r17
    out     SREG, r0
.endmacro