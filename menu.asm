 .dseg

setting:			.byte 1
gravity_set:        .byte 1
bound_set:          .byte 1
random_v_set:       .byte 1
time_set:			.byte 1
size_set:			.byte 1
mode:				.byte 1

.cseg
;------------------------------------------------------------
MenuLoop:
    rcall   StartPress
    brne    MenuCheckModePress
	rcall   StartGame

MenuCheckModePress:
    rcall   ModePress
	brne    MenuCheckRotPress
	rcall   ChangeMode
	
MenuCheckRotPress:
    rcall   RotPress
    brne    MenuCheckRotCCW
	rcall   ChangeSetting

MenuCheckRotCCW:
    rcall   RotCCW
	brne    MenuCheckRotCW
    rcall   DecSetting

MenuCheckRotCW:
    rcall   RotCW
	brne    MenuCheckSoundTimer
    rcall   IncSetting

MenuCheckSoundTimer:
    ldi     r16, SOUND_TIMER_IDX
    rcall   DelayNotDone
    brne    MenuLoopEnd
    rcall   StartSoundTimer

MenuLoopEnd:
    ret


;------------------------------------------------------------
InitSettings:
    ldi     r16, GRAVITY
    sts     setting, r16
    rcall   DisplayMessage
    ldi     r16, GRAV_INIT
    sts     gravity_set, r16
    ldi     r16, BOUND_INIT
    sts     bound_set, r16
    ldi     r16, RANDOM_V_INIT
    sts     random_v_set, r16
    ldi     r16, TIME_LIM_INIT
    sts     time_set, r16
    ldi     r16, SIZE_INIT
    sts     size_set, r16
    ldi     r16, TIMED
    sts     mode, r16
    ret


;------------------------------------------------------------
ChangeMode:
    lds     r16, mode
    cpi     r16, TIMED
    breq    SetModeInfinite
    ; brne SetModeTimed

SetModeTimed:
    ldi     r16, TIMED
    rjmp    ChangeModeEnd

SetModeInfinite:
    ldi     r16, INFINITE
    ; rjmp ChangeModeEnd

ChangeModeEnd:
    sts     mode, r16
    rcall   DisplayMessage
    ret


;------------------------------------------------------------
ChangeSetting:
    clr r0
    wordTabOffsetZ ChangeSettingTable, r0
    ldi     r17, N_SETTINGS
    lds     r16, setting

ChangeSettingLookupLoop:
    lpm     r18, Z+
    cp      r16, r18
    breq    ChangeSettingLookupMatch
    ; brne ChangeSettingLookupNoMatch

ChangeSettingLookupNoMatch:
    adiw    Z, CHANGE_SETTING_ENTRY_SIZE-1
    dec     r17
    brne    ChangeSettingLookupLoop
    ; breq ChangeSettingLookupMatch

ChangeSettingLookupMatch:
    lpm     r16, Z
    sts     setting, r16
    rcall   DisplayMessage
    ret

ChangeSettingTable:
    .db     GRAVITY,        BOUND
    .equ    CHANGE_SETTING_ENTRY_SIZE = 2 * (PC - ChangeSettingTable)
    .db     BOUND,			SIZE
    .db     SIZE,			RANDOM_V
    .db     RANDOM_V,       TIME_LIM
    .db     TIME_LIM,       GRAVITY
    .equ    N_SETTINGS = (PC - ChangeSettingTable) /  (CHANGE_SETTING_ENTRY_SIZE / 2)
    .db     0x00,           GRAVITY
    

;------------------------------------------------------------
DecSetting:
    clr r0
    wordTabOffsetZ DecSettingTable, r0
    ldi     r17, DEC_SETTING_ENTRIES
    lds     r16, setting

DecSettingLookupLoop:
    lpm     r18, Z+
    cp      r16, r18
    breq    DecSettingLookupMatch
    ; brne DecSettingLookupNoMatch

DecSettingLookupNoMatch:
    adiw    Z, DEC_SETTING_ENTRY_SIZE-1
    dec     r17
    brne    DecSettingLookupLoop
    ; breq DecSettingLookupMatch

DecSettingLookupMatch:
    lpm     r18, Z+
    lpm     r19, Z+
    movw    Z, r18
    ijmp


DecSettingTable:
    .db     GRAVITY,        low(DecGravity),        high(DecGravity),       0x00
    .equ    DEC_SETTING_ENTRY_SIZE = 2 * (PC - DecSettingTable)
    .db     BOUND,          low(DecBound),          high(DecBound),         0x00
    .db     SIZE,      low(DecSize),       high(DecSize),      0x00
    .db     RANDOM_V,       low(DecRandomV),        high(DecRandomV),       0x00
    .db     TIME_LIM,  low(DecGameTime),       high(DecGameTime),      0x00
    .equ    DEC_SETTING_ENTRIES = (PC - DecSettingTable) /  (DEC_SETTING_ENTRY_SIZE / 2)
    .db     0x00,           low(InitSettings),      high(InitSettings),     0x00


; We follow the general scheme of decrementing the setting value only if it is
; greater than the lower bound. If it is equal to the lower bound, we store the
; lower bound value back to the setting and return
DecGravity:
    rcall   ClearDisplay
    lds     r16, gravity_set
	ldi     r17, GRAV_LB
	cpse    r16, r17
    dec     r16
    sts     gravity_set, r16
    clr     r17
    rcall   DisplayHex
    ret

DecBound:
    rcall   ClearDisplay
    lds     r16, bound_set
	ldi     r17, BOUND_LB
	cpse    r16, r17
    dec     r16
    sts     bound_set, r16
    clr     r17
    rcall   DisplayBound
    ret

DecRandomV:
    rcall   ClearDisplay
    lds     r16, random_v_set
	ldi     r17, RANDOM_V_LB
	cpse    r16, r17
    dec     r16
    sts     random_v_set, r16
    clr     r17
    rcall   DisplayHex
    ret

DecGameTime:
    rcall   ClearDisplay
    lds     r16, time_set
	ldi     r17, TIME_LIM_LB
	cpse    r16, r17
    dec     r16
    sts     time_set, r16
    clr     r17
    rcall   DisplayHex
    ret


DecSize:
    rcall   ClearDisplay
    lds     r16, size_set
	ldi     r17, SIZE_LB
	cpse    r16, r17
    dec     r16
    sts     size_set, r16
    clr     r17
    rcall   DisplayBall
    ret

;------------------------------------------------------------
IncSetting:
    clr r0
    wordTabOffsetZ IncSettingTable, r0
    ldi     r17, INC_SETTING_ENTRIES
    lds     r16, setting

IncSettingLookupLoop:
    lpm     r18, Z+
    cp      r16, r18
    breq    IncSettingLookupMatch
    ; brne IncSettingLookupNoMatch

IncSettingLookupNoMatch:
    adiw    Z, DEC_SETTING_ENTRY_SIZE-1
    dec     r17
    brne    IncSettingLookupLoop
    ; breq IncSettingLookupMatch

IncSettingLookupMatch:
    lpm     r18, Z+
    lpm     r19, Z+
    movw    Z, r18
    ijmp

IncSettingTable:
    .db     GRAVITY,        low(IncGravity),        high(IncGravity),       0x00
    .equ    INC_SETTING_ENTRY_SIZE = 2 * (PC - IncSettingTable)
    .db     BOUND,          low(IncBound),          high(IncBound),         0x00
    .db     SIZE,      low(IncSize),       high(IncSize),      0x00
    .db     RANDOM_V,       low(IncRandomV),        high(IncRandomV),       0x00
    .db     TIME_LIM,  low(IncGameTime),       high(IncGameTime),      0x00
    .equ    INC_SETTING_ENTRIES = (PC - IncSettingTable) /  (INC_SETTING_ENTRY_SIZE / 2)
    .db     0x00,           low(InitSettings),      high(InitSettings),     0x00

; We follow the general scheme of incrementing the setting value only if it is
; lesser than the upper bound. If it is equal to the upper bound, we store the
; upper bound value back to the setting and return
IncGravity:
    rcall   ClearDisplay
    lds     r16, gravity_set
	ldi     r17, GRAV_UB
    cpse    r16, r17
    inc     r16
    sts     gravity_set, r16
    clr     r17
    rcall   DisplayHex
    ret


IncBound:
    rcall   ClearDisplay
    lds     r16, bound_set
	ldi     r17, BOUND_UB
    cpse    r16, r17
    inc     r16
    sts     bound_set, r16
    rcall   DisplayBound
    ret


IncRandomV:
    rcall   ClearDisplay
    lds     r16, random_v_set
	ldi     r17, RANDOM_V_UB
    cpse    r16, r17
    inc     r16
    sts     random_v_set, r16
    clr     r17
    rcall   DisplayHex
    ret

IncGameTime:
    rcall   ClearDisplay
    lds     r16, time_set
	ldi     r17, TIME_LIM_UB
    cpse    r16, r17
    inc     r16
    sts     time_set, r16
    clr     r17
    rcall   DisplayHex
    ret


IncSize:
    rcall   ClearDisplay
    lds     r16, size_set
	ldi     r17, SIZE_UB
    cpse    r16, r17
    inc     r16
    clr     r17
    sts     size_set, r16
    rcall   DisplayBall
    ret
