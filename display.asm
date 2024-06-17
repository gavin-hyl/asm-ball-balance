;-------------------------------------------------------------------------------
; File:             display.asm
; Description:      this file contains the display routines for the 7-segment and
;                   the game LED display.
; Public Functions: DisplayInit - initializes the display
;                   ClearDisplay - clears the display
;                   DisplayMux - writes the values in the buffers to the display
;                   DisplayHex - displays a hexadecimal number to the 7-segment LED
;                   DisplayGameLED - controls the status of an individual LED
;
; Author:           Gavin Hua
; Revision History: 5/18/2024 - Initial revision
;                   5/18/2024 - Debug and test
;                   2024/06/12 - Update DisplayGameLED to not handle mode and
;                                start buttons, and created specialized routines
;                                for them.


;-------------------------------------------------------------------------------
.cseg


MessageTable:
    .db TIMED,          0x00
    .equ PADDING_SIZE = 2 * (PC - MessageTable)
    .db "tirn"
    .equ MESSAGE_ENTRY_SIZE = 2 * (PC - MessageTable)
    .equ MSG_LENGTH = MESSAGE_ENTRY_SIZE - PADDING_SIZE
    .db INFINITE,       0x00,   "EuEr"
    .db GRAVITY,        0x00,   "GrAu"
    .db F_INVIS,        0x00,   "Inui"
    .db BOUND,          0x00,   "EDGE"
    .db RANDOM_V,       0x00,   "rAnd"
    .db TIME_LIM,       0x00,   " Gt="
    .db SIZE,           0x00,   "BALL"
    .db LOSE,           0x00,   "LOSE"
    .db WIN,            0x00,   " =) "
    .equ MESSAGE_ENTRIES = (PC - MessageTable) / (MESSAGE_ENTRY_SIZE / 2)
    .db 0x00,           0x00,   " Err"

;-------------------------------------------------------------------------------

.dseg

curr_c_patterns:        .byte       DISP_BUFF_LEN
curr_dig:               .byte       1
curr_dig_pattern:       .byte       1
curr_msg:               .byte       MSG_LENGTH
blink_dim_cnt:          .byte       1
display_on_t:           .byte       1
display_off_t:          .byte       1

; DisplayInit
; Description:          This procedure initializes the variables for the 
;                       display. It clears all the digits and the game LEDs.
;                       Also initializes the parallel IO register for
;					    the display multiplexer.
; Operation:            This procedure clears the current digit and the blink/dim
;                       counter. It then sets the current digit pattern to LED_OFF
;                       and calls ClearDisplay to clear the display.
;                       It will also set port A,C,D to be all ouotputs.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_c_patterns   - a table of port C patterns
;                       curr_dig             - current digit to display
;                       curr_dig_pattern      - current digit pattern to display
;                       blink_dim_cnt         - for blinking/dimming the display
; Local Variables:      LED_OFF holder (r16)
;                       zero holder (r1)
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r1, r16
; Stack Depth:          0
;
; Author:               Gavin Hua
; Last Modified:        5/18/2024
.cseg
InitDisplay:
    clr     r1
    sts     curr_dig, r1
    sts     blink_dim_cnt, r1
    ldi     r16, LED_OFF
    sts     curr_dig_pattern, r16
    ldi     r16, DISP_ON_T_INIT
    sts     display_on_t, r16
    ldi     r16, DISP_OFF_T_INIT
    sts     display_off_t, r16
    rcall   ClearDisplay
    ret


; ClearDisplay
; Description:          This procedure clears the display.
; Operation:            This procedure will set all the currDigPatterns to the 
;                       blank digit pattern.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_c_patterns     - a table of current digit patterns
; Local Variables:      loop counter (r16)
;                       LED_OFF holder (r17)
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
; Registers Used:       r16, r17, Y
; Stack Depth:          0
;
; Author:               Gavin Hua
; Last Modified:        5/18/2024

ClearDisplay:
    ldi     r16, DISP_BUFF_LEN
    byteTabOffsetY  curr_c_patterns, r16
    ldi     r17, LED_OFF

ClearDisplayLoop:
    st      -Y, r17
    dec     r16
    brne    ClearDisplayLoop
    ; breq  ClearDisplayEnd

ClearDisplayEnd:
    ret



; DisplayMux
; Description:          This procedure writes the values in the buffers to the
;                       display and game LEDs. It expects to be called by the
;                       timer interrupt at a regular interval.
; Operation:            This procedure will write a output pattern to the GPIO,
;                       corresponding to a digit or game LED block. It will then
;                       increment/wrap the current digit and the blink/dim
;                       counter.
;
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_c_patterns   - a table of port C patterns
;                       curr_dig             - current digit to display
;                       curr_dig_pattern      - current digit pattern to display
;                       blink_dim_cnt         - for blinking/dimming the display
; Local Variables:      LED_OFF (r16)       - turns off a port
;                       blink_dim_cnt (r16)   - counter for blinking/dimming
;                       curr_dig (r17)       - current digit to display
;                       portPattern (r18)   - current port pattern
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, r18, Y, Z
; Stack Depth:          0
;
; Author:               Gavin Hua
; Last Modified:        5/18/2024

DisplayMux:

    ldi     r16, LED_OFF
    out     PORTA, r16
    out     PORTD, r16

    lds     r16, blink_dim_cnt
    lds     r17, display_on_t
    cp      r16, r17
    brsh    IncDimCnt
    brlo    DisplayDigit

DisplayDigit:
    lds     r17, curr_dig

    byteTabOffsetY  curr_c_patterns, r17
    ld      r18, Y
    out     PORTC, r18

    wordTabOffsetZ  PortAPatterns, r17
    lpm     r18, Z
    out     PORTA, r18

    wordTabOffsetZ  PortDPatterns, r17
    lpm     r18, Z
    out     PORTD, r18
    ; rjmp  IncCurrDig

IncCurrDig:
    inc     r17
    cpi     r17, DISP_BUFF_LEN
    brne    StoreCurrDig
    ; breq  WrapBuffer

WrapBuffer:
    clr r17
    ; rjmp  StoreCurrDig

StoreCurrDig:
    sts     curr_dig, r17
	; rjmp  IncDimCnt

IncDimCnt:
    inc     r16
    lds     r17, display_on_t
    lds     r18, display_off_t
    add     r17, r18
    cp      r16, r17
    brne    StoreDimCnt

WrapDimCnt:
    clr     r16
    ; rjmp  storeDimCnt

StoreDimCnt:
    sts     blink_dim_cnt, r16
    ; rjmp  DisplayMuxEnd

DisplayMuxEnd:
    ret



; DisplayHex
; Description:          This procedure displays a hexadecimal number (n) to the 
;                       7-segment LED display.
; Operation:            The procedure will set the currentDigitPatterns to the 
;                       corresponding digit pattern for each digit of the number.
; 
; Arguments:            n is passed in r17|r16 by value; it is preserved.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_c_patterns   - a table of port C patterns
; Local Variables:      n (r17|r16)
;                       temp digit holder (r18)
;                       loop counter (r19)
;                       temp pattern holder (r20)
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       If fewer than 4 digits are provided, the proedure will
;                       display display the number in the registers regardless,
;                       which is not guaranteed a default value.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, r18, r19, r20,Y, Z
; Stack Depth:          0
;
; Author:               Gavin Hua
; Last Modified:        5/18/2024

DisplayHex:
    ldi     r19, SEG_BUF_OFFSET
    mov     r18, r16
    andi    r18, LOW_HEX_DIG        ; low digit of r16
    rcall   LoadHexDigit

    inc     r19
    mov     r18, r16
    swap    r18
    andi    r18, LOW_HEX_DIG
    rcall   LoadHexDigit

    inc     r19
    mov     r18, r17
    andi    r18, LOW_HEX_DIG
    rcall   LoadHexDigit

    inc     r19
    mov     r18, r17
    swap    r18
    andi    r18, LOW_HEX_DIG       ; high digit of r17
    rcall   LoadHexDigit
    ret

LoadHexDigit:
    wordTabOffsetZ  DigitSegTable, r18
    lpm     r20, Z
    byteTabOffsetY  curr_c_patterns, r19
    st      Y, r20
    ret


;-------------------------------------------------------------------------------
; r16 hols the message number to display
DisplayMessage:
    clr r0
    wordTabOffsetZ MessageTable, r0
    ldi     r17, MESSAGE_ENTRIES

DisplayMessageLookupLoop:
    lpm     r18, Z
    cp      r18, r16
    breq    DisplayMessageLookupMatch
    ; brne DisplayMessageLookupNoMatch

DisplayMessageLookupNoMatch:
    adiw    Z, MESSAGE_ENTRY_SIZE
    dec     r17
    brne    DisplayMessageLookupLoop
    ; rjmp DisplayMessageLookupMatch

DisplayMessageLookupMatch:
    adiw    Z, PADDING_SIZE
    ldi     YL, low(curr_msg)
    ldi     YH, high(curr_msg)
    ldi     r17, MSG_LENGTH
    byteTabOffsetY curr_msg, r17

DisplayMessageLoadMsgBufferLoop:
    lpm     r16, Z+
    st      -Y, r16
    dec     r17
    brne    DisplayMessageLoadMsgBufferLoop
    ; breq DisplayMessageLoadDisplayBufferInit

DisplayMessageLoadDisplayBufferInit:
    ldi     XL, low(curr_msg)
    ldi     XH, high(curr_msg)
    ldi     r16, SEG_BUF_OFFSET
    byteTabOffsetY curr_c_patterns, r16
    ldi     r17, MSG_LENGTH

DisplayMessageLoadDisplayBufferLoop:
    ld      r16, X+
    wordTabOffsetZ ASCIISegTable, r16
    lpm     r16, Z
    st      Y+, r16
    dec     r17
    brne    DisplayMessageLoadDisplayBufferLoop
    ; breq DisplayMessageEnd

DisplayMessageEnd:
    ret



; DisplayGameLED
; 
; Description:          This procedure controls the status of an individual LED in
;                       the game board LEDs.
; Operation:            This procedure will set one bit in curr_c_patterns to
;                       either 1 or 0. If the provided LED number is out of range,
;                       the procedure will return without doing anything.
; 
; Arguments:            r16 - An 8-bit LED number (l, 1-70) that indicates the
;                             game board LED to turn on or off.
;                       r17 - A boolean value that indicates the state of the game
;                             board LED. If the value is TRUE (non-zero), the LED
;                             will be turned on. If the value is FALSE (zero), it
;                             will be turned off.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_c_patterns   - a table of port C patterns
; Local Variables:      None.
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, r18, r19, r20, Y
; Stack Depth:          0
;
; Author:               Gavin Hua
; Last Modified:        5/18/2024

DisplayGameLED:
    dec     r16
    cpi     r16, LED_IDX_MAX+1
    brsh    DisplayGameLEDEnd
    cpi     r16, LED_IDX_MIN
    brlo    DisplayGameLEDEnd
    mov     r18, r16
    andi    r18, MOD_8

CreateLEDMaskInit:
    ldi     r19, 0b10000000

CreateLEDMaskLoop:
    cpi     r18, 0
    breq    CreatePatternIndex
    dec     r18
    lsr     r19
    rjmp    CreateLEDMaskLoop

CreatePatternIndex: ; r16 / 8
    lsr    r16
    lsr    r16
    lsr    r16
    ; rjmp CheckSetStatus

CheckSetStatus:
    byteTabOffsetY  curr_c_patterns, r16
    ld      r20, Y      ; prepare to set or clear the bit
    cpi    r17, FALSE
    breq   DisplayGameLEDClear
    ; brne DisplayGameLEDSet

DisplayGameLEDSet:
    or      r20, r19
    st      Y, r20
    rjmp    DisplayGameLEDEnd

DisplayGameLEDClear:
    com     r19
    and     r20, r19
    st      Y, r20
    ; rjmp  DisplayGameLEDEnd

DisplayGameLEDEnd:
    ret
