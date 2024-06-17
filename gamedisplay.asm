;-------------------------------------

DisplayGameState:
    rcall   ClearDisplay
    rcall   DisplayBound
    rcall   DisplayTime
    lds     r16, is_invisible
	cpi     r16, TRUE
	breq    DisplayGameStateEnd
    rcall   DisplayBall

DisplayGameStateEnd:
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

DisplayBall:
    lds     r16, ball_pos
    lds     r18, size_set
    dec     r18         ; the radius of the ball (0 -> 1 LED, 1 -> 3 LEDs, etc.)
    mov     r19, r18
    add     r19, r16    ; upper bound
    cpi     r19, GAME_LED_IDX_MAX
    brlo    DisplayBallLoopInit
    ; brsh DisplayBallCapUpperBound

DisplayBallCapUpperBound:
    ldi     r19, GAME_LED_IDX_MAX
    ; rjmp DisplayBallLoopInit

DisplayBallLoopInit:
    sub     r16, r18    ; lower bound
    dec     r16         ; subtract 1 because we increment first in the loop
    ldi     r17, TRUE

DisplayBallLoop:
    inc     r16
    rcall   DisplayGameLED
    cpse    r16, r19
    rjmp    DisplayBallLoop
    ; rjmp DisplayBallEnd

DisplayBallEnd:
    ret
