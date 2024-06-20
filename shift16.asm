Shift16Right:
    swap    r17
    mov     r18, r17
    swap    r16
    andi    r16, LOW_HEX_DIG
    andi    r18, HIGH_HEX_DIG
    add     r16, r18
    ret