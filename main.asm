;-------------------------------------------------------------------------------
; File:             main.asm
; Description:      This program provides the main loop for the ball balance
;                   game, the final project for EE 10b. The program initializes
;                   the hardware, and then enters the main loop.
;
; Input:            None.
; Output:           Music on the speaker, display on the game and 7-segment LEDs,
;
; User Interface:   The user can control the menu with the switches, and play
;                   the game by tilting the game board. Please refer to the
;                   functional specification for more details.
; Error Handling:   Refer to functional specification.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      None.
;
; Revision History:
;   2024/06/01 - initial revision
;   2024/06/18 - changed main loop structure to call game loop and menu loop
;   2024/06/19 - added comments
;-------------------------------------------------------------------------------



; device setup and include files
.device ATMEGA64
.include "m64def.inc"

.include "chiptimerdefs.inc"
.include "displaydefs.inc"
.include "gamesettingdefs.inc"
.include "generaldefs.inc"
.include "imudefs.inc"
.include "iodefs.inc"
.include "randomdefs.inc"
.include "sounddefs.inc"
.include "switchdefs.inc"
.include "timer.inc"
;-------------------------------------------------------------------------------



.cseg

; vector jump table
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



;-------------------------------------------------------------------------------
; main program
Start:                              ; start the CPU after a reset
    cli
    ldi     r16, low(stack_top)     ; initialize the stack pointer
    out     SPL, r16
    ldi     r16, high(stack_top)
    out     SPH, r16

    rcall   InitIO                  ; initialize the I/O ports
    rcall   InitChipTimers          ; initialize the IC timers
    rcall   InitSwitch              ; initialize the switch variables
    rcall   InitTimers              ; initialize software timers
    rcall   InitRandom              ; initialize the random number generator
    rcall   InitDisplay             ; initialize the display variables
    rcall   InitSound               ; initialize the sound variables
    rcall   InitSPI                 ; initialize the SPI control register
    rcall   InitIMU                 ; initialize the IMU control registers
    rcall   InitGame                ; initialize the game variables
    rcall   InitSettings            ; initialize the game settings variables
    rcall   InitMusic               ; initialize the music variables
    sei                             ; enable interrupts after initialization
    rjmp    Main                    ; enter the main loop
    rjmp    Start                   ; if Main exits unexpectedly, restart

Main:
    lds     r16, in_game            ; check if in game or menu
    cpi     r16, TRUE               ; if in game
    breq    CallGameLoop            ; call the game loop
    ; brne   CallMenuLoop           ; otherwise call the menu loop

CallMenuLoop:
    rcall   MenuLoop                ; call the menu loop
    rjmp    MainEnd                 ; and return to the main loop

CallGameLoop:
    rcall   GameLoop                ; call the game loop
    ; rjmp    MainEnd               ; and return to the main loop

MainEnd:
    rjmp    Main                    ; loop forever



;-------------------------------------------------------------------------------
; stack space
.dseg

               .byte   127
stack_top:     .byte   1                  ; top of stack



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
.include "shift16.asm"
