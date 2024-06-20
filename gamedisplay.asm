;-------------------------------------------------------------------------------
; gamedisplay.asm
;
; Description:
;   This file contains the functions to display the game state on the 7-segment
;   display and game LEDs.
;
; Public Functions:
;   DisplayGameState - displays the entire game state
;   DisplayTime - displays the game time on the 7-segment display
;   DisplayBound - displays the upper and lower bounds on the game LEDs
;   DisplayBall - displays the ball on the game LEDs
;
; Author:
; 	Gavin Hua
;
; Revision History: 
;	2024/06/14 - Initial revision
;	2024/06/19 - Update comments
;-------------------------------------------------------------------------------



.cseg

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
; Shared Variables:     ball_pos - read only
;                       size_set - read only
;                       bound_set - read only
;                       game_time - read only
;                       curr_src_patterns - read/write (to display the bounds)
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
; Registers Used:       r13, r14, r15, r16, r17, r18, r19, r20, Y, Z, SREG

; Author:               Gavin Hua
; Last Modified:        2024/06/19

DisplayGameState:
    rcall   ClearDisplay    ; clear all displays for a fresh start
    rcall   DisplayBound    ; display the upper and lower bounds
    rcall   DisplayTime     ; display the game time
    rcall   DisplayBall     ; display the ball
    ret                     ; all done, return



;-------------------------------------------------------------------------------
; DisplayTime
;
; Description:          This procedure displays the game time on the 7-segment
;                       display.
; Operation:            The game time is loaded from the game_time variable
;                       and passed to the DisplayHex procedure to display the
;                       time on the 7-segment display.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     game_time - read only
;                       curr_src_patterns - read/write
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
; Registers Used:       r16, r17, r18, r19, r20, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

DisplayTime:
    lds     r16, game_time  ; load the game time
    clr     r17             ; the game time is a single byte so we clear r17
    rcall   DisplayHex      ; to display 00 for the upper digits
    ret                     ; all done, return



;-------------------------------------------------------------------------------
; DisplayBound
;
; Description:          This procedure displays the upper and lower bounds on
;                       the game LEDs.
; Operation:            The upper bound is computed by calling ComputeUpperBound
;                       and is then displayed by calling DisplayGameLED. The
;                       lower bound is computed by calling ComputeLowerBound
;                       and is then displayed by calling DisplayGameLED.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     bound_set - read only
;                       curr_src_patterns - read/write (to display the bounds)
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
; Registers Used:       r16, r17, r18, r19, r20, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

DisplayBound:
    rcall   ComputeUpperBound   ; compute the upper bound in r16
    ldi     r17, TRUE           ; set the display to on
    rcall   DisplayGameLED      ; display the upper bound
    rcall   ComputeLowerBound   ; compute the lower bound in r16
    ldi     r17, TRUE           ; set the display to on
    rcall   DisplayGameLED      ; display the lower bound
    ret                         ; all done, return



;-------------------------------------------------------------------------------
; DisplayBound
;
; Description:          This procedure displays the ball on the game LEDs.
; Operation:            The ball position is loaded from the ball_pos variable
;                       and the size of the ball is loaded from the size_set
;                       variable. The upper and lower bounds are computed by
;                       subtracting the size of the ball from the ball position
;                       and adding the size of the ball to the ball position,
;                       respectively. The bounds and interior of the ball are
;                       displayed by calling DisplayGameLED.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     ball_pos - read only
;                       size_set - read only
;                       bound_set - read only
;                       curr_src_patterns - read/write (to display the bounds)
; Local Variables:      radius (r13) - the radius of the ball
;                       upper_bound (r14) - the upper bound of the ball
;                       lower_bound (r15) - the lower bound of the ball
;                       loop_counter (r15) - loop counter to display the ball
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r13, r14, r15, r16, r17, r18, r19, r20, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19
DisplayBall:
    lds     r15, ball_pos           ; load the ball position
    lds     r13, size_set           ; load the size of the ball
    dec     r13                     ; the radius of the ball (0->1 LED, 1->3 LEDs, etc.)
    mov     r14, r13                ; r13 will be used again later so we create a copy
    add     r14, r15                ; upper bound (ball position + radius)
    mov     r16, r14                ; we avoided using r16 since DisplayGameLED 
                                    ; destroys it. We make a copy now because
                                    ; CPI only works on the upper registers.
    cpi     r16, GAME_LED_IDX_MAX   ; check if greater than the maximum index
    brlo    DisplayBallLoopInit     ; if not, continue
    ; brsh DisplayBallCapUpperBound ; if so, cap its value

DisplayBallCapUpperBound:
    ldi     r16, GAME_LED_IDX_MAX   ; set upper bound to the rightmost game LED
    mov     r14, r16                ; copy it back to r14
    ; rjmp DisplayBallLoopInit

DisplayBallLoopInit:
    sub     r15, r13                ; compute lower bound/init loop counter
    dec     r15                     ; decrement because loop increments first
    ; rjmp DisplayBallLoop

DisplayBallLoop:
    inc     r15                     ; increment loop counter
    mov     r16, r15                ; set up call to DisplayGameLED
    ldi     r17, TRUE               ; set the display to on
    rcall   DisplayGameLED          ; display one LED of the ball
    cp      r15, r14                ; check current LED against the upper bound
    brne    DisplayBallLoop         ; if not equal, continue
    ; rjmp DisplayBallEnd           ; if equal, we're done

DisplayBallEnd:
    ret                             ; all done, return
