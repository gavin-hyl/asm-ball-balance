;-------------------------------------------------------------------------------
; display.asm
;
; Description:
;   This file contains the display routines for the 7-segment and the game LEDs.
;
; Tables:
;   MessageTable - a lookup table relating message ids to ASCII messages
;   DispSinkPort0Patterns - a lookup table relating buffer position to sink0 output
;   DispSinkPort1Patterns - a lookup table relating buffer position to sink1 output
;
; Public Functions:
;   DisplayInit - initializes the display
;   ClearDisplay - clears the display
;   DisplayMux - writes the values in the buffers to the display
;   DisplayHex - displays a hexadecimal number to the 7-segment dislay
;   DisplayMessage - displays a message to the 7-segment dislay
;   DisplayGameLED - controls the status of an individual game LED
;
; Author:
;   Gavin Hua
;
; Revision History: 5/18/2024 - Initial revision
;                   5/18/2024 - Debug and test
;                   2024/06/12 - Update DisplayGameLED to not handle mode and
;                                start buttons, and created specialized routines
;                                for them.
;                   2024/06/14 - Adde DisplayMessage function and MessageTable
;                   2024/06/19 - Update comments
;-------------------------------------------------------------------------------



.dseg

curr_src_patterns:  .byte   DISP_BUF_LEN    ; current multiplexing patterns for
                                            ; for the LED source port. The first
                                            ; 10 bytes are for the game LEDs,
                                            ; and the last 4 bytes are for the
                                            ; 7-segment display.
msg_buf:            .byte   SEG_BUF_LEN     ; ASCII buffer for the message to
                                            ; display
disp_buf_pos:       .byte   1   ; the current position in the display buffer
blink_dim_cnt:      .byte   1   ; counts the time in interrupt ticks since the
                                ; last time that the LEDs were turned on
display_on_t:       .byte   1   ; the time in interrupt ticks that the LEDs
                                ; should be turned on. This controls the on-off
                                ; cycle that drives display blinking/dimming. 
display_off_t:      .byte   1   ; the time in interrupt ticks that the LEDs
                                ; should be turned off. This controls the on-off
                                ; cycle that drives display blinking/dimming. 


;-------------------------------------------------------------------------------
.cseg

; MessageTable
;
; Description:      This table contains the message contents for each of the
;                   settings, modes, and win/losing the game. 
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    2024/06/17

MessageTable:
    ;db     index           padding     message
    .db     TIMED,          0x00,       "t   "
    ; byte size of an entry
    .equ    MESSAGE_ENTRY_SIZE = 2 * (PC - MessageTable)
    .db     INFINITE,       0x00,       " inF"
    .db     GRAVITY,        0x00,       "g=  "
    .db     BOUND,          0x00,       "EdgE"
    .db     RANDOM_V,       0x00,       "rng="
    .db     TIME_LIM,       0x00,       "t=  "
    .db     SIZE,           0x00,       "bALL"
    .db     LOSE,           0x00,       " =( "
    .db     WIN,            0x00,       " =) "
    ; number of entries in the table
    .equ    MESSAGE_ENTRIES = (PC - MessageTable) / (MESSAGE_ENTRY_SIZE / 2)
    .db     0x00,           0x00,       " Err"



;-------------------------------------------------------------------------------
; DispSinkPort0Patterns
;
; Description:      This is the segment pattern table for the Port A (sink 0),
;                   for the 7-segment display and the game LEDs.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    2024/05/18

DispSinkPort0Patterns:
	.db	0b00000001, 0b00000010
	.db	0b00000100, 0b00001000
	.db	0b00010000, 0b00100000
	.db	0b01000000, 0b00000000
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000000



;-------------------------------------------------------------------------------
; DispSinkPort1Patterns
;
; Description:      This is the segment pattern table for the Port D (sink 1)
;                   for the 7-segment display and the game LEDs.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    2024/05/18

DispSinkPort1Patterns:
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000010
	.db	0b00000001, 0b00000100
	.db	0b00001000, 0b00010000
	.db	0b00100000, 0b01000000



;-------------------------------------------------------------------------------
.cseg

; InitDisplay
;
; Description:          This procedure initializes the display variables to set
;                       the LEDs to maximum brightness, and clears the display.
; Operation:            This procedure clears the current digit and the blink/dim
;                       counter. It then sets the display_on/off_t variables to
;                       represent maximum brightness/no blinking display. It
;                       lastly calls the ClearDisplay routine.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     blink_dim_cnt - set to 0
;                       disp_buf_pos - set to 0
;                       display_on_t - set to 1
;                       display_off_t - set to 0
;                       curr_src_patterns - set to all LED_OFF
; Local Variables:      tmp (r16) - used to hold values to store into variables
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, Y
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

InitDisplay:
    clr     r16
    sts     blink_dim_cnt, r16      ; start counting at 0
    sts     disp_buf_pos, r16           ; start position in the buffer at 0

    ldi     r16, DISP_ON_T_INIT     ; max brightness
    sts     display_on_t, r16
    ldi     r16, DISP_OFF_T_INIT    ; display never turns off
    sts     display_off_t, r16
    rcall   ClearDisplay    ; fill the entire buffer with LED_OFF
    ret



;-------------------------------------------------------------------------------
; ClearDisplay
;
; Description:          This procedure clears the display.
; Operation:            This procedure will set all the curr_src_patterns to the 
;                       blank digit pattern.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_src_patterns - set to all LED_OFF
; Local Variables:      loop counter (r16) - used to iterate over the buffer
;                       tmp (r17) - used to store LED_OFF into the buffer
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
; Registers Used:       r16, r17, Y
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

ClearDisplay:
    ldi     r16, DISP_BUF_LEN
    byteTabOffsetY  curr_src_patterns, r16  ; Y points to the end of the buffer
    ldi     r17, LED_OFF

ClearDisplayLoop:
    st      -Y, r17             ; fill the buffer with LED_OFF
    dec     r16                 ; check whether we have reached the start
    brne    ClearDisplayLoop    ; if not, then continue filling in the buffer
    ; breq  ClearDisplayEnd     ; if so, then break

ClearDisplayEnd:
    ret



;-------------------------------------------------------------------------------
; DisplayMux
; Description:          This procedure writes one value in the buffers to the
;                       display or game LEDs. It expects to be called by the
;                       timer interrupt at a 1 ms interval.
; Operation:            This procedure will write a output pattern to the GPIO,
;                       corresponding to a digit or game LED block. It will then
;                       increment/wrap the current digit and the blink/dim
;                       counter.
;
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_src_patterns - read only
;                       disp_buf_pos - set to (disp_buf_pos+1) % DISP_BUFF_LEN
;                       blink_dim_cnt - set to (cnt+1) % (on_t + off_t)
; Local Variables:      tmp (r16) - holds LED_OFF, then blink_dim_cnt
;                       port_pattern (r18) - current port pattern
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, r18, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

DisplayMux:

    ldi     r16, LED_OFF        ; turn off all LEDs
    out     DISP_SINK_PORT0, r16          ; by turning off both sink ports
    out     DISP_SINK_PORT1, r16

    lds     r16, blink_dim_cnt
    lds     r17, display_on_t
    cp      r16, r17            ; check whether the count >= on time
    brsh    IncDimCnt           ; if so, turn off the LEDs
    brlo    DisplayDigit        ; if not, display the next digit

DisplayDigit:
    lds     r17, disp_buf_pos

    byteTabOffsetY  curr_src_patterns, r17  ; Y points to source pattern to load
    ld      r18, Y
    out     DISP_SRC_PORT, r18          ; load the pattern into the source port

    wordTabOffsetZ  DispSinkPort0Patterns, r17  ; Z points to sink 0 patternt to load
    lpm     r18, Z
    out     DISP_SINK_PORT0, r18          ; load the pattern into the sink port 0

    wordTabOffsetZ  DispSinkPort1Patterns, r17  ; Z points to sink 1 patternt to load
    lpm     r18, Z
    out     DISP_SINK_PORT1, r18          ; load the pattern into the sink port 1
    ; rjmp  IncCurrDig

IncCurrDig:
    inc     r17                 ; +1 to the buffer position
    cpi     r17, DISP_BUF_LEN  ; check whether position >= buffer length
    brne    StoreBufPos         ; if so, then store the position back
    ; breq  WrapBufPos          ; if not, then wrap the position to 0

WrapBufPos:
    clr r17                     ; set the position to 0
    ; rjmp  StoreBufPos

StoreBufPos:
    sts     disp_buf_pos, r17   ; store the buffer position
	; rjmp  IncDimCnt

IncDimCnt:
    inc     r16                 ; increment blink_dim_cnt
    lds     r17, display_on_t
    lds     r18, display_off_t
    add     r17, r18
    cp      r16, r17            ; check whether cnt = on_t + off_t
    brne    StoreDimCnt         ; if not, store it back
    ; breq  WrapDimCnt          ; if so, wrap the count to 0

WrapDimCnt:
    clr     r16                 ; wrap the count to 0
    ; rjmp  storeDimCnt

StoreDimCnt:
    sts     blink_dim_cnt, r16  ; store the count back into the variable
    ; rjmp  DisplayMuxEnd

DisplayMuxEnd:
    ret



;-------------------------------------------------------------------------------
; DisplayHex
;
; Description:          This procedure displays a hexadecimal number stored in
;                       r17|r16. high17-low17-high16-low16 (nibbles) correspond
;                       to dig0-dig1-dig2-dig3 on the display.
; Operation:            The procedure will set the 7-seg region of the 
;                       curr_src_patterns buffer to the corresponding digit
;                       pattern for each digit of the number.
; 
; Arguments:            n (r17|r16) - the four digits to be displayed. 
;                                     high17-low17-high16-low16 correspond to
;                                     dig0-dig1-dig2-dig3 on the display. The 
;                                     value is destroyed. The contents of these
;                                     two registers will always be interpreted
;                                     as a 4-digit hexadecimal number.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_src_patterns - 7seg region (last 4 bytes) written
; Local Variables:      tmp (r19) - SEG_BUF_OFFSET, low nibble of r16, buffer
;                                   pattern
;                       loop counter (r20)
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, r18, r19, r20, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

DisplayHex:
    ldi     r19, SEG_BUF_OFFSET ; prepare to set up Y pointer
    byteTabOffsetY  curr_src_patterns, r19  ; Y points to the start of the 7seg
                                            ; buffer
    ldi     r20, SEG_BUF_LEN    ; set up loop counter

DisplayHexLoop:
    mov     r19, r16            ; copy r16 to preserve high nibble after ANDI
    andi    r19, LOW_HEX_DIG    ; get the low nibble of r16
    wordTabOffsetZ  DigitSegTable, r19  ; Z points to the segment pattern
    lpm     r19, Z
    st      Y+, r19             ; store the seg pattern into the buffer
    rcall   Shift16Right        ; align next nibble with r16 low nibble
    dec     r20                 ; decrement loop counter
    brne    DisplayHexLoop      ; if cnt != 0, continue looping
    ; breq  DisplayHexEnd       ; otherwise, finished loading buffer

DisplayHexEnd:
    ret                         ; all done, return



;-------------------------------------------------------------------------------
; DisplayMessage
;
; Description:          This procedure displays a 4-character messsage
;                       specified by a message id in r16 to the 7-seg display.
; Operation:            This procedure first loads the message into a buffer,
;                       the accesses the ASCIISegTable, and loads the source
;                       port patterns into the display buffer.
; 
; Arguments:            msg_id (r16) - the ID of the event/message to display,
;                                      a full list is given in MessageTable.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_src_patterns - 7seg region (last 4 bytes) written
; Local Variables:      msg_buf - read and write
;                       loop counter (r17) - for msg lookup, msg loading, and
;                                            pattern loading.
;                       tmp (r16) - after table lookup match, r16 is used to
;                                   store the results of various ld/lpm's,
;                                   and to offset X, Y, and Z pointers.
;                       tmp (r18) - during msg table lookup, r18 holds lpm's
;                                   results to compare with r16.
;                       
; Input:                None.
; Output:               None.
;   
; Error Handling:       If msg_id is unknown, " Err" is displayed by default.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, r18, X, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

DisplayMessage:
    clr     r17                         ; prepare to set up Z pointer
    wordTabOffsetZ MessageTable, r17    ; point Z to the start of MessageTable
    ldi     r17, MESSAGE_ENTRIES        ; set up loop counter for table look-up
    ; rjmp  DisplayMessageLookupLoop

DisplayMessageLookupLoop:
    lpm     r18, Z                      ; load current msg_id
    cp      r18, r16                    ; check finding a matching entry
    breq    DisplayMessageLookupMatch   ; if matching, start loading the msg
    ; brne DisplayMessageLookupNoMatch  ; if not, keep looking

DisplayMessageLookupNoMatch:
    adiw    Z, MESSAGE_ENTRY_SIZE       ; point Z to the next entry
    dec     r17                         ; decrement and test loop counter
    brne    DisplayMessageLookupLoop    ; if nonzero, keep looking
    ; rjmp DisplayMessageLookupMatch    ; otherwise, Z points at default, break

DisplayMessageLookupMatch:
    adiw    Z, MESSAGE_ENTRY_SIZE - SEG_BUF_LEN ; point Z to msg start
    ldi     r17, SEG_BUF_LEN            ; prepare to set up Y pointer
    byteTabOffsetY msg_buf, r17         ; point Y to the end of msg_buf
    ; rjmp  DisplayMessageLoadMsgBufferLoop

DisplayMessageLoadMsgBufferLoop:
    lpm     r16, Z+                     ; load one message character
    st      -Y, r16                     ; store it in the msg_buf
    dec     r17                         ; decrement and test loop counter
    brne    DisplayMessageLoadMsgBufferLoop ; if nonzero, keep loading
    ; breq DisplayMessageLoadDisplayBufferInit  ; otherwise, done loading

DisplayMessageLoadDisplayBufferInit:
    ldi     XL, low(msg_buf)            ; point X to the start of msg_buf
    ldi     XH, high(msg_buf)
    ldi     r16, SEG_BUF_OFFSET         ; prepare to set up Y pointer
    byteTabOffsetY curr_src_patterns, r16   ; point Y to end of src pattern buf
    ldi     r17, SEG_BUF_LEN            ; loop counter for loading display buf
    ; rjmp  DisplayMessageLoadDisplayBufferLoop

DisplayMessageLoadDisplayBufferLoop:
    ld      r16, X+                     ; get one ASCII character
    wordTabOffsetZ ASCIISegTable, r16   ; point Z to the corresponding pattern
    lpm     r16, Z                      ; load the pattern
    st      Y+, r16                     ; store it in the display buffer
    dec     r17                         ; decrement and test loop counter
    brne    DisplayMessageLoadDisplayBufferLoop ; if nonzero, keep loading
    ; breq DisplayMessageEnd            ; otherwise, we are done

DisplayMessageEnd:
    ret                                 ; all done, return



;-------------------------------------------------------------------------------
; DisplayGameLED
; 
; Description:          This procedure controls the status of an individual LED in
;                       the game board LEDs.
; Operation:            This procedure will first check whether the provided LED
;                       number is out of range. If so, then it returns without
;                       doing anything. Otherwise, it sets one bit in
;                       curr_src_patterns to either 1 or 0, depending on set.
; 
; Arguments:            idx (r16) - An 8-bit LED number (l, 1-70) that indicates
;                                   the game board LED to turn on or off.
;                       set (r17) - A boolean value that indicates the state of
;                                   the game board LED. If the value is TRUE
;                                   (non-zero), the LED will be turned on.
;                                   Otherwise, it will be turned off.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     curr_src_patterns - read and write
; Local Variables:      loop counter (r18) - r16%8, used to create the bit mask
;                       mask (r19) - set/clear a bit in the display buffer
;                       tmp (r20) 0 - holds a byte in the display buffer
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       If the provided LED number is out of range, the 
;                       procedure will return without doing anything.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17, r18, r19, r20, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

DisplayGameLED:
    ; push    r16
    ; push    r17
    ; push    r18
    ; push    r19
    ; push    r20
    ; push    YL
    ; push    YH
    dec     r16                 ; offset the range from 1-70 to 0-69
    cpi     r16, LED_IDX_MAX+1  ; only >= is available for unsigned, so +1
    brsh    DisplayGameLEDEnd   ; if idx >= max_idx + 1, then do nothing
    cpi     r16, LED_IDX_MIN    ; compare index with min_idx
    brlo    DisplayGameLEDEnd   ; if idx < min_idx, do nothing
    mov     r18, r16            ; preserve r16 for later use
    andi    r18, MOD_8          ; the hardware groups LEDs by 8, and which
                                ; source pin to activate depends on the idx
                                ; within that group, so we mod 8.

CreateLEDMaskInit:
    ldi     r19, LED_MASK_INIT  ; initialize the mask (0x80) for the source pin

CreateLEDMaskLoop:
    cpi     r18, 0              ; if index%8 = 0, we are done creating the mask
    breq    CreatePatternIndex  ; so we try to find the sink pin
    dec     r18                 ; otherwise, keep shifting the bit
    lsr     r19                 ; the idx corresponds to the position of the
                                ; source pin bit, so shift the mask to find it
    rjmp    CreateLEDMaskLoop   ; keep looping

CreatePatternIndex:
    lsr    r16                  ; find the group number of the index
    lsr    r16                  ; which is accomplished by computing index/8
    lsr    r16
    ; rjmp CheckSetStatus

CheckSetStatus:
    byteTabOffsetY  curr_src_patterns, r16  ; point Y to the LED group specified
                                            ; by the index
    ld     r20, Y               ; set or clear the bit in the current pattern
    cpi    r17, FALSE           ; check whether to set or clear
    breq   DisplayGameLEDClear  ; if r17=FALSE, then clear
    ; brne DisplayGameLEDSet    ; otherwise, set the bit

DisplayGameLEDSet:
    or      r20, r19            ; set the bit using the mask
    rjmp    DisplayGamePatternStore

DisplayGameLEDClear:
    com     r19                 ; invert the mask (all 1's except for a 0)
    and     r20, r19            ; clear the bit using the inverted mask
    ; rjmp  DisplayGamePatternStore

DisplayGamePatternStore:
    st      Y, r20              ; store the pattern back
    ; rjmp  DisplayGameLEDEnd

DisplayGameLEDEnd:
    ; pop     YH
    ; pop     YL
    ; pop     r20
    ; pop     r19
    ; pop     r18
    ; pop     r17
    ; pop     r16
    ret                         ; all done, return
