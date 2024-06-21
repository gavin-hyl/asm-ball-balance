;-------------------------------------------------------------------------------
; menu.asm
;
; Description:
;   This file contains the code for the menu system of the game.
;   The menu system allows the user to change the game settings and mode.
;   The user can change the setting by rotating the encoder, and change the mode
;   by pressing the mode button. The user can start the game by pressing the
;   start button. The menu system also displays the current setting and mode.
;
; Public Functions:
;   MenuLoop - This procedure handles software timer expirations and button
;              presses while the user is in the menu.
;   InitSettings - This function initializes settings to default values.
;
; Private Functions:
;   ChangeMode - This function changes the current mode.
;   ChangeSetting - This function changes the current setting.
;   DecSetting - This function decrements the current setting.
;   DecGravity - This function decrements the gravity setting.
;   DecBound - This function decrements the safe zone boundary setting.
;   DecRandomV - This function decrements the random velocity setting.
;   DecGameTime - This function decrements the game time setting.
;   DecSize - This function decrements the size of the ball.
;   IncSetting - This function increments the current setting.
;   IncGravity - This function increments the gravity setting.
;   IncBound - This function increments the safe zone boundary setting.
;   IncRandomV - This function increments the random velocity setting.
;   IncGameTime - This function increments the game time setting.
;   IncSize - This function increments the size of the ball.
;
; Tables:
;   ChangeSettingTable - This table contains the setting indices and the next
;                        setting index to change to.
;   DecSettingTable - This table contains the setting indices and the function
;                     pointers to functions that decrement the setting.
;   IncSettingTable - This table contains the setting indices and the function
;                     pointers to functions that increment the setting.
;
; Author:
; 	Gavin Hua
;
; Revision History: 
;	2024/06/14 - initial revision
;	2024/06/17 - debugged and tested all functions
;	2024/06/19 - update comments and removed unnecessary clears
;-------------------------------------------------------------------------------


.dseg

setting:	    .byte   1   ; current setting index
gravity_set:    .byte   1   ; gravity setting value
bound_set:      .byte   1   ; safe zone boundary setting value
random_v_set:   .byte   1   ; random velocity setting value
time_set:	    .byte   1   ; game time setting value
size_set:	    .byte   1   ; ball size setting value
mode:		    .byte   1   ; current mode index



;-------------------------------------------------------------------------------
.cseg

; MenuLoop
;
; Description:          This procedure handles software timer expirations and
;                       button presses while the user is in the menu.
; Operation:            This procedure polls the software timers and the Start
;                       button and calls the corresponding handlers.
; 
; Arguments:            None.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     delay_timer - read only
;                       setting - read/write
;                       mode - read/write
;                       rot_pressed - read only
;                       start_pressed - read only
;                       mode_pressed - read only
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
; Registers Used:       r0, r16, Y, SREG (possibly more)
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

MenuLoop:
    rcall   StartPress          ; check if the start button is pressed
    brne    MenuCheckModePress  ; if not, check the mode button
	rcall   StartGame           ; if so, start the game
    ; rjmp  MenuCheckModePress  ; and check the mode button press

MenuCheckModePress:
    rcall   ModePress           ; check if the mode button is pressed
	brne    MenuCheckRotPress   ; if not, check the rot press
	rcall   ChangeMode          ; if so, change the mode
    ; rjmp  MenuCheckRotPress   ; and check the rot press
	
MenuCheckRotPress:
    rcall   RotPress            ; check if the rotary encoder is pressed
    brne    MenuCheckRotCCW     ; if not, check if it is rotated CCW
	rcall   ChangeSetting       ; if so, change the setting
    ; rjmp  MenuCheckRotCCW     ; and check if it is rotated CCW

MenuCheckRotCCW:
    rcall   RotCCW              ; check if the rotary encoder is rotated CCW
	brne    MenuCheckRotCW      ; if not, check if it is rotated clockwise
    rcall   DecSetting          ; if so, decrement the setting
    ; rjmp  MenuCheckRotCW      ; and check if it is rotated clockwise

MenuCheckRotCW:
    rcall   RotCW               ; check if the rotary encoder is rotated CW
	brne    MenuCheckSoundTimer ; if not, check the sound timer
    rcall   IncSetting          ; if so, increment the setting
    ; rjmp  MenuCheckSoundTimer ; and check the sound timer

MenuCheckSoundTimer:
    ldi     r16, SOUND_TIMER_IDX; load the sound timer index to call DelayNotDone
    rcall   DelayNotDone        ; check if the sound timer is done
    brne    MenuLoopEnd         ; if not, end the menu loop
    rcall   StartSoundTimer     ; if so, start the sound timer
    ; rjmp  MenuLoopEnd         ; and end the menu loop

MenuLoopEnd:
    ret


;-------------------------------------------------------------------------------
; InitSettings
;
; Description:          This function initializes settings to default values.
; Operation:            This function sets the gravity, boundary, random v,
;                       time limit, size, and mode to their default values. It 
;                       then calls the DisplayMessage function to display the 
;                       default setting, gravity. It also sets the mode to TIMED.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     gravity_set - set to GRAV_INIT
;                       bound_set - set to BOUND_INIT
;                       random_v_set - set to RANDOM_V_INIT
;                       time_set - set to TIME_LIM_INIT
;                       size_set - set to SIZE_INIT
;                       setting - set to GRAVITY
;                       mode - set to TIMED
; Local Variables:      tmp (r16) - temporary variable for setting values
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r16, r17, r18, X, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

InitSettings:
    ldi     r16, GRAVITY        ; set the setting to GRAVITY
    sts     setting, r16
    rcall   DisplayMessage      ; display the default setting
    ldi     r16, GRAV_INIT      ; set the gravity to default value
    sts     gravity_set, r16
    ldi     r16, BOUND_INIT     ; set the boundary to default value
    sts     bound_set, r16
    ldi     r16, RANDOM_V_INIT  ; set the random velocity to default value
    sts     random_v_set, r16
    ldi     r16, TIME_LIM_INIT  ; set time limit of timed mode to default value
    sts     time_set, r16
    ldi     r16, SIZE_INIT      ; set the size of the ball to default value
    sts     size_set, r16
    ldi     r16, TIMED          ; set the mode to TIMED
    sts     mode, r16
    ret                         ; all done, return


;-------------------------------------------------------------------------------
; ChangeMode
;
; Description:          This function changes the current mode.
; Operation:            This function sets the mode to TIMED if it is INFINITE
;                       and INFINITE if it is TIMED.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     mode - toggled between TIMED and INFINITE
; Local Variables:      tmp (r16) - temporary variable for mode
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r16, r17, r18, X, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

ChangeMode:
    lds     r16, mode       ; load the current mode
    cpi     r16, TIMED      ; compare with TIMED
    breq    SetModeInfinite ; if it is TIMED, then set to INFINITE
    ; brne SetModeTimed     ; if it is INFINITE, then set to TIMED

SetModeTimed:
    ldi     r16, TIMED      ; set the mode to TIMED
    rjmp    ChangeModeEnd   ; and clean up

SetModeInfinite:
    ldi     r16, INFINITE   ; set the mode to INFINITE
    ; rjmp ChangeModeEnd    ; and clean up

ChangeModeEnd:
    sts     mode, r16       ; store the new mode
    rcall   DisplayMessage  ; display the new mode
    ret                     ; all done, return



;------------------------------------------------------------
; ChangeSetting
;
; Description:          This function changes the current setting.
; Operation:            This function checks the current setting index, and
;                       stores the next setting index based on a table lookup.
;                       It then calls the DisplayMessage function to display the
;                       new setting.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     setting - changed to next setting
; Local Variables:      loop_cnt (r17) - loop counter for table lookup
;                       setting (r16) - current setting index
;                       tmp (r18) - temporary variable for next setting index
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r16, r17, r18, X, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

ChangeSetting:
    clr r16                              ; clear r0 to prepare Z pointer offset
    wordTabOffsetZ ChangeSettingTable, r16 ; point Z to table beginning
    ldi     r17, N_SETTINGS             ; initialize loop counter
    lds     r16, setting                ; load the current setting index

ChangeSettingLookupLoop:
    lpm     r18, Z+                     ; load the setting index from the table
    cp      r16, r18                    ; compare with current setting index
    breq    ChangeSettingLookupMatch    ; if match, load the next setting index
    ; brne ChangeSettingLookupNoMatch   

ChangeSettingLookupNoMatch:
    adiw    Z, CHANGE_SETTING_ENTRY_SIZE-1  ; point Z to the next entry
    dec     r17                         ; decrement and test the loop counter
    brne    ChangeSettingLookupLoop     ; if zero, end of table, default action
    ; breq ChangeSettingLookupMatch     ; otherwise, continue looping

ChangeSettingLookupMatch:
    lpm     r16, Z                      ; load the next setting index
    sts     setting, r16                ; store it back to the setting variable
    rcall   DisplayMessage              ; display the new setting
    ret                                 ; all done, return



;-------------------------------------------------------------------------------
; ChangeSettingTable
;
; Description:      This table contains the setting indices and the next setting
;                   index to change to.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    2024/06/17

ChangeSettingTable:
    ;db     setting index,  next setting index
    .db     GRAVITY,        BOUND
    ; byte size of each entry
    .equ    CHANGE_SETTING_ENTRY_SIZE = 2 * (PC - ChangeSettingTable)
    .db     BOUND,			SIZE
    .db     SIZE,			RANDOM_V
    .db     RANDOM_V,       TIME_LIM
    .db     TIME_LIM,       GRAVITY
    ; number of entries in the table
    .equ    N_SETTINGS = (PC - ChangeSettingTable) /  (CHANGE_SETTING_ENTRY_SIZE / 2)
    .db     0x00,           GRAVITY



;------------------------------------------------------------
; DecSetting
;
; Description:          This function decrements the current setting.
; Operation:            This function checks the current setting index, and
;                       calls the appropriate function to decrement the setting
;                       by performing a table lookup.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     Depends on current setting.
; Local Variables:      loop_cnt (r17) - loop counter for table lookup
;                       setting (r16) - current setting index
;                       tmp (r18) - temporary variable for storing setting index
;                                   and loading function pointer
;                       tmp2 (r19) - temporary variable for function pointer
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r0, r16, r17, r18, r19, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

DecSetting:
    clr r16                             ; clear r0 to prepare Z pointer offset
    wordTabOffsetZ DecSettingTable, r16  ; point Z to the beginning of the table
    ldi     r17, DEC_SETTING_ENTRIES    ; load the number of settings
    lds     r16, setting                ; load the current setting index

DecSettingLookupLoop:
    lpm     r18, Z+                     ; load the setting index from the table
    cp      r16, r18                    ; compare with current setting index
    breq    DecSettingLookupMatch       ; if match, load the function pointer
    ; brne DecSettingLookupNoMatch      ; if not, point Z to next entry

DecSettingLookupNoMatch:
    adiw    Z, DEC_SETTING_ENTRY_SIZE-1 ; point Z to the next entry
    dec     r17                         ; decrement and test the loop counter
    brne    DecSettingLookupLoop        ; if zero, end of table, default action
    ; breq DecSettingLookupMatch        ; otherwise, continue looping

DecSettingLookupMatch:
    lpm     r18, Z+                     ; load low byte of function pointer
    lpm     r19, Z+                     ; load high byte of function pointer
    movw    Z, r18                      ; move function pointer to Z
    ijmp                                ; call the function


;-------------------------------------------------------------------------------
; DecSettingTable
;
; Description:      This table contains the setting indices and the function
;                   pointers to functions that decrement the setting. The table
;                   is used to look up the function pointer based on the setting
;                   index.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    2024/06/17

DecSettingTable:
    ;db     setting index,  low(function),          high(function),         0x00
    .db     GRAVITY,        low(DecGravity),        high(DecGravity),       0x00
    ; byte size of each entry
    .equ    DEC_SETTING_ENTRY_SIZE = 2 * (PC - DecSettingTable)
    .db     BOUND,          low(DecBound),          high(DecBound),         0x00
    .db     SIZE,           low(DecSize),           high(DecSize),          0x00
    .db     RANDOM_V,       low(DecRandomV),        high(DecRandomV),       0x00
    .db     TIME_LIM,       low(DecGameTime),       high(DecGameTime),      0x00
    ; number of entries in the table
    .equ    DEC_SETTING_ENTRIES = (PC - DecSettingTable) /  (DEC_SETTING_ENTRY_SIZE / 2)
    .db     0x00,           low(InitSettings),      high(InitSettings),     0x00



;-------------------------------------------------------------------------------
; DecGravity
;
; Description:          This function decrements the gravity setting.
; Operation:            This function first clears the display, then loads the
;                       current gravity setting. If the setting is not at the
;                       lower bound, it decrements the setting. It then stores
;                       the new setting back to the gravity_set variable.
;                       Finally, it calls the DisplayHex function to display the
;                       new gravity setting.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     gravity_set - possibly decremented
;                       curr_src_patterns - 7seg region (last 4 bytes) written
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
; Registers changed:    r16, r17, r18, r19, r20, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

DecGravity:
    rcall   ClearDisplay        ; clear the display
    lds     r16, gravity_set    ; load the current gravity setting
	ldi     r17, GRAV_LB        ; load the lower bound of the gravity setting
	cpse    r16, r17            ; check if the setting is at the lower bound
    dec     r16                 ; if not, decrement the setting
    sts     gravity_set, r16    ; store it back to the gravity_set variable
    clr     r17                 ; clear r17 (upper two digits) to prepare for
    rcall   DisplayHex          ; DisplayHex call
    ret                         ; all done, return


;-------------------------------------------------------------------------------
; DecBound
;
; Description:          This function decrements the safe zone boundary setting.
; Operation:            This function first clears the display, then loads the
;                       current boundary setting. If the setting is not at the
;                       lower bound, it decrements the setting. It then stores
;                       the new setting back to the bound_set variable. Finally,
;                       it calls the DisplayBound function to display the new
;                       safe zone boundary.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     bound_set - possibly decremented
;                       curr_src_patterns - gameLED region written
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
; Registers changed:    r16, r17, r18, r19, r20, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

DecBound:
    rcall   ClearDisplay    ; clear the display
    lds     r16, bound_set  ; load the current boundary setting
	ldi     r17, BOUND_LB   ; load the lower bound of the boundary setting
	cpse    r16, r17        ; check if the setting is at the lower bound
    dec     r16             ; if not, decrement the setting
    sts     bound_set, r16  ; store it back to the bound_set variable
    rcall   DisplayBound    ; display the new safe zone boundary
    ret



;-------------------------------------------------------------------------------
; DecRandomV
;
; Description:          This function decrements the random velocity setting.
; Operation:            This function first clears the display, then loads the
;                       current random velocity setting. If the setting is not
;                       at the lower bound, it decrements the setting. It then
;                       stores the new value back to the random_v_set variable.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     random_v_set - possibly decremented
;                       curr_src_patterns - 7seg region (last 4 bytes) written
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
; Registers changed:    r16, r17, r18, r19, r20, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

DecRandomV:
    rcall   ClearDisplay        ; clear the display
    lds     r16, random_v_set   ; load the current random velocity setting
	ldi     r17, RANDOM_V_LB    ; load the lower bound of the random velocity
	cpse    r16, r17            ; check if the setting is at the lower bound
    dec     r16                 ; if not, decrement the setting
    sts     random_v_set, r16   ; store it back to the random_v_set variable
    clr     r17                 ; clear r17 (upper two digits) to prepare for
    rcall   DisplayHex          ; DisplayHex call
    ret                         ; all done, return



;-------------------------------------------------------------------------------
; DecGameTime
;
; Description:          This function decrements the game time setting.
; Operation:            This function first clears the display, then loads the
;                       current game time setting. If the setting is not at the
;                       lower bound, it decrements the setting. It then stores
;                       the new setting back to the time_set variable. Finally,
;                       it calls the DisplayHex function to display the new time.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     time_set - possibly decrements
;                       curr_src_patterns - 7seg region (last 4 bytes) written
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
; Registers changed:    r16, r17, r18, r19, r20, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

DecGameTime:
    rcall   ClearDisplay        ; clear the display
    lds     r16, time_set       ; load the current game time setting
	ldi     r17, TIME_LIM_LB    ; load the lower bound of the game time setting
	cpse    r16, r17            ; check if the setting is at the lower bound
    dec     r16                 ; if not, decrement the setting
    sts     time_set, r16       ; store it back to the time_set variable
    clr     r17                 ; clear r17 (upper two digits) to prepare for
    rcall   DisplayHex          ; DisplayHex call
    ret                         ; all done, return



;-------------------------------------------------------------------------------
; DecSize
;
; Description:          This function decrements the size of the ball.
; Operation:            This function first clears the display, then loads the
;                       current size of the ball. If the size is not at the lower
;                       bound, it decrements the size. It then stores the new size
;                       back to the size_set variable. Finally, it calls the
;                       DisplayBall function to display the new ball.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     size_set - possibly decremented
;                       curr_src_patterns - gameLED region written
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
; Registers changed:     r13, r14, r15, r16, r17, r18, r19, r20, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

DecSize:
    rcall   ClearDisplay    ; clear the display
    lds     r16, size_set   ; load the current size of the ball
	ldi     r17, SIZE_LB    ; load the lower bound of the size
	cpse    r16, r17        ; check if the size is at the lower bound
    dec     r16             ; if not, decrement the size
    sts     size_set, r16   ; store the new size back to the size_set variable
    rcall   DisplayBall     ; display the new ball
    ret



;-------------------------------------------------------------------------------
; IncSetting
;
; Description:          This function increments the current setting.
; Operation:            This function checks the current setting index, and
;                       calls the appropriate function to increment the setting
;                       by performing a table lookup.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     Depends on current setting.
;                       curr_src_patterns - gameLED region written
; Local Variables:      loop_cnt (r17) - loop counter for table lookup
;                       setting (r16) - current setting index
;                       tmp (r18) - temporary variable for storing setting index
;                                   and loading function pointer
;                       tmp2 (r19) - temporary variable for function pointer
;
; Input:                None.
; Output:               None.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r0, r16, r17, r18, r19, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

IncSetting:
    clr r16                             ; clear r0 to prepare Z pointer offset
    wordTabOffsetZ IncSettingTable, r16 ; point Z to the beginning of the table
    ldi     r17, INC_SETTING_ENTRIES    ; load the number of settings
    lds     r16, setting                ; load the current setting index

IncSettingLookupLoop:
    lpm     r18, Z+                     ; load the setting index from the table
    cp      r16, r18                    ; compare with current setting index
    breq    IncSettingLookupMatch       ; if match, load the function pointer
    ; brne IncSettingLookupNoMatch      ; if not, point Z to next entry

IncSettingLookupNoMatch:
    adiw    Z, DEC_SETTING_ENTRY_SIZE-1 ; point Z to the next entry
    dec     r17                         ; decrement and test the loop counter
    brne    IncSettingLookupLoop        ; if zero, end of table, default action
    ; breq IncSettingLookupMatch        ; otherwise, continue looping

IncSettingLookupMatch:
    lpm     r18, Z+                     ; load low byte of function pointer
    lpm     r19, Z+                     ; load high byte of function pointer
    movw    Z, r18                      ; move function pointer to Z
    ijmp                                ; call the function



;-------------------------------------------------------------------------------
; IncSettingTable
;
; Description:      This table contains the setting indices and the function
;                   pointers to functions that increment the setting. The table
;                   is used to look up the function pointer based on the setting
;                   index.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    2024/06/17

IncSettingTable:
    ;db     setting index,  low(function),          high(function),         0x00
    .db     GRAVITY,        low(IncGravity),        high(IncGravity),       0x00
    ; byte size of each entry
    .equ    INC_SETTING_ENTRY_SIZE = 2 * (PC - IncSettingTable)
    .db     BOUND,          low(IncBound),          high(IncBound),         0x00
    .db     SIZE,           low(IncSize),           high(IncSize),          0x00
    .db     RANDOM_V,       low(IncRandomV),        high(IncRandomV),       0x00
    .db     TIME_LIM,       low(IncGameTime),       high(IncGameTime),      0x00
    ; number of entries in the table
    .equ    INC_SETTING_ENTRIES = (PC - IncSettingTable) /  (INC_SETTING_ENTRY_SIZE / 2)
    .db     0x00,           low(InitSettings),      high(InitSettings),     0x00



;-------------------------------------------------------------------------------
; IncGravity
;
; Description:          This function increments the gravity setting.
; Operation:            This function first clears the display, then loads the
;                       current gravity setting. If the setting is not at the
;                       upper bound, it increments the setting. It then stores
;                       the new setting back to the gravity_set variable.
;                       Finally, it calls the DisplayHex function to display the
;                       new gravity setting.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     gravity_set - possibly incremented
;                       curr_src_patterns - 7seg region (last 4 bytes) written
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
; Registers changed:    r16, r17, r18, r19, r20, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

IncGravity:
    rcall   ClearDisplay        ; clear the display
    lds     r16, gravity_set    ; load the current gravity setting
	ldi     r17, GRAV_UB        ; load the upper bound of the gravity setting
    cpse    r16, r17            ; check if the setting is at the upper bound
    inc     r16                 ; if not, increment the setting
    sts     gravity_set, r16    ; store it back to the gravity_set variable
    clr     r17                 ; clear r17 (upper two digits) to prepare for
    rcall   DisplayHex          ; DisplayHex call
    ret



;-------------------------------------------------------------------------------
; IncBound
;
; Description:          This function increments the safe zone boundary setting.
; Operation:            This function first clears the display, then loads the
;                       current boundary setting. If the setting is not at the
;                       upper bound, it increments the setting. It then stores
;                       the new setting back to the bound_set variable. Finally,
;                       it calls the DisplayBound function to display the new
;                       safe zone boundary.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     bound_set - possibly incremented
;                       curr_src_patterns - gameLED region written
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
; Registers changed:    r16, r17, r18, r19, r20, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

IncBound:
    rcall   ClearDisplay    ; clear the display
    lds     r16, bound_set  ; load the current boundary setting
	ldi     r17, BOUND_UB   ; load the upper bound of the boundary setting
    cpse    r16, r17        ; check if the setting is at the upper bound
    inc     r16             ; if not, increment the setting
    sts     bound_set, r16  ; store it back to the bound_set variable
    rcall   DisplayBound    ; display the new safe zone boundary
    ret                     ; all done, return



;-------------------------------------------------------------------------------
; IncRandomV
;
; Description:          This function increments the random velocity setting.
; Operation:            This function first clears the display, then loads the
;                       current random velocity setting. If the setting is not
;                       at the upper bound, it increments the setting. It then
;                       stores the new value back to the random_v_set variable.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     random_v_set - possibly incremented
;                       curr_src_patterns - 7seg region (last 4 bytes) written
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
; Registers changed:    r16, r17, r18, r19, r20, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

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



;-------------------------------------------------------------------------------
; IncGameTime
;
; Description:          This function increments the game time setting.
; Operation:            This function first clears the display, then loads the
;                       current game time setting. If the setting is not at the
;                       upper bound, it increments the setting. It then stores
;                       the new setting back to the time_set variable. Finally,
;                       it calls the DisplayHex function to display the new time.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     time_set - possibly incremented
;                       curr_src_patterns - 7seg region (last 4 bytes) written
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
; Registers changed:    r16, r17, r18, r19, r20, Y, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

IncGameTime:
    rcall   ClearDisplay        ; clear the display
    lds     r16, time_set       ; load the current game time setting
	ldi     r17, TIME_LIM_UB    ; load the upper bound of the game time setting
    cpse    r16, r17            ; check if the setting is at the upper bound
    inc     r16                 ; if not, increment the setting
    sts     time_set, r16       ; store it back to the time_set variable
    clr     r17                 ; clear r17 (upper two digits) to prepare for
    rcall   DisplayHex          ; DisplayHex call
    ret                         ; all done, return



;-------------------------------------------------------------------------------
; IncSize
;
; Description:          This function increments the size of the ball.
; Operation:            This function first clears the display, then loads the
;                       current size of the ball. If the size is not at the 
;                       upper bound, it increments the size. It then stores the
;                       new size back to the size_set variable. Finally, it
;                       calls the DisplayBall function to display the new ball.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     size_set - possibly incremented
;                       curr_src_patterns - gameLED region written
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
; Registers changed:     r13, r14, r15, r16, r17, r18, r19, r20, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/17

IncSize:
    rcall   ClearDisplay    ; clear the display
    lds     r16, size_set   ; load the current size of the ball
	ldi     r17, SIZE_UB    ; load the upper bound of the size
    cpse    r16, r17        ; check if the size is at the upper bound
    inc     r16             ; if not, increment the size
    sts     size_set, r16   ; store the new size back to the size_set variable
    rcall   DisplayBall     ; display the new ball
    ret                     ; all done, return
