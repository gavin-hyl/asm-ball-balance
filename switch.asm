;-------------------------------------------------------------------------------
; switch.asm
;
; Description:
;   This file contains function used to debounce the input switches and the
;   rotary encoder, and to interface withe the shared variables.
;
; Public Functions:
;   InitSwitch - initializes the switch/encoder variables
;   RotPress - returns ZF set if the rotary encoder switch has been pressed
;   ModePress - returns ZF set if the mode button has been pressed
;   StartPress - returns ZF set if the start button has been pressed
;   RotCCW - returns ZF set if the rotary encoder has been turned CCW
;   RotCW - returns ZF set if the rotary encoder has been turned CW
;   DebounceButtons - debounces the input switches and the rotary encoder,
;                     expects to be called periodically every 1 ms.
;
; Private Functions:
;   CheckPressFlag - macro to check the pressed flag and reset it
;   CheckBtn - debounces the input switches individually
;
; Author:
; 	Gavin Hua
;
; Revision History: 
;	2024/05/03 - initial revision
;	2024/05/04 - debugged functions
;   2024/06/10 - cleaned up code
;   2024/06/11 - update comments
;-------------------------------------------------------------------------------

.dseg

start_pressed:  .byte   1   ; flag to indicate if the start button was pressed
start_cnt:      .byte   1   ; debounce counter for the start button
                            ; register a press if counter is 0

mode_pressed:   .byte   1   ; flag to indicate if the mode button was pressed
mode_cnt:       .byte   1   ; debounce counter for the mode button
                            ; register a press if counter is 0

rot_pressed:    .byte   1   ; flag to indicate if the rotary encoder was pressed
rot_cnt:        .byte   1   ; debounce counter for the rotary encoder
                            ; register a press if counter is 0

rot_state:      .byte   1   ; rotary encoder position history since last detent
rot_cw:         .byte   1   ; flag to indicate if the rotary encoder turned CW
rot_ccw:        .byte   1   ; flag to indicate if the rotary encoder turned CCW



;-------------------------------------------------------------------------------
.cseg

; InitSwitch
;
; Description:          This procedure initializes the switch/encoder variables.
; Operation:            This procedure will set the debounce counters to their
;                       initial values, clear the rotary encoder history, and 
;                       set the pressed flags to false.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     start_cnt - set to DEBOUNCE_T
;                       mode_cnt - set to DEBOUNCE_T
;                       rot_cnt - set to DEBOUNCE_T
;                       rot_state - set to ENC_INIT_STATE
;                       start_pressed - set to FALSE
;                       mode_pressed - set to FALSE
;                       rot_pressed - set to FALSE
;                       rot_cw - set to FALSE
;                       rot_ccw - set to FALSE
; Local Variables:      tmp (r16) - temporary register used to load variables
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r16.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

InitSwitch:
    ldi     r16, DEBOUNCE_T         ; load before cli to reduce critical code
    in      r0, SREG                ; critical code start, save SREG
    cli
    sts     start_cnt, r16          ; set all debounce counters to DEBOUNCE_T
    sts     mode_cnt,  r16
    sts     rot_cnt,   r16
    ldi     r16, ENC_INIT_STATE     ; set initial state for rotary encoder
    sts     rot_state, r16
    ldi     r16, FALSE              ; set all pressed/rotated flags to false
    sts     start_pressed, r16
    sts     mode_pressed, r16
    sts     rot_pressed, r16
    sts     rot_cw, r16
    sts     rot_ccw, r16
    out     SREG, r0                ; critical code end, restore SREG
    ret



;-------------------------------------------------------------------------------
; CheckPressFlag
;
; Description:          The procedure returns TRUE (zero flag set) if the start 
;                       button has been pressed since the last time it was 
;                       called. Otherwise FALSE (zero flag reset) is returned.
; Operation:            This procedure will read the start_pressed byte, which is 
;                       set by the Event Handler. If the start_pressed byte is 
;                       TRUE, then the zero flag is set, otherwise it is reset.
;                       The start_pressed byte is then reset to FALSE.
; Arguments:            None.
; Return Value:         The Z flag, set if start button has been pressed, 
;                       cleared otherwise.
;
; Global Variables:     None.
; Shared Variables:     start_pressed - read and reset.
; Local Variables:      r0  - register used to store the SREG.
;                       r16 - register used to store the start_pressed byte.
;                       r17 - register used to reset the start_pressed byte.
;
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    SREG, r0, r16, r17.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10
.macro CheckPressFlag
    ldi		r17, FALSE
    in      r0, SREG
    cli
    lds		r16, @0
    sts		@0, r17
    out		SREG, r0
    cpi		r16, TRUE
    ret
.endmacro



;------------------------------------------------------------------------------
; RotPress
;
; Description:          The procedure returns TRUE (zero flag set) if the rotary 
;                       encoder switch has been pressed since the last time it 
;                       was called. Otherwise FALSE (zero flag reset) is returned.
; Operation:            This procedure uses the CheckPressFlag macro to check
;                       the rot_pressed flag and reset it.
;
; Arguments:            None.
; Return Value:         The Z flag, set if rotary encoder switch has been 
;                       pressed, cleared otherwise.
;
; Global Variables:     None.
; Shared Variables:     rot_pressed - read and reset.
; Local Variables:      None
;
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    SREG, r0, r16, r17.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10
RotPress:
    CheckPressFlag  rot_pressed ; refer to CheckPressFlag macro



;-------------------------------------------------------------------------------
; ModePress
;
; Description:          The procedure returns TRUE (zero flag set) if the mode 
;                       button has been pressed since the last time it was 
;                       called. Otherwise FALSE (zero flag reset) is returned.
; Operation:            This procedure uses the CheckPressFlag macro to check
;                       the mode_pressed flag and reset it.
;
; Arguments:            None.
; Return Value:         The Z flag, set if mode button has been pressed, cleared
;                       otherwise.
;
; Global Variables:     None.
; Shared Variables:     mode_pressed - read and reset.
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
; Registers changed:    SREG, r0, r16, r17.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

ModePress:
    CheckPressFlag  mode_pressed    ; refer to CheckPressFlag macro



;--------------------------------------------------------------------------------
; StartPress
;
; Description:          The procedure returns TRUE (zero flag set) if the start 
;                       button has been pressed since the last time it was 
;                       called. Otherwise FALSE (zero flag reset) is returned.
; Operation:            This procedure uses the CheckPressFlag macro to check
;                       the start_pressed flag and reset it.
;
; Arguments:            None.
; Return Value:         The Z flag, set if start button has been pressed, 
;                       cleared otherwise.
;
; Global Variables:     None.
; Shared Variables:     start_pressed - read and reset.
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
; Registers changed:    SREG, r0, r16, r17.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

StartPress:
    CheckPressFlag  start_pressed   ; refer to CheckPressFlag macro



;-------------------------------------------------------------------------------
; RotCCW
;
; Description:          The procedure returns TRUE (zero flag set) if the rotary 
;                       encoder has been turned counterclockwise since the last 
;                       time it was called. Otherwise FALSE (zero flag reset) is 
;                       returned.
; Operation:            This function uses the CheckPressFlag macro to check
;                       the rot_ccw byte and reset it.
;
; Arguments:            None.
; Return Value:         The Z flag, set if rotary encoder has been turned 
;                       counterclockwise, cleared otherwise.
;
; Global Variables:     None.
; Shared Variables:     rot_ccw - read and reset.
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
; Registers changed:    SREG, r0, r16, r17.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

RotCCW:
    CheckPressFlag  rot_ccw ; refer to CheckPressFlag macro



;-------------------------------------------------------------------------------
; RotCW
;
; Description:          The procedure returns TRUE (zero flag set) if the rotary 
;                       encoder has been turned clockwise since the last time it 
;                       was called. Otherwise FALSE (zero flag reset) is returned.
; Operation:            This function uses the CheckPressFlag macro to check
;                       the rot_cw byte and reset it.
;
; Arguments:            None.
; Return Value:         The Z flag, set if rotary encoder has been turned 
;                       clockwise, cleared otherwise.
;
; Global Variables:     None.
; Shared Variables:     rot_cw - read and reset.
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
; Registers changed:    SREG, r0, r16, r17.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

RotCW:
    CheckPressFlag  rot_cw  ; refer to CheckPressFlag macro



;-------------------------------------------------------------------------------
; DebounceButtons:
;
; Description:          This procedure expects to be called every 1 ms. It will
;                       debounce the input switches and the rotary encoder.
; Operation:            This procedure will debounce the switches and the rotary
;                       encoders by waiting for the signals to settle for the 
;                       former, and recording the sequences of events for the 
;                       latter. We first dicuss the switches. If the switches
;                       are pressed, the debounce counter is set to the debounce
;                       time. If the debounce counter is not zero, it is
;                       decremented. If the debounce counter is zero, the
;                       corresponding pressed flag is set. The rotary encoder
;                       is debounced by recording the sequence of events since
;                       the last time the encoder was in the detent position.
;                       The encoder reading is compared with the previous state
;                       to determine if the encoder has moved. If the encoder
;                       has moved, the state is updated. If the encoder is in
;                       the detent position, the direction of rotation is
;                       determined. If the encoder is turned clockwise, the
;                       rot_cw flag is set. If the encoder is turned
;                       counterclockwise, the rot_ccw flag is set.
;                       The procedure ends by returning from the interrupt.
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     start_cnt - incremented/reset
;                       mode_cnt - incremented/reset
;                       rot_cnt - incremented/reset
;                       start_pressed - possibly set
;                       mode_pressed - possibly set
;                       rot_pressed - possibly set
;                       rot_state - updated
;                       rot_cw - possibly set
;                       rot_ccw - possibly set
; Local Variables:      r16 - register used to store the current state of the
;                             switches and the rotary encoder.
;                       r17 - register used to mask the switches.
;                       r18 - register used to manipulate the debounce counter.
;                       r19 - register used to set the pressed flags.
;                       r20 - register used to store the encoder reading.
;                       r21 - register used to store the past rotation states.
;                       r22 - register used to store the two bits of interest in
;                             the state recording.
;
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None
;
; Registers changed:    r16, r17, r18, r19, r20, r21, r22, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

DebounceButtons:

CheckStart:
    lds     r18, start_cnt      ; r18 stores debounce cnt for start button
    ldi     r19, START_BTN_MASK ; r19 stores the mask for the start button
    rcall   CheckBtn            ; setup complete, call CheckBtn
    sts     start_cnt, r18      ; store the updated debounce cnt
    lds     r18, start_pressed  ; prepare to set the pressed flag if necessary
    or      r18, r19            ; set the pressed flag if CheckBtn set r19=TRUE
    sts     start_pressed, r18  ; store the updated pressed flag
    ; rjmp  CheckMode           ; proceed to check the mode button

CheckMode:
    lds     r18, mode_cnt       ; r18 stores debounce cnt for mode button
    ldi     r19, MODE_BTN_MASK  ; r19 stores the mask for the mode button
    rcall   CheckBtn            ; setup complete, call CheckBtn
    sts     mode_cnt, r18       ; store the updated debounce cnt
    lds     r18, mode_pressed   ; prepare to set the pressed flag if necessary
    or      r18, r19            ; set the pressed flag if CheckBtn set r19=TRUE
    sts     mode_pressed, r18   ; store the updated pressed flag
    ; rjmp  CheckRot            ; proceed to check the rotary encoder

CheckRot:
    lds     r18, rot_cnt        ; r18 stores debounce cnt for encoder button
    ldi     r19, ROT_BTN_MASK   ; r19 stores the mask for the encoder button
    rcall   CheckBtn            ; setup complete, call CheckBtn
    sts     rot_cnt, r18        ; store the updated debounce cnt
    lds     r18, rot_pressed    ; prepare to set the pressed flag if necessary
    or      r18, r19            ; set the pressed flag if CheckBtn set r19=TRUE
    sts     rot_pressed, r18    ; store the updated pressed flag
    ; rjmp  CheckEnc

CheckEnc:
    in      r20, BUTTON_DATA    ; get the entire GPIO readings  (denote t+1)
    andi    r20, ENC_MASK       ; andi to get encoder reading in r20
    lsl     r20                 ; align the reading with the state[5:4]
    lds     r21, rot_state      ; r21 stores the past rotation states (t -> t-3)
    mov     r22, r21            ; r22 stores the two bits of interest
    andi    r22, ENC_BOUNCE_MASK; andi to get the state from t-1
    cp      r22, r20            ; compare state from t-1 with t+1
    brne    EncNoBounce         ; if not equal, encoder did not bounce back
    ; BREQ  EncBounced          ; otherwise, it did

EncBounced:
    rjmp    DebounceButtonsEnd  ; ignore the bounce

EncNoBounce:
    mov     r22, r21            ; now we check the state from t
    andi    r22, ENC_PREV_MASK  ; andi to get the state from t (at bits 7:6)
    lsl     r20                 ; align state(t+1) with state(t)
    lsl     r20                 ; t+1 was originally at bits 5:4
    cp      r22, r20            ; compare them
    breq    DebounceButtonsEnd  ; if no change in the encoder state, do nothing
    ; brne  EncUpdateState      ; otherwise, update the state with new reading

EncUpdateState:
    lsr     r21 
    lsr     r21                 ; shift state right to make room for new reading
    add     r21, r20            ; append the new reading to the state
    sts     rot_state, r21      ; store the updated state
    ; rjmp    EncCheckCW

EncCheckCW:
    cpi     r21, ENC_CW_TURN    ; check if the encoder has traversed a CW turn
    brne	EncCheckCCW         ; if not, check if it has traversed a CCW turn
    ; breq    SetRotCW          ; if so, set the CW flag and clear the state

SetRotCW:
    ldi     r19, TRUE           ; set the CW flag
    sts     rot_cw, r19
    ldi     r21, ENC_INIT_STATE ; reset the state to the initial state
    sts     rot_state, r21      ; store the initial state
    rjmp	DebounceButtonsEnd  ; and we are done

EncCheckCCW:
    cpi     r21, ENC_CCW_TURN   ; check if the encoder has traversed a CCW turn
    brne	DebounceButtonsEnd  ; if not, we are done
    ; breq SetRotCCW            ; if so, set the CCW flag and clear the state

SetRotCCW:
    ldi     r19, TRUE           ; set the CCW flag
    sts     rot_ccw, r19
    ldi     r21, ENC_INIT_STATE ; reset the state to the initial state
    sts     rot_state, r21      ; store the initial state
    ; rjmp  DebounceButtonsEnd  ; and we are done

DebounceButtonsEnd:
    ret                         ; all done, return



;--------------------------------------------------------------------------------
; CheckBtn
;
; Description:          This procedure debounces the input switches individually.
;                       It expects to be called by DebounceButtons to debounce
;                       the start, mode, and rotary encoder switches. It takes
;                       as arguments the current debounce counter and the bit
;                       mask for the switch. It returns the updated debounce
;                       counter and the pressed flag.
; Operation:            
;
; Arguments:            cur_cnt (r18) - current debounce counter for the button
;                       mask (r19) - bit mask for the button
;
; Return Value:         new_cnt (r18) - updated debounce counter for the button
;                       pressed (r19) - set if the button was pressed, cleared
;                                       otherwise.
;
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      btn_state (r16) - current state of the button
;
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    SREG, r0, r16, r18, r19.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

CheckBtn:
    in      r16, BUTTON_DATA    ; r16 holds the current state of the buttons
    and     r16, r19            ; get the individual button state
    breq    BtnDown             ; if 0, the button is pressed
    ; brne  BtnUp               ; otherwise, the button is not pressed

BtnUp:                          ; button is not pressed
    ldi     r18, DEBOUNCE_T     ; set the debounce counter to the debounce time
    ldi     r19, FALSE          ; clear the pressed flag
    rjmp    CheckBtnEnd         ; and we are done

BtnDown:                        ; button is pressed
    ldi     r19, FALSE          ; clear the pressed flag (possibly set later)
    dec     r18                 ; decrement and test the debounce counter
    brne    CheckBtnEnd         ; if not zero, we are done
    ; breq  SetBtnPressed       ; otherwise, set the pressed flag

SetBtnPressed:
    ldi     r18, AUTOREP_T      ; set debounce counter to the autorepeat time
    ldi     r19, TRUE           ; set the pressed flag
    ; rjmp  CheckBtnEnd         ; and we are done

CheckBtnEnd:
    ret                         ; all done, return