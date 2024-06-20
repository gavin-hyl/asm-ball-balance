;-------------------------------------
;-------------------------------------


; DisplayGameState
;
; Description:          This procedure calls several other procedures to display
;                       the game state on the 7-segment display and game LEDs.
; Operation:            This procedure calls ClearDisplay to clear the 7-segment
;                       display, DisplayBound to display the upper and lower
;                       bounds, DisplayTime to display the game time, and
;                       DisplayBall to display the ball on the game LEDs.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     
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
; Registers Used:       r0, r16, X, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19
DisplayGameState:
    rcall   ClearDisplay
    rcall   DisplayBound
    rcall   DisplayTime
    rcall   DisplayBall
    ret


;-------------------------------------
DisplayTime:
    lds     r16, game_time
    clr     r17
    rcall   DisplayHex
    ret

;-------------------------------------
DisplayBound:
    rcall   ComputeUpperBound
    ldi     r17, TRUE
    rcall   DisplayGameLED
    rcall   ComputeLowerBound
    ldi     r17, TRUE
    rcall   DisplayGameLED
    ret
;-------------------------------------
; no argument and no return value
DisplayBall:
    lds     r15, ball_pos
    lds     r13, size_set
    dec     r13         ; the radius of the ball (0 -> 1 LED, 1 -> 3 LEDs, etc.)
    mov     r14, r13    ; r13 will be used again later so we create a copy
    add     r14, r15    ; upper bound
    mov     r16, r14
    cpi     r16, GAME_LED_IDX_MAX   ; check if greater than the maximum index
    brlo    DisplayBallLoopInit
    ; brsh DisplayBallCapUpperBound

DisplayBallCapUpperBound:
    ldi     r16, GAME_LED_IDX_MAX   ; if so, cap it
    mov     r14, r16
    ; rjmp DisplayBallLoopInit

DisplayBallLoopInit:
    sub     r15, r13    ; lower bound
    dec     r15         ; subtract 1 because we increment first in the loop

DisplayBallLoop:
    inc     r15
    mov     r16, r15    ; we avoid using r16 becuase DisplayGameLED destroys it
    ldi     r17, TRUE
    rcall   DisplayGameLED
    cp      r15, r14
    brne    DisplayBallLoop
    ; rjmp DisplayBallEnd

DisplayBallEnd:
    ret
