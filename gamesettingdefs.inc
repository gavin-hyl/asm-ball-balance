.equ MIDDLE_LED                 = 35
.equ START_POS                  = MIDDLE_LED

.equ TIMED                      = 0xff
.equ INFINITE                   = 0xfe
.equ WIN                        = 0x0f
.equ LOSE                       = 0x1f
.equ BLINK_TIME                 = 127

.equ BALL_POS_FRAC_MAX          = 20      ; decimal system

.EQU GRAVITY        = 0
.EQU GRAV_UB        = 8
.EQU GRAV_LB        = 1
.equ GRAV_INIT      = 1

.EQU BOUND          = 2
.EQU BOUND_UB       = 34
.EQU BOUND_LB       = 10
.equ BOUND_INIT     = BOUND_UB

.EQU RANDOM_V       = 3
.EQU RANDOM_V_UB    = 8
.EQU RANDOM_V_LB    = 0
.equ RANDOM_V_INIT  = 0

.EQU TIME_LIM      = 4
.EQU TIME_LIM_UB   = 0xff
.EQU TIME_LIM_LB   = 1
.equ TIME_LIM_INIT = 10

.EQU SIZE           = 5
.EQU SIZE_UB		= 3
.EQU SIZE_LB		= 1
.equ SIZE_INIT		= 1

.EQU MAX_SETTING_IDX = SIZE

.equ MAX_BRIGHTNESS             = 255
