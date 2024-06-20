;-------------------------------------------------------------------------------
; game.asm
;
; Description:
;	This file contains the functions to initialize, win, and lose the game, as
;   well as several utility functions and timer handlers for the game.
;
; Public Functions:
;	InitGame - Initializes the game variables.
;   StartGame - Handles starting a game
;   GameLoop - Function to be called by the main loop while in the game
;   LoseGame - Handles losing a game
;   WinGame - Handles winning a game
;   ComputeUpperBound - Returns the upper bound of the safe zone
;   ComputeLowerBound - Returns the lower bound of the safe zone
;   StartGameTimer - Starts the game time timer
;   StartStatusTimer - Starts the status update timer
;   StartRandomEventTimer - Starts the random event timer
;   GameTimerHandler - Handles the game time timer expiration
;   StatusTimerHandler - Handles the status update timer expiration
;   RandomEventTimerHandler - Handles the random event timer expiration
;
; Author:
; 	Gavin Hua
;
; Revision History: 
;	2024/06/15 - Initial revision
;	2024/06/19 - Update comments
;-------------------------------------------------------------------------------

.dseg

ball_pos:       .byte 1     ; integer part of the ball position (0~69 in LEDs)
ball_pos_frac:  .byte 1     ; fractional part of the position (-10~10 in LEDs)
velocity:       .byte 1     ; velocity in number of LEDs per second (integer)
                            ; we achieve granularity by using a fractional part
                            ; and expecting position updates at 10 Hz.
game_time:      .byte 1     ; if mode is TIMED: remaining game time in seconds
                            ; if mode is INFINITE: time elapsed in seconds
                            ; the maximum time is 255 seconds.
in_game:        .byte 1     ; if TRUE, call game loop, otherwise call menu loop



;-------------------------------------------------------------------------------
.cseg

; InitGame
;
; Description:          This procedure initializes select game variables to set
;                       up the UI. This function should be called once during
;                       the initialization before the main loop.
; Operation:            This procedure sets the game variables to their
;                       corresponding initial values.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     in_game - set to FALSE
;                       mode - set to INFINITE
;                       ball_pos - set to START_POS
;                       ball_pos_frac - set to 0
;                       velocity - set to 0
;
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
; Registers Used:       r16, Y
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19
; Notes:                There is no critical code here since interrupts are
;                       disabled during initialization.

InitGame:
    ldi     r16, FALSE
    sts     in_game, r16    ; not in game, initial UI is menu

    ldi     r16, INFINITE
    sts     mode, r16       ; initial game mode is infinite

    rcall   InitBallPos     ; initialize for display purposes (r0, r16 changed)
    ret                     ; all done, return



;-------------------------------------------------------------------------------
; InitBallPos
;
; Description:          This procedure initializes variables related to the
;                       ball's position and movement.
; Operation:            This procedure sets the game variables to their
;                       corresponding initial values.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     ball_pos - set to START_POS
;                       ball_pos_frac - set to 0
;                       velocity - set to 0
;
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
; Registers Used:       r0, r16
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

InitBallPos:
    ldi     r16, START_POS      ; prepare to set shared variables
    clr     r17                 ; loading values into registers is not critical
    in      r0, SREG            ; critical code start
    cli
    sts     ball_pos, r16       ; set ball_pos to START_POS
    sts     ball_pos_frac, r17  ; set ball_pos_frac to 0
    sts     velocity, r17       ; set velocity to 0
    out     r0                  ; critical code end
    ret                         ; all done, return



;-------------------------------------------------------------------------------
; StartGame
;
; Description:          This procedure initializes the game variables to start
;                       the game, according to the mode. It also plays the game
;                       music on repeat.
; Operation:            This procedure sets all the game variables to their
;                       corresponding initial values according to the mode. It
;                       also sets the repeat flag, and initializes the music
;                       player to play the game music.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     in_game - set to TRUE
;                       ball_pos - set to START_POS
;                       velocity - set to 0
;                       ball_pos_frac - set to 0
;                       game_time - set to time_set if mode is TIMED else 0
;                       delay_timer - the words corresponding to the game time
;                                     timer, status update timer, and random
;                                     event timer are set to their respective 
;                                     periods
;
; Local Variables:      tmp (r16) - used to hold values to store into variables
;                       time_set (r17)
;                       
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

StartGame:
    rcall   ClearDisplay            ; clear any remaining settings display

    ldi     r16, TRUE
    sts     in_game, r16            ; main loop now calls game loop
    
    rcall   InitBallPos             ; center ball and clear velocity

    clr     r0                      ; reset game time
    sts     game_time, r0           ; (possibly set to time_set later)

    lds     r16, mode
    cpi     r16, INFINITE           ; check if mode is infinite
    breq    StartGamePlaySequence   ; if it is, then directly play music
    ; brne  StartGameSetTime        ; if not, set the game time to time_set

StartGameSetTime:
    lds     r17, time_set
    sts     game_time, r17          ; set game time to timed mode time
    ; rjmp  StartGamePlaySequence

StartGamePlaySequence:
    ldi     r16, TRUE
    sts     repeat, r16             ; play music on repeat
    clr     r16                     ; set up PlaySequence call
    wordTabOffsetZ GameMusic, r16   ; by pointing Z to GameMusic's start
    rcall PlaySequence              ; play GameMusic sequence

    rcall   StartGameTimer          ; toggle game time updates
    rcall   StartStatusTimer        ; toggle game status updates
    rcall   StartRandomEventTimer   ; toggle random events

    ret                             ; all done, return



;-------------------------------------------------------------------------------
; GameLoop
;
; Description:          This procedure handles software timer expirations and
;                       button presses while the user is in the game.
; Operation:            This procedure polls the software timers and the Start
;                       button and calls the corresponding handlers.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     in_game - set to TRUE
;                       ball_pos - set to START_POS
;                       velocity - set to 0
;                       ball_pos_frac - set to 0
;                       game_time - set to time_set if mode is TIMED else 0
;                       delay_timer - read/write
;
; Local Variables:      tmp (r16) - used to hold timer indices
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r0, r16, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

GameLoop:
    rcall  StartPress                   ; check if start is pressed
    breq   LoseGame                     ; if so, then the user lost the game

GameCheckSoundTimer:
    ldi     r16, SOUND_TIMER_IDX        ; prepare to check sound timer
    rcall   DelayNotDone                ; check sound timer delay, elapsed
	brne    GameCheckStatusTimer        ; if not, then check status timer
    rcall   SoundTimerHandler           ; otherwise, call the handler

GameCheckStatusTimer:
    ldi     r16, STATUS_TIMER_IDX       ; prepare to check status update timer
    rcall   DelayNotDone                ; check status update timer delay
	brne    GameCheckGameTimer          ; if not, then check time update
    rcall   StatusTimerHandler          ; otherwise, call the handler

GameCheckGameTimer:
    ldi     r16, GAME_TIMER_IDX         ; prepare to check the game time timer
    rcall   DelayNotDone                ; check game time timer delay elapsed
	brne    GameCheckRandomEventTimer   ; if not, then check rng event timer
    rcall   GameTimerHandler            ; otherwise, call the handler

GameCheckRandomEventTimer:
    ldi     r16, RANDOM_EVENT_TIMER_IDX ; prepare to check the rng event timer
    rcall   DelayNotDone                ; check rng event timer elapsed
	brne    GameLoopEnd                 ; if not, we are done
    rcall   RandomEventTimerHandler     ; otherwise, call the handler
    
GameLoopEnd:
    ret                                 ; all done, return



;-------------------------------------------------------------------------------
; LoseGame
;
; Description:          This procedure handles losing a game by exiting the game,
;                       playing the lose music, and blinking the lose message.
; Operation:            This procedure clears the display, plays lose music once,
;                       displays the lose message and sets the display_on/off_t
;                       variables, waits for the music to end, resets the
;                       display and returns.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     in_game - set to FALSE
;                       repeat - set to FALSE
;                       curr_sequence - set to LoseMusic
;                       curr_src_patterns - SEG_BUF set to message, others to 0
;                       ball_pos - set to START_POS
;                       ball_pos_frac - set to 0
;                       velocity - set to 0
;
; Local Variables:      
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r0, r16, r17, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

LoseGame:
    rcall   ClearDisplay                ; clear remaining game display
    ldi     r16, FALSE
    sts     in_game, r16                ; set UI to menu
    sts     repeat, r16                 ; play LoseMusic once
    clr     r16                         ; prepare to set up the Z pointer
    wordTabOffsetZ LoseMusic, r16       ; point Z to the start of LoseMusic
    rcall   PlaySequence                ; to play that sequence
    ; PlaySequence LoseMusic
    ldi     r16, LOSE
    rcall   DisplayMessage              ; display the lose message
    ldi     r16, BLINK_TIME
    sts     display_on_t, r16           ; set the on and off time
    sts     display_off_t, r16          ; to blink the display
    ; rjmp    LoseGamePlaySequenceLoop

LoseGamePlaySequenceLoop:
    ldi     r16, SOUND_TIMER_IDX        ; prepare to check the sound timer
    rcall   DelayNotDone                ; check sound timer elapsed
    brne    LoseGamePlaySequenceLoop    ; if not, continue waiting for music end
    rcall   SoundTimerHandler           ; if so, call the sound hanldler

    lds     r16, playing_sequence       ; check whether we are still playing
    cpi     r16, TRUE
    breq    LoseGamePlaySequenceLoop    ; if so, continue waiting for music end
    ; brne LoseGameEnd

LoseGameEnd:
    ldi     r16, MAX_BRIGHTNESS
    sts     display_on_t, r16           ; reset the display to max brightness
    ldi     r16, 0
    sts     display_off_t, r16          ; and no blinking
    rcall   InitSound                   ; turn off the speaker
    rcall   InitBallPos                 ; init position variables for menu UI
    ret                                 ; all done, return



;-------------------------------------------------------------------------------
; WinGame
;
; Description:          This procedure handles winning a game by exiting the
;                       game, playing the win music, and showing the win message.
; Operation:            This procedure clears the display, plays win music once,
;                       displays the win message and sets, waits for the music
;                       to end, resets the display and returns.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     in_game - set to FALSE
;                       repeat - set to FALSE
;                       curr_sequence - set to WinMusic
;                       curr_src_patterns - SEG_BUF set to message, others to 0
;                       ball_pos - set to START_POS
;                       ball_pos_frac - set to 0
;                       velocity - set to 0
;
; Local Variables:      
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r0, r16, r17, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

WinGame:
    rcall   ClearDisplay            ; clear remaining game display
    ldi     r16, FALSE
    sts     in_game, r16            ; set UI to menu
    sts     repeat, r16             ; play WinMusic once
    clr     r0                      ; prepare to offset the Z pointer
    wordTabOffsetZ WinMusic, r0     ; point Z to the start of WinMusic
    rcall   PlaySequence            ; play WinMusic
    ldi     r16, WIN
    rcall   DisplayMessage          ; display the win message
    ; rjmp    WinGameEnd

WinGameWaitSequenceLoop:
    ldi     r16, SOUND_TIMER_IDX    ; prepare to check the sound timer
    rcall   DelayNotDone            ; check sound timer elapsed
    brne    WinGameWaitSequenceLoop ; if not, continue waiting for music end
    rcall   SoundTimerHandler       ; if so, call the sound handler

    lds     r16, playing_sequence   ; check whether we are still playing
    cpi     r16, TRUE
    breq    WinGameWaitSequenceLoop ; if so, continue waiting for music end
    ; brne WinGameEnd

WinGameEnd:
    rcall   InitSound               ; turn off the speaker
    rcall   InitBallPos             ; init position variables for menu UI 
    ret



;-------------------------------------------------------------------------------
; GameTimerHandler
;
; Description:          This procedure should be called when the game time timer
;                       elapses, which should be approximately every 1 second.
; Operation:            This procedure decrements the game time if the mode is
;                       TIMED, and increments the game time if the mode is
;                       INFINITE. It then calls StartGameTimer to restart the
;                       timer.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     game_time - updated
;                       mode - read only
;                       delay_timer - word corresponding to the game time timer
;                                     is set to GAME_TIMER_PERIOD
; Local Variables:      
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r0, r16, r17, X, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

GameTimerHandler:
    lds     r16, game_time              ; get the current game time
    lds     r17, mode                   ; get the current game mode
    cpi     r17, TIMED                  ; check if the mode is timed
    breq UpdateGameTimeModeTimed        ; if so, decrement the game time
    ; brne UpdateGameTimeModeInfinite   ; if not, increment the game time

UpdateGameTimeModeInfinite:
    inc     r16                         ; increment the game time
    rjmp    UpdateGameTimeEnd           ; and continue

UpdateGameTimeModeTimed:
    dec     r16                         ; decrement the game time
    ; rjmp UpdateGameTimeEnd

UpdateGameTimeEnd:
    sts     game_time, r16              ; store the new game time
    rcall   StartGameTimer              ; restart the game time timer
    ret                                 ; all done, return



;-------------------------------------------------------------------------------
; StatusTimerHandler
;
; Description:          This procedure should be called when the game time timer
;                       elapses, which should be approximately every 0.1 second.
; Operation:            This procedure updates the game state by updating the
;                       ball's position and velocity, checking if the ball is
;                       within the safe zone, and checking if the game is won or
;                       lost. It then restarts the status update timer.
;
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     ball_pos - updated
;                       ball_pos_frac - updated
;                       velocity - updated
;                       gravity_set - read only
;                       bound_set - read only
;                       mode - read only
;                       delay_timer - word corresponding to the status update
;                                     timer is set to STATUS_TIMER_PERIOD
; Local Variables:      a_y (r16) - used to store 4 bits of the y-acceleration
;                       tmp (r17) - used to store the gravity set value, and
;                                   perform various comparisons.
; 
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r0, r15, r16, r17, X, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

StatusTimerHandler:
    rcall   DisplayGameState        ; display the previously updated state

    rcall   GetAccelY               ; get the y acceleration from the IMU
    neg     r17                     ; the ball's position should decrease
                                    ; when there's a positive y-acceleration
                                    ; so we negate the value
    mov     r16, r17                ; we ignore r16 from the IMU
    asr     r16                     ; we also ignore the low nibble of r17
    asr     r16                     ; so we shift r17 right four times
    asr     r16                     ; we need an arithmetic shift to keep
    asr     r16                     ; the sign bit

    lds     r17, gravity_set        ; get the gravity set value
    muls    r16, r17                ; r0 = k_grav * acceleration
    mov     r16, r0                 ; r16 = k_grav * acceleration

    lds     r17, velocity           ; r17 = original velocity (int value)
    add     r16, r17                ; r16 = new velocity
    sts     velocity, r16           ; store the new velocity
    ; rjmp UpdateBallPos

UpdateBallPos:
    lds     r17, ball_pos_frac      ; get the fractional part of the position
    add     r16, r17                ; add the new velocity to it. We can do this
                                    ; directly because the velocity is in 
                                    ; LEDs/s and the fractional position is in
                                    ; 0.1 LEDs, and the update is expected to
                                    ; be at 10 Hz (0.1 s), so the units match
    ldi     r17, BALL_POS_FRAC_MAX  ; prepare to check if the fractional part
                                    ; is out of bounds 
    rcall   div8s                   ; r15 = r16 % r17, r16 = r16 / r17 (avr200)
    sts     ball_pos_frac, r15      ; store the new fractional part
    lds     r17, ball_pos           ; get the integer part of the position
    add     r17, r16                ; add the integer position change to it
    sts     ball_pos, r17           ; and store it back
    ; rjmp CheckWinLose

CheckWinLose:
    rcall   ComputeUpperBound       ; get the upper bound of the safe zone
    lds     r17, ball_pos           ; get the ball's position
    cp      r17, r16                ; check if the ball is above the upper bound
    brsh    CallLoseGame            ; if so, the game is lost
    rcall   ComputeLowerBound       ; get the lower bound of the safe zone
    lds     r17, ball_pos           ; get the ball's position
    cp      r17, r16                ; check if the ball is below the lower bound
    brlo    CallLoseGame            ; if so, the game is lost
    lds     r16, mode               ; get the game mode
    cpi     r16, TIMED              ; check if the game mode is timed
    brne    StatusTimerHandlerEnd   ; if not, no more checks are needed
    lds     r16, game_time          ; if so, check if the game time is up
    tst     r16                     ; check if the game time is zero
    breq    CallWinGame             ; if so, the game is won
    rjmp    StatusTimerHandlerEnd   ; neither win nor lose, continue game

CallLoseGame:
    rcall   LoseGame                ; call the lose game handler
    rjmp    StatusTimerHandlerEnd   ; and return

CallWinGame:
    rcall   WinGame                 ; call the win game handler
    ; rjmp StatusTimerHandlerEnd    ; and return

StatusTimerHandlerEnd:
    rcall   StartStatusTimer        ; restart the status update timer
    ret                             ; all done, return



;-------------------------------------------------------------------------------
; RandomEventTimerHandler
;
; Description:          This procedure handles the random event timer. It adds
;                       a random velocity to the current velocity, which value
;                       is determined by the random number generator and 
;                       velocity set value.
; Operation:            This procedure generates a random number, and if the
;                       random velocity set value is non-zero, it adds/subtracts
;                       the random velocity to the current velocity, with the
;                       direction determined by the sign of the random number.
;                       It then restarts the timer.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     delay_timer - written (word corresponding to the random
;                                     event timer is set to the random event
;                                     timer period)
;                       lfsr - read/write (Fibonacci LFSR)
;                       random_v_set - read only
;                       velocity - read/write (random_v added to velocity)
; Local Variables:      random_v (r2) - used to store the random velocity to add
;                                       to the current velocity
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r0, r2, r16, X, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

RandomEventTimerHandler:
    rcall   Random                      ; generate a random number
    lds     r16, lfsr                   ; get the random number (first 8 bits)
    clr     r17                         ; prepare to divide by random_v_set
    lds     r20, random_v_set           ; get the random velocity set value
    tst     r20                         ; check if it is zero
    breq    RandomEventTimerHandlerEnd  ; if so, randomness is off, return
    rcall   Div16by8                    ; otherwise, calculate the random_v
    lds     r17, lfsr+1                 ; get lfsr[8] to determine sign
    tst     r17                         ; check if the random number is negative
    breq AddRandomV                     ; if not, add the random velocity
    ; brne NegRandomV                   ; if so, subtract the random velocity

NegRandomV:
    neg     r2                          ; negate the random velocity to avoid 
    ; rjmp  AddRanodomV                 ; code duplication (always add)

AddRandomV:
    lds     r16, velocity               ; get the current velocity
    add     r16, r2                     ; add the random velocity
    sts     velocity, r16               ; store the new velocity
    ; rjmp RandomEventTimerHandlerEnd

RandomEventTimerHandlerEnd:
    rcall   StartRandomEventTimer       ; restart the random event timer
    ret                                 ; all done, return



;-------------------------------------------------------------------------------
; StartGameTimer
;
; Description:          This procedure starts the game time timer.
; Operation:            This procedure calls StartDelay with the game time timer
;                       period.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     delay_timer - word corresponding to the game time timer
;                                     is set to GAME_TIMER_PERIOD
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

StartGameTimer:
    ldi     XL, low(GAME_TIMER_PERIOD)  ; prepare to start the game time timer
    ldi     XH, high(GAME_TIMER_PERIOD) ;   by setting X to its period
    ldi     r16, GAME_TIMER_IDX         ; and the timer index its index
    rcall   StartDelay                  ; start the timer
    ret                                 ; all done, return



;-------------------------------------------------------------------------------
; StartStatusTimer
;
; Description:          This procedure starts the status update timer.
; Operation:            This procedure calls StartDelay with the status update
;                       timer period.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     delay_timer - word corresponding to the status update
;                                     timer is set to STATUS_TIMER_PERIOD.
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

StartStatusTimer:
    ldi     XL, low(STATUS_TIMER_PERIOD)    ; prepare to start the status update
    ldi     XH, high(STATUS_TIMER_PERIOD)   ;   timer by setting X to its period
    ldi     r16, STATUS_TIMER_IDX           ; and the timer index its index
    rcall   StartDelay                      ; start the timer
    ret                                     ; all done, return



;-------------------------------------
; StartRandomEventTimer
;
; Description:          This procedure starts the random event timer.
; Operation:            This procedure calls StartDelay with the random event
;                       timer period.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     delay_timer - word corresponding to the random event
;                                     timer is set to RANDOM_EVENT_TIMER_PERIOD.
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

StartRandomEventTimer:
    ldi     XL, low(RANDOM_EVENT_TIMER_PERIOD)  ; prepare to start the rng event
    ldi     XH, high(RANDOM_EVENT_TIMER_PERIOD) ; timer by setting X to its period
    ldi     r16, RANDOM_EVENT_TIMER_IDX         ; and the timer index its index
    rcall   StartDelay                          ; start the timer
    ret                                         ; all done, return




;--------------------------------------
; ComputeUpperBound
;
; Description:          This procedure computes the upper bound of the safe zone
; Operation:            This procedure adds the bound set value by the middle 
;                       LED index.
;
; Arguments:            None.
; Return Value:         r16 - the upper bound of the safe zone.
;
; Global Variables:     None.
; Shared Variables:     bound_set - read only
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
; Registers Used:       r16, r17, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

ComputeUpperBound:
	ldi     r16, MIDDLE_LED+1   ; since we want the bounds to be symmetric,
                                ; we add 1 to the middle LED index to account
                                ; for the fact that while MIDDLE_LED=34, there
                                ; are two "real" middles at 34 and 35
    lds     r17, bound_set      ; get the bound set value
    add     r16, r17            ; compute the upper bound and store it in r16
    ret                         ; return the result in r16



;-------------------------------------------------------------------------------
; ComputeUpperBound
;
; Description:          This procedure computes the lower bound of the safe zone
; Operation:            This procedure subtracts the bound set value by the 
;                       middle LED index.
;
; Arguments:            None.
; Return Value:         r16 - the lower bound of the safe zone.
;
; Global Variables:     None.
; Shared Variables:     bound_set - read only
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
; Registers Used:       r16, r17, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19
ComputeLowerBound:
    ldi     r16, MIDDLE_LED     ; prepare to compute the lower bound
    lds     r17, bound_set      ; get the bound set value
    sub     r16, r17            ; compute the lower bound and store it in r16
    ret                         ; return the result in r16
