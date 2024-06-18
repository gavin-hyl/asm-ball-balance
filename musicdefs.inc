.macro PlaySequence
    clr     r0
    wordTabOffsetZ @0, r0
    lpm     r16, Z+
    lsl     r16
    clr     r17
    rol     r17
    rcall   PlayNote
    lpm     r16, Z
    sbiw    Z, 1
    in      r1, SREG
    cli
    sts     curr_sequence, ZL
    sts     curr_sequence+1, ZH
    sts     note_tick_cnt, r16
    ldi     r16, TRUE
    sts     playing_sequence, r16
    ldi     r16, 0
    sts     curr_note, r16
    out     SREG, r1
.endmacro
