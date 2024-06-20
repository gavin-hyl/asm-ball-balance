;-------------------------------------------------------------------------------
; sound.asm
;
; Description:
;   This file contains the functions to initialize and play notes on the speaker.
;
; Public Functions:
;   SoundInit - Initialize the speaker
;   PlayNote - Play a note
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/06/01 - initial revision
;   2024/06/19 - add comments
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
;
; Author:               Gavin Hua
; Last Modified:        2024/06/01

InitSound:
    clr     r17         ; set up call to PlayNote
    clr     r16         ; frequency = 0 Hz
    rcall   PlayNote    ; playing 0 Hz turns off the speaker
    ret                 ; all done, return



;-------------------------------------------------------------------------------
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
; Arguments:            r17|r16 - the frequency to play, in Hz. The valid range
;                                 is 1 to 65535 Hz. If f = 0 Hz, the speaker is
;                                 turned off.
; Return Value:         None.
; 
; Global Variables:     None.
; Shared Variables:     None.
; Local Variables:      None.
; 
; Input:                None.
; Output:               The speaker plays the frequency f, if f > 0 Hz. It is
;                       turned off iff f = 0 Hz.
;   
; Error Handling:       If f = 0Hz, then nothing is output.
;   
; Algorithms:           Restoring division.
; Data Structures:      None.
;
; Registers Used:       r2, r3, r16, r17, r20, r22, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/01

PlayNote:
    mov     r20, r16                        ; check whether the f=0 Hz
    or      r20, r17                        ; which is the same as r17||r16 = 0
    brne    ComputeCompareValue             ; f > 0 Hz, compute compare value
    ; breq Mute                             ; f = 0 Hz, turn off speaker

Mute:
    cbi     SPEAKER_PORT_DDR, SPEAKER_PIN   ; disable speaker
    rjmp    PlayNoteEnd                     ; done

ComputeCompareValue:
    movw    r20, r16                        ; set up call to Div16
                                            ; divisor in r21|r20
    ldi     r17, HIGH(FREQ_DIV)             ; dividend in r17|r16
    ldi     r16, LOW(FREQ_DIV)
    rcall   Div16                           ; compute the compare register value
    cbi     SPEAKER_PORT_DDR, SPEAKER_PIN   ; disable speaker while loading
    out     OCR1AH, r17                     ; load the compare value
    out     OCR1AL, r16                     ; corresponding to the frequency
    sbi     SPEAKER_PORT_DDR, SPEAKER_PIN   ; enable speaker
    ; rjmp PlayNoteEnd                      ; done

PlayNoteEnd:
    ret                                     ; all done, return