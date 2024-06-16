.dseg
lfsr:  .byte 2

;-------------------------------------------------------------------------------
.cseg


InitRandom:
    ldi     r16, low(LFSR_SEED)
    sts     lfsr, r16
    ldi     r16, high(LFSR_SEED)
    sts     lfsr+1, r16

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