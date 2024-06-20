; InitGameTimers:
;     rcall   StartGameTimer
;     rcall   StartStatusTimer
;     rcall   StartRandomEventTimer
;     rcall   StartSoundTimer
;     ret

; ;-------------------------------------

; GameTimerHandler:
;     lds     r16, game_time
;     lds     r17, mode
;     cpi     r17, TIMED
;     breq UpdateGameTimeModeTimed
;     ; brne UpdateGameTimeModeInfinite

; UpdateGameTimeModeInfinite:
;     inc     r16
;     rjmp    UpdateGameTimeEnd

; UpdateGameTimeModeTimed:
;     dec     r16
;     ; rjmp UpdateGameTimeEnd

; UpdateGameTimeEnd:
;     sts     game_time, r16
;     rcall   StartGameTimer
;     ret

; ;-------------------------------------

; StatusTimerHandler:
;     rcall   DisplayGameState

;     rcall   GetAccelY
;     neg     r17
;     mov     r16, r17
;     asr     r16
;     asr     r16
;     asr     r16
;     asr     r16

;     lds     r17, gravity_set
;     muls    r16, r17
;     mov     r16, r0                         ; r17 = k_grav * acceleration

;     lds     r17, velocity                   ; r16 = velocity (int value)
;     add     r16, r17                        ; r16 = new velocity
;     sts     velocity, r16
;     ; rjmp UpdateBallPos

; UpdateBallPos:
;     lds     r17, ball_pos_frac
;     add     r16, r17
;     ldi     r17, BALL_POS_FRAC_MAX
;     rcall   div8s   ; r15 = r16 % r17, r16 = r16 / r17
;     sts     ball_pos_frac, r15
;     lds     r17, ball_pos
;     add     r17, r16
;     sts     ball_pos, r17
;     ; rjmp CheckWinLose

; CheckWinLose:
;     rcall   ComputeUpperBound
;     lds     r17, ball_pos
;     cp      r17, r16
;     brsh    CallLoseGame
;     rcall   ComputeLowerBound
;     lds     r17, ball_pos
;     cp      r17, r16
;     brlo    CallLoseGame
;     lds     r16, mode
;     cpi     r16, TIMED
;     brne    StatusTimerHandlerEnd
;     lds     r16, game_time
;     tst     r16
;     breq    CallWinGame
;     rjmp    StatusTimerHandlerEnd    ; neither win nor lose, continue game

; CallLoseGame:
;     rcall   LoseGame
;     rjmp    StatusTimerHandlerEnd

; CallWinGame:
;     rcall   WinGame
;     ; rjmp StatusTimerHandlerEnd

; StatusTimerHandlerEnd:
;     rcall   StartStatusTimer
;     ret

; ;-------------------------------------

; RandomEventTimerHandler:
;     rcall   Random
;     lds     r16, lfsr
;     clr     r17
;     lds     r20, random_v_set
;     tst     r20
;     breq    RandomEventTimerHandlerEnd
;     rcall   Div16by8
;     lds     r17, lfsr+1
;     tst     r17
;     breq AddRandomV
;     ; brne NegRandomV

; NegRandomV:
;     neg     r2

; AddRandomV:
;     lds     r16, velocity
;     add     r16, r2
;     sts     velocity, r16
;     ; rjmp RandomEventTimerHandlerEnd

; RandomEventTimerHandlerEnd:
;     rcall   StartRandomEventTimer
;     ret



; ;-------------------------------------
; StartGameTimer:
;     ldi     XL, low(GAME_TIMER_PERIOD)
;     ldi     XH, high(GAME_TIMER_PERIOD)
;     ldi     r16, GAME_TIMER_IDX
;     rcall   StartDelay
;     ret

; ;-------------------------------------

; StartStatusTimer:
;     ldi     XL, low(STATUS_TIMER_PERIOD)
;     ldi     XH, high(STATUS_TIMER_PERIOD)
;     ldi     r16, STATUS_TIMER_IDX
;     rcall   StartDelay
;     ret

; ;-------------------------------------
; StartRandomEventTimer:
;     ldi     XL, low(RANDOM_EVENT_TIMER_PERIOD)
;     ldi     XH, high(RANDOM_EVENT_TIMER_PERIOD)
;     ldi     r16, RANDOM_EVENT_TIMER_IDX
;     rcall   StartDelay
;     ret

; ;-------------------------------------
; StartSoundTimer:
;     ldi     XL, low(SOUND_TIMER_PERIOD)
;     ldi     XH, high(SOUND_TIMER_PERIOD)
;     ldi     r16, SOUND_TIMER_IDX
;     rcall   StartDelay
;     ret
