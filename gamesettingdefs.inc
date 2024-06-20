;-------------------------------------------------------------------------------
; gamesettingdefs.inc
;
; Description:
;   This file contains definitions for the game settings, including the indices
;   for the game settings and the initial values for the game settings, as well
;   as software timer constants.
;
; Author:
;   Gavin Hua
;
; Revision History: 
;   2024/05/16 - Initial revision
;   2024/05/18 - Debug and test
;   2024/06/01 - Remove extra definitions
;   2024/06/19 - Update comments
;-------------------------------------------------------------------------------



.equ TIMED                      = 0xff          ; timed game mode
.equ INFINITE                   = 0xfe          ; infinite game mode
.equ WIN                        = 0x0f          ; win game status
.equ LOSE                       = 0x1f          ; lose game status
.equ BLINK_TIME                 = 127           ; max on/off time for blinking

.equ BALL_POS_FRAC_MAX          = 10            ; A decimal system is used since
                                                ; it is compatible with the
                                                ; ~10 Hz update rate of the game

.EQU GRAVITY                    = 0             ; gravity setting index
.EQU GRAV_UB                    = 8             ; maximum gravity
.EQU GRAV_LB                    = 1             ; minimum gravity
.equ GRAV_INIT                  = GRAV_LB       ; initial gravity setting        

.EQU BOUND                      = 2             ; bound setting index
.EQU BOUND_UB                   = 34            ; maximum bound
.EQU BOUND_LB                   = 10            ; minimum bound
.equ BOUND_INIT                 = BOUND_UB      ; initial bound setting

.EQU RANDOM_V                   = 3             ; random velocity setting index
.EQU RANDOM_V_UB                = 8             ; maximum random velocity
.EQU RANDOM_V_LB                = 0             ; minimum random velocity
.equ RANDOM_V_INIT              = RANDOM_V_LB   ; initial random velocity setting

.EQU TIME_LIM                   = 4             ; time limit setting index
.EQU TIME_LIM_UB                = 0xff          ; maximum time limit
.EQU TIME_LIM_LB                = 1             ; minimum time limit
.equ TIME_LIM_INIT              = 10            ; initial time limit setting

.EQU SIZE                       = 5             ; ball size setting index
.EQU SIZE_UB		            = 3             ; maximum ball size
.EQU SIZE_LB		            = 1             ; minimum ball size
.equ SIZE_INIT		            = 1             ; initial ball size setting

.equ MAX_BRIGHTNESS             = 255

.equ GAME_TIMER_IDX             = 0             ; game timer index
.equ GAME_TIMER_PERIOD          = 1000          ; expire ~ every second
.equ STATUS_TIMER_IDX           = 1             ; status timer index
.equ STATUS_TIMER_PERIOD        = 100           ; ~ 10 Hz update
.equ RANDOM_EVENT_TIMER_IDX     = 2             ; random event timer index
.equ RANDOM_EVENT_TIMER_PERIOD  = 1000          ; expire ~ every second
.equ SOUND_TIMER_IDX            = 3             ; sound timer index
.equ SOUND_TIMER_PERIOD         = 100           ; ~ 10 Hz update