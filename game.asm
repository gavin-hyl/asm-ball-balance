.dseg
ball_pos:       .byte 1
ball_pos_frac:  .byte 1
velocity:       .byte 1
game_time:      .byte 1
is_invisible:   .byte 1
in_game:        .byte 1


.cseg

;-------------------------------------
; Initialize game variables and start all timers
InitGame:
    ldi     r16, FALSE
    sts     in_game, r16
    ldi     r16, START_POS
    sts     ball_pos, r16
    ldi     r16, INFINITE
    sts     mode, r16
    ldi     r16, 0
    sts     game_time, r16
    sts     ball_pos_frac, r16
    sts     velocity, r16
    ldi     r16, DISP_ON_T_INIT
    sts     display_on_t, r16
    ldi     r16, DISP_OFF_T_INIT
    sts     display_off_t, r16
    ret

;-------------------------------------
GameLoop:
    rcall  StartPress
    breq   LoseGame

    ldi     r16, STATUS_TIMER_IDX
    rcall   DelayNotDone
	brne    GameCheckGameTimer
    rcall   StatusTimerHandler

GameCheckGameTimer:
    ldi     r16, GAME_TIMER_IDX
    rcall   DelayNotDone
	brne    GameCheckRandomEventTimer
    rcall   GameTimerHandler

GameCheckRandomEventTimer:
    ldi     r16, RANDOM_EVENT_TIMER_IDX
    rcall   DelayNotDone
	brne    GameCheckSoundTimer
    rcall   RandomEventTimerHandler

GameCheckSoundTimer:
    ldi     r16, SOUND_TIMER_IDX
    rcall   DelayNotDone
	brne    GameLoopEnd
    rcall   SoundTimerHandler
    
GameLoopEnd:
    rcall  ClearButtons
    ret

;-------------------------------------
StartGame:
    ldi     r16, TRUE
    sts     in_game, r16
    sts     repeat, r16
    PlaySequence GameMusic   ; play game music on repeat
    ldi     r16, START_POS      ; set ball position to start position
    sts     ball_pos, r16
    clr     r0
    sts     game_time, r0       ; reset game time, possibly set to setting time later
    lds     r17, time_set
    lds     r16, mode           ; check if mode is infinite
    ldi     r18, INFINITE
    cpse    r16, r18           ; if mode is not infinite
    sts     game_time, r17      ; set game time to timed mode time
    ret

;-------------------------------------

LoseGame:
    ldi     r16, FALSE
    sts     in_game, r16
    sts     repeat, r16
    PlaySequence LoseMusic
    ldi     r16, LOSE
    rcall   DisplayMessage
    ; rcall DISPLAY?

PlaySequenceLoop:
    ldi     r16, BLINK_TIME
    sts     display_on_t, r16
    sts     display_off_t, r16
    lds     r16, playing_sequence
    cpi     r16, TRUE
    breq PlaySequenceLoop
    ; brne LoseGameEnd

LoseGameEnd:
    rcall   ClearDisplay
    ldi     r16, MAX_BRIGHTNESS
    sts     display_on_t, r16
    clr     r0
    sts     display_off_t, r0
    ldi     r16, FALSE
    sts     in_game, r16
    ret

;-------------------------------------

WinGame:
    ldi     r16, FALSE
    sts     in_game, r16
    sts     repeat, r16
    PlaySequence WinMusic
    ldi     r16, WIN
    rcall   DisplayMessage

WaitSequenceLoop:
    lds     r16, playing_sequence
    cpi     r16, TRUE
    breq    WaitSequenceLoop
    ; brne WinGameEnd

WinGameEnd:
    rcall   ClearDisplay
    ret


ComputeUpperBound:
	lds     r16, MIDDLE_LED
    lds     r17, bound_set
    add     r16, r17
    ret


ComputeLowerBound:
    lds     r16, MIDDLE_LED
    lds     r17, bound_set
    sub     r16, r17
    ret
