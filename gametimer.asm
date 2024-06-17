InitGameTimers:
    rcall   StartGameTimer
    rcall   StartStatusTimer
    rcall   StartRandomEventTimer
    rcall   StartSoundTimer
    ret

;-------------------------------------

GameTimerHandler:
    lds     r16, game_time
    lds     r17, mode
    cpi     r17, TIMED
    breq UpdateGameTimeModeTimed
    ; brne UpdateGameTimeModeInfinite

UpdateGameTimeModeInfinite:
    inc     r16
    rjmp    UpdateGameTimeEnd

UpdateGameTimeModeTimed:
    dec     r16
    ; rjmp UpdateGameTimeEnd

UpdateGameTimeEnd:
    sts     game_time, r16
    rcall   StartGameTimer
    ret

;-------------------------------------

StatusTimerHandler:

    rcall   GetAccelX
    swap    r17
    andi    r17, LOW_HEX_DIG
    wordTabOffsetZ IMU_TO_BALL_ACCEL, r17   ; half-byte accuracy is enough
    lpm     r16, Z                          ; r16 = acceleration in ball units
    lds     r17, gravity
    muls    r16, r17
    mov     r17, r0                         ; r17 = k_grav * acceleration
    lds     r16, velocity                   ; r16 = velocity (int value)
    add     r16, r17                        ; r16 = new velocity
    ; rjmp UpdateBallPos

UpdateBallPos:
    lds     r17, ball_pos_frac
    add     r16, r17
    clr     r17
    ldi     r20, BALL_POS_FRAC_MAX
    rcall   Div16by8
    sts     ball_pos_frac, r2
    lds     r17, ball_pos
    add     r17, r16
    sts     ball_pos, r17
    ; rjmp CheckWinLose

CheckWinLose:
    rcall   ComputeUpperBound
    lds     r17, ball_pos
    cp      r17, r16
    brsh    CallLoseGame
    rcall   ComputeLowerBound
    lds     r17, ball_pos
    cp      r17, r16
    brlo    CallLoseGame
    lds     r16, game_time
    cpi     r16, 0
    brlo    CallWinGame
    rjmp    StatusTimerHandlerEnd    ; neither win nor lose, continue game

CallLoseGame:
    rcall   LoseGame
    rjmp    StatusTimerHandlerEnd

CallWinGame:
    rcall   WinGame
    ; rjmp StatusTimerHandlerEnd

StatusTimerHandlerEnd:
    rcall   StartStatusTimer
    rcall   DisplayGameState
    ret

;-------------------------------------

RandomEventTimerHandler:
    rcall   Random

UpdateInvisible:
    lds     r16, lfsr
    andi    r16, 0x07
	lds     r17, f_invis_set
    cp      r16, r17
    brlo    SetInvisible
    ; brge ClearInvisible

SetInvisible:
    ldi     r16, TRUE
    sts     is_invisible, r16
    rjmp    UpdateRandomV

ClearInvisible:
    ldi     r16, FALSE
    sts     is_invisible, r16
    ; rjmp UpdateRandomV

UpdateRandomV:
    rcall   Random
    lds     r16, lfsr
    clr     r17
    lds     r20, random_v
    rcall   Div16by8
    lds     r16, velocity
    lds     r17, lfsr+1
    tst     r17
    breq AddRandomV
    ; brne NegRandomV

NegRandomV:
    neg     r2

AddRandomV:
    add     r16, r2
    sts     velocity, r16
    ; rjmp SpawnRandomEventEnd

SpawnRandomEventEnd:
    rcall   StartRandomEventTimer
    ret



;-------------------------------------
StartGameTimer:
    ldi     XL, low(GAME_TIMER_PERIOD)
    ldi     XH, high(GAME_TIMER_PERIOD)
    ldi     r16, GAME_TIMER_IDX
    rcall   StartDelay
    ret

;-------------------------------------

StartStatusTimer:
    ldi     XL, low(STATUS_TIMER_PERIOD)
    ldi     XH, high(STATUS_TIMER_PERIOD)
    ldi     r16, STATUS_TIMER_IDX
    rcall   StartDelay
    ret

;-------------------------------------
StartRandomEventTimer:
    ldi     XL, low(RANDOM_EVENT_TIMER_PERIOD)
    ldi     XH, high(RANDOM_EVENT_TIMER_PERIOD)
    ldi     r16, RANDOM_EVENT_TIMER_IDX
    rcall   StartDelay
    ret

;-------------------------------------
StartSoundTimer:
    ldi     XL, low(SOUND_TIMER_PERIOD)
    ldi     XH, high(SOUND_TIMER_PERIOD)
    ldi     r16, SOUND_TIMER_IDX
    rcall   StartDelay
    ret

IMU_TO_BALL_ACCEL:
    .db 0, 0