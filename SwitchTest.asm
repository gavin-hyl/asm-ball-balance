;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   HW2TEST                                  ;
;                            Homework #2 Test Code                           ;
;                                  EE/CS 10b                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program tests the switch and encoder functions for
;                   Homework #2.  It sets up the stack and calls the homework
;                   test function.
;
; Input:            User presses of the switches and rotations of the rotary
;                   encoders are stored in memory.
; Output:           None.
;
; User Interface:   No real user interface.  The user inputs switch presses
;                   and rotations and appropriate data is written to memory.
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      Only the last (at least) 128 switch inputs are stored.
;
; Revision History:
;    5/02/18  Glen George               initial revision
;    4/06/22  Glen George               changed output format to only store an
;                                          extra byte when there is an error
;    4/28/24  Glen George               changed function calls to match
;                                          Balance Game board




;set the device
.device  ATMEGA64




;get the definitions for the device
.include  "m64def.inc"

;include all the .inc files since all .asm files are needed here (no linker)


.include "chiptimerdefs.inc"
.include "displaydefs.inc"
.include "gamesettingdefs.inc"
.include "gametimerdefs.inc"
.include "generaldefs.inc"
.include "imudefs.inc"
.include "iodefs.inc"
.include "musicdefs.inc"
.include "randomdefs.inc"
.include "sounddefs.inc"
.include "switchdefs.inc"
.include "timer.inc"


.cseg




;setup the vector area

.org    $0000
    jmp     Start                   ;reset vector
    jmp     PC                      ;external interrupt 0
    jmp     PC                      ;external interrupt 1
    jmp     PC                      ;external interrupt 2
    jmp     PC                      ;external interrupt 3
    jmp     PC                      ;external interrupt 4
    jmp     PC                      ;external interrupt 5
    jmp     PC                      ;external interrupt 6
    jmp     PC                      ;external interrupt 7
    jmp     PC                      ;timer 2 compare match
    jmp     PC                      ;timer 2 overflow
    jmp     PC                      ;timer 1 capture
    jmp     PC                      ;timer 1 compare match A
    jmp     PC                      ;timer 1 compare match B
    jmp     PC                      ;timer 1 overflow
    jmp     Timer0CompareMatchHandler;timer 0 compare match
    jmp     PC                      ;timer 0 overflow
    jmp     PC                      ;SPI transfer complete
    jmp     PC                      ;UART 0 Rx complete
    jmp     PC                      ;UART 0 Tx empty
    jmp     PC                      ;UART 0 Tx complete
    jmp     PC                      ;ADC conversion complete
    jmp     PC                      ;EEPROM ready
    jmp     PC                      ;analog comparator
    jmp     PC                      ;timer 1 compare match C
    jmp     PC                      ;timer 3 capture
    jmp     PC                      ;timer 3 compare match A
    jmp     PC                      ;timer 3 compare match B
    jmp     PC                      ;timer 3 compare match C
    jmp     PC                      ;timer 3 overflow
    jmp     PC                      ;UART 1 Rx complete
    jmp     PC                      ;UART 1 Tx empty
    jmp     PC                      ;UART 1 Tx complete
    jmp     PC                      ;Two-wire serial interface
    jmp     PC                      ;store program memory ready




; start of the actual program

Start:                                  ;start the CPU after a reset
        LDI     R16, LOW(TopOfStack)    ;initialize the stack pointer
        OUT     SPL, R16
        LDI     R16, HIGH(TopOfStack)
        OUT     SPH, R16


        ;call any initialization functions
        rcall   InitIO
        rcall   InitChipTimers
        rcall   InitSwitch
        ;rcall   InitTimers
        ;rcall   InitRandom
        ; rcall   InitDisplay

        RCALL   SwitchTest              ;do the switch tests
        RJMP    Start                   ;shouldn't return, but if it does, restart




; SwitchTest
;
; Description:       This procedure tests the switch functions.  It loops
;                    calling each status function and when it finds a switch
;                    press or rotation the appropriate character is written to
;                    the key buffer (KeyBuf).  It also verifies that there is
;                    no longer a switch or rotation and if there is, it writes
;                    an 0xEE to the buffer to indicate an error.  Thus for
;                    properly working functions the buffer will contain only
;                    the switch press and rotation characters.  The function
;                    never returns.
;
; Operation:         For each switch its status function is called.  If there
;                    is a press or rotation an appropriate letter is written
;                    to the buffer (KeyBuf).  Then the status function is
;                    called again and if there is again a press or rotation
;                    (should not be the case) 0xEE is written to the buffer to
;                    indicate an error.  The function then loops and starts
;                    over, performing these tests in an infinite loop.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   R4 - pointer into buffer.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R4, R5, R16, Y (YH | YL)
; Stack Depth:       unknown (at least 2 bytes)
;
; Author:            Glen George
; Last Modified:     April 28, 2024

SwitchTest:


        CLR     R4              ;start at beginning of buffer

SwitchTestLoop:

CheckRotPress:                  ;check RotPress function

        PUSH    R4              ;save buffer index around call to RotPress
        RCALL   RotPress        ;check for rotary encoder press
        POP     R4
        BRNE    CheckModeSwitch ;if none, check "Mode" switch

        LDI     R16, 'R'        ;otherwise have a switch press
        RCALL   StoreBuff       ;store it in the buffer

        PUSH    R4              ;save index while calling LRSwitch
        RCALL   RotPress        ;check for rotary encoder press again
        POP     R4              ;   (shouldn't be one)
        BRNE    CheckModeSwitch ;if none, don't write EE, just check next

        LDI     R16, 0xEE       ;otherwise have an erroneous press so write EE
        RCALL   StoreBuff
        ;RJMP   CheckModeSwitch


CheckModeSwitch:                ;check ModePress function

        PUSH    R4              ;save buffer index around call to ModePress
        RCALL   ModePress       ;check for "Mode" switch
        POP     R4
        BRNE    CheckStartSwitch;if none, check for "Start" switch

        LDI     R16, 'M'        ;otherwise have a "Mode" switch press
        RCALL   StoreBuff       ;store it in the buffer

        PUSH    R4              ;save index while calling ModePress
        RCALL   ModePress       ;check for "Mode" switch again
        POP     R4              ;   (shouldn't be one)
        BRNE    CheckStartSwitch;if none, don't write EE, just check next

        LDI     R16, 0xEE       ;otherwise spurious switch press so write EE
        RCALL   StoreBuff
        ;RJMP   CheckStartSwitch


CheckStartSwitch:               ;check StartPress function

        PUSH    R4              ;save buffer index around call to StartPress
        RCALL   StartPress      ;check for "Start" switch
        POP     R4
        BRNE    CheckRotCCW     ;if none, check counterclockwise rotation

        LDI     R16, 'S'        ;otherwise have a "Start" switch press
        RCALL   StoreBuff       ;store it in the buffer

        PUSH    R4              ;save index while calling StartPress
        RCALL   StartPress      ;check for "Start" switch again
        POP     R4              ;   (shouldn't be one)
        BRNE    CheckRotCCW     ;if none, don't write EE, just check next

        LDI     R16, 0xEE       ;otherwise spurious switch press so write EE
        RCALL   StoreBuff
        ;RJMP   CheckRotCCW


CheckRotCCW:                    ;check RotCCW function

        PUSH    R4              ;save buffer index around call to RotCCW
        RCALL   RotCCW          ;check for counterclockwise rotation
        POP     R4
        BRNE    CheckRotCW      ;if none, check for clockwise rotation

        LDI     R16, 'c'        ;otherwise have a counterclockwise rotation
        RCALL   StoreBuff       ;store it in the buffer

        PUSH    R4              ;save index while calling RotCCW
        RCALL   RotCCW          ;check for counterclockwise rotation again
        POP     R4              ;   (shouldn't be one)
        BRNE    CheckRotCW      ;if none, no error, just check next

        LDI     R16, 0xEE       ;otherwise erroneous rotation so write EE
        RCALL   StoreBuff
        ;RJMP   CheckRotCW


CheckRotCW:                     ;check RotCW function

        PUSH    R4              ;save buffer index around call to RotCW
        RCALL   RotCW           ;check for clockwise rotation
        POP     R4
        BRNE    DoneCheckSw     ;if none, done checking switches

        LDI     R16, 'C'        ;otherwise have a clockwise rotation
        RCALL   StoreBuff       ;store it in the buffer

        PUSH    R4              ;save index while calling RotCW again
        RCALL   RotCW           ;check for clockwise rotation again
        POP     R4              ;   (shouldn't be one)
        BRNE    DoneCheckSw     ;if none, don't write EE, and done

        LDI     R16, 0xEE       ;otherwise function error so write EE
        RCALL   StoreBuff
        ;RJMP   DoneCheckSw


DoneCheckSw:                    ;done checking switch functions
        JMP     SwitchTestLoop  ;keep looping forever


        RET                     ;should never get here




; StoreBuff
;
; Description:       This procedure stores the byte passed in R16 at the
;                    offset in the KeyBuf buffer passed in R4.  The offset is
;                    updated and the new offset is returned in R4.
;
; Operation:         The Y register is loaded with the buffer address.  The
;                    passed offset is then added to this address and the
;                    passed byte is stored at this location.  The passed
;                    offset is then incremented and returned.
;
; Arguments:         R4  - offset in KeyBuf at which to write the passed byte.
;                    R16 - byte to write to the buffer at the passed offset.
; Return Value:      R4  - offset of the next location in the buffer.
;
; Local Variables:   Y - pointer into buffer.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R4, R16, R17, Y (YH | YL)
; Stack Depth:       0 bytes
;
; Author:            Glen George
; Last Modified:     May 1, 2018

StoreBuff:

        LDI     YL, LOW(KeyBuf) ;get buffer location to store switch at
        LDI     YH, HIGH(KeyBuf)

        LDI     R17, 0          ;for carry propagation
        ADD     YL, R4          ;add the passed offset
        ADC     YH, R17

        STD     Y + 0, R16      ;store the passed byte in the buffer

        INC     R4              ;update the buffer offset, wrapping at 256


        RET                     ;all done, return




;the data segment


.dseg


; buffer in which to store switch presses (length must be 256)
KeyBuf:         .BYTE   256


; the stack - 128 bytes
                .BYTE   127
TopOfStack:     .BYTE   1               ;top of the stack




; since don't have a linker, include all the .asm files

;.include "file.asm"
;-------------------------------------------------------------------------------
; include asm files for the rest of the program
.include "timer.asm"
.include "chiptimer.asm"
.include "display.asm"
.include "div.asm"
.include "game.asm"
.include "gamedisplay.asm"
.include "gametimer.asm"
.include "imu.asm"
.include "io.asm"
.include "menu.asm"
.include "music.asm"
.include "random.asm"
.include "segtable.asm"
.include "sound.asm"
.include "spi.asm"
.include "switch.asm"
