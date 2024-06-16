.macro PlaySequence
    in      r17, SREG
    cli     
    ldi     r16, low(@0)
    sts     curr_sequence, r16
    ldi     r16, high(@0)
    sts     curr_sequence+1, r16
    out     SREG, r17
.endmacro