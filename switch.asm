; Description:      This file contains the switch logic functions for EE/CS 10b
;                   Homework #2. The functions are used to debounce the input
;                   switches and the rotary encoder. The functions are called
;                   by the Event Handler to determine if the switches have been
;                   pressed, and if the rotary encoder has been turned. The
;                   functions are also used to determine the direction of
;                   rotation of the rotary encoder.
;
; Input:            None.
; Output:           None.
;
; User Interface:   None.
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      None.
;
; Revision History:
;       5/03/24     Gavin Hua      Initial Revision
;       5/04/24     Gavin Hua      Debugged functions

.dseg

start_pressed:  .byte   1
start_cnt:      .byte   1

mode_pressed:   .byte   1
mode_cnt:       .byte   1

rot_pressed:    .byte   1
rot_cnt:        .byte   1

rot_state:      .byte   1
rot_cw:         .byte   1
rot_ccw:        .byte   1


.cseg

; SwitchInit
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
; Shared Variables:     None.
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
; Registers changed:    r16.
;
; Stack Depth:          0 bytes.
;
; Author:               Gavin Hua
; Last Modified:        5/4/2024

InitSwitch:
    ldi     r16, DEBOUNCE_T
    in      r0, SREG
    cli
    sts     start_cnt, r16
    sts     mode_cnt,  r16
    sts     rot_cnt,   r16
    ldi     r16, ENC_INIT_STATE
    sts     rot_state, r16
    out     SREG, r0
    rcall   ClearButtons
    ret



ClearButtons:
    ldi     r16, FALSE
    in		r0, SREG
    cli
    sts     start_pressed, r16
    sts     mode_pressed, r16
    sts     rot_pressed, r16
    sts     rot_cw, r16
    sts     rot_ccw, r16
    out     SREG, r0
    ret


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


; RotPress
;
; Description:          The procedure returns TRUE (zero flag set) if the rotary 
;                       encoder switch has been pressed since the last time it 
;                       was 
;                       called. Otherwise FALSE (zero flag reset) is returned.
; Operation:            This procedure will read the rot_pressed byte, which is set
;                       by the Event Handler. If the rot_pressed byte is TRUE, then
;                       the zero flag is set, otherwise it is reset. The rot_pressed
;                       byte is then reset to FALSE.
; Arguments:            None.
; Return Value:         The Z flag, set if rotary encoder switch has been 
;                       pressed, cleared otherwise.
;
; Global Variables:     None.
; Shared Variables:     The rot_pressed byte is read and reset.
; Local Variables:      r0  - register used to store the SREG.
;                       r16 - register used to store the rot_pressed byte.
;                       r17 - register used to reset the rot_pressed byte.
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
; Stack Depth:          0 bytes.
;
; Author:               Gavin Hua
; Last Modified:        5/4/2024
RotPress:
    CheckPressFlag  rot_pressed


; ModePress
;
; Description:          The procedure returns TRUE (zero flag set) if the mode 
;                       button has been pressed since the last time it was 
;                       called. Otherwise FALSE (zero flag reset) is returned.
; Operation:            This procedure will read the mode_pressed byte, which is 
;                       set by the Event Handler. If the mode_pressed byte is 
;                       TRUE, then the zero flag is set, otherwise it is reset.
;                       The mode_pressed byte is then reset to FALSE.
; Arguments:            None.
; Return Value:         The Z flag, set if mode button has been pressed, cleared
;                       otherwise.
;
; Global Variables:     None.
; Shared Variables:     The mode_pressed byte is read and reset.
; Local Variables:      r0  - register used to store the SREG.
;                       r16 - register used to store the mode_pressed byte.
;                       r17 - register used to reset the mode_pressed byte.
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
; Stack Depth:          0 bytes.
;
; Author:               Gavin Hua
; Last Modified:        5/4/2024

ModePress:
    CheckPressFlag  mode_pressed


; StartPress
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
; Shared Variables:     The start_pressed byte is read and reset.
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
; Stack Depth:          0 bytes.
;
; Author:               Gavin Hua
; Last Modified:        5/4/2024

StartPress:
    CheckPressFlag  start_pressed


; RotCCW
;
; Description:          The procedure returns TRUE (zero flag set) if the rotary 
;                       encoder has been turned counterclockwise since the last 
;                       time it was called. Otherwise FALSE (zero flag reset) is 
;                       returned.
; Operation:            This function will read the rot_ccw byte, which is 
;                       set by the Event Handler. If the rot_ccw byte is 
;                       TRUE, then the zero flag is set, otherwise it is reset. 
;                       The rot_ccw byte is then reset to FALSE.
; Arguments:            None.
; Return Value:         The Z flag, set if rotary encoder has been turned 
;                       counterclockwise, cleared otherwise.
;
; Global Variables:     None.
; Shared Variables:     The rot_ccw byte is read and reset.
; Local Variables:      r0  - register used to store the SREG.
;                       r16 - register used to store the rot_ccw byte.
;                       r17 - register used to reset the rot_ccw byte.
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
; Stack Depth:          0 bytes.
;
; Author:               Gavin Hua
; Last Modified:        5/4/2024

RotCCW:
    CheckPressFlag  rot_ccw


; RotCW
;
; Description:          The procedure returns TRUE (zero flag set) if the rotary 
;                       encoder has been turned clockwise since the last time it 
;                       was called. Otherwise FALSE (zero flag reset) is returned.
; Operation:            This function will read the rot_cw byte, which is 
;                       set by the Event Handler. If the rot_cw byte is 
;                       TRUE, then the zero flag is set, otherwise it is reset. 
;                       The rot_cw byte is then reset to FALSE.
; Arguments:            None.
; Return Value:         The Z flag, set if rotary encoder has been turned 
;                       clockwise, cleared otherwise.
;
; Global Variables:     None.
; Shared Variables:     The rot_cw byte is read and reset.
; Local Variables:      r0  - register used to store the SREG.
;                       r16 - register used to store the rot_cw byte.
;                       r17 - register used to reset the rot_cw byte.
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
; Stack Depth:          0 bytes.
;
; Author:               Gavin Hua
; Last Modified:        5/4/2024

RotCW:
    CheckPressFlag  rot_cw


; DebounceTimerIRQ
;
; Description:          This procedure is called at a periodic interval to 
;                       debounce the input switches and the rotary encoder.
; Operation:            This procedure will debounce the switches and the rotary
;                       encoders by waiting for the signals to settle for the 
;                       former, and recording thesequences of events for the 
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
; Shared Variables:     The debounce counters, the pressed flags, and the state
;                       of the rotary encoder are updated.
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
; Data Structures:      A length 4 array of 2-bits, stored in rot_state.
;
; Registers changed:    None. (SREG, r16..r23 are restored)
;
; Stack Depth:          8 bytes.
;
; Author:               Gavin Hua
; Last Modified:        5/4/2024

DebounceButtons:

CheckStart:
    lds     r18, start_cnt
    ldi     r19, START_BTN_MASK
    rcall   CheckBtn
    sts     start_cnt, r18
    lds     r18, start_pressed
    or      r18, r19
    sts     start_pressed, r18
    ; rjmp  CheckMode

CheckMode:
    lds     r18, mode_cnt
    ldi     r19, MODE_BTN_MASK
    rcall   CheckBtn
    sts     mode_cnt, r18
    lds     r18, mode_pressed
    or      r18, r19
    sts     mode_pressed, r18
    ; rjmp  CheckRot

CheckRot:
    lds     r18, rot_cnt
    ldi     r19, ROT_BTN_MASK
    rcall   CheckBtn
    sts     rot_cnt, r18
    lds     r18, rot_pressed
    or      r18, r19
    sts     rot_pressed, r18
    ; rjmp  CheckEnc

CheckEnc:
    in      r20, BUTTON_DATA
    andi    r20, ENC_MASK    ; r20 stores the GPIO encoder reading
    lsl     r20                          ; align the reading with state[5:4]
    lds     r21, rot_state    ; r21 stores the past rotation states
    mov     r22, r21         ; r22 stores the two bits of interest
    andi    r22, ENC_BOUNCE_MASK
    cp      r22, r20
    brne    EncNoBounce
    ; BREQ  EncBounced

EncBounced:
    rjmp    DebounceButtonsEnd

EncNoBounce:
    mov     r22, r21
    andi    r22, ENC_PREV_MASK
    lsl     r20
    lsl     r20                         ; align current with state[7:6]
    cp      r22, r20
    breq    DebounceButtonsEnd          ; no change in the encoder state
    ; brne  EncUpdateState

EncUpdateState:
    lsr     r21 
    lsr     r21                         ; shift state to right to make room for new reading
    add     r21, r20
    sts     rot_state, r21
    ; rjmp    EncCheckCW

EncCheckCW:
    cpi     r21, ENC_CW_TURN
    brne	EncCheckCCW
    ; breq    SetRotCW

SetRotCW:
    ldi     r19, TRUE
    sts     rot_cw, r19
    ldi     r21, ENC_INIT_STATE
    sts     rot_state, r21
    rjmp	DebounceButtonsEnd

EncCheckCCW:
    cpi     r21, ENC_CCW_TURN
    brne	DebounceButtonsEnd
    ; breq SetRotCCW

SetRotCCW:
    ldi     r19, TRUE
    sts     rot_ccw, r19
    ldi     r21, ENC_INIT_STATE
    sts     rot_state, r21
    ; rjmp  DebounceButtonsEnd

DebounceButtonsEnd:
    ret


; r19 - mask, r18 - current_t
; return: r18 - current_t, r19 - pressed?
;--------------------------------------------------------------
CheckBtn:
    in      r16, BUTTON_DATA  ; r16 holds the current state of the buttons
    mov     r17, r16    ; r17 holds the bits of interest
    and     r17, r19     ; mask the bits of interest
    breq    BtnDown
    ; brne  BtnUp

BtnUp:
    ldi     r18, DEBOUNCE_T
    ldi     r19, FALSE
    rjmp    CheckBtnEnd

BtnDown:
    ldi     r19, FALSE
    dec     r18
    brne    CheckBtnEnd
    ; breq  SetBtnPressed

SetBtnPressed:
    ldi     r18, AUTOREP_T
    ldi     r19, TRUE
    ; rjmp  CheckBtnEnd

CheckBtnEnd:
    ret
;--------------------------------------------------------------
