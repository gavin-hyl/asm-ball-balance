;-------------------------------------------------------------------------------
; File:             sound.asm
; Description:      This file contains the functions to initialize the speaker
;                   and play a frequency.
; Public Functions: SoundInit   - Initialize the speaker
;                   PlayNote    - Play a note
;
; Author:           Gavin Hua
; Revision History: 6/01/2024   - Initial Revision
;-------------------------------------------------------------------------------


.cseg

; SoundInit
; 
; Description:          Turns off the speaker. I/O initialization is done in
;                       the general I/O initialization function.
; Operation:            This function calls PlayNote with frequency 0 Hz.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      None
;
; Input:                None.
; Output:               If the speaker is on, it is turned off.
;
; Error Handling:       None.
;
; Algorithms:           None.
; Data Structures:      None.
;
; Registers Used:       r16, r17
; Stack Depth:          0
;
; Author:               Gavin Hua
; Last Modified:        6/01/2024

InitSound:
    clr     r17
    clr     r16
    rcall   PlayNote
    ret


; PlayNote
; 
; Description:          The function plays the note with the passed frequency 
;                       (f, in Hz) on the speaker. This tone is output until a new
;                       tone is output via this function. f = 0 Hz
;                       turns off the speaker output. The max value of f is 
;                       65536 Hz, which is the maximum unsigned number that can
;                       be stored in 2 bytes.
; Operation:            The function computes the compare register value by
;                       dividing the scaled clock frequency with double the
;                       output frequency and writes it to the output compare
;                       register if f is not 0 Hz. Otherwise, the speaker is 
;                       turned off.
; 
; Arguments:            r17|r16 - the frequency to play, in Hz.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      None.
; 
; Input:                None.
; Output:               The speaker plays the note with frequency f, if f>0 Hz.
;   
; Error Handling:       If f = 0Hz, then nothing is output.
;   
; Algorithms:           Restoring division.
; Data Structures:      None.
;
; Registers Used:       r16, r17
; Stack Depth:          0
;
; Author:               Gavin Hua
; Last Modified:        2024/06/01

PlayNote:
    cpi     r17, high(FREQ_OFF)
    brne    ComputeCompareValue    ; f > 0 Hz, compute compare value
    cpi     r16, low(FREQ_OFF)
    brne    ComputeCompareValue    ; f > 0 Hz, compute compare value
    ; breq Mute                 ; f = 0 Hz, turn off speaker

Mute:
    cbi     SPEAKER_PORT_DDR, SPEAKER_PIN            ; disable speaker
    rjmp    PlayNoteEnd

ComputeCompareValue:
    movw    r20, r16                    ; Div16 expects the divisor in r21:r20
    ldi     r17, HIGH(FREQ_DIV)         ; Div16 expects the dividend in r17|r16
    ldi     r16, LOW(FREQ_DIV)
    rcall   Div16
    cbi     SPEAKER_PORT_DDR, SPEAKER_PIN   ; disable speaker while loading
    out     OCR1AH, r17
    out     OCR1AL, r16
    sbi     SPEAKER_PORT_DDR, SPEAKER_PIN            ; enable speaker
    ; rjmp PlayNoteEnd

PlayNoteEnd:
    ret