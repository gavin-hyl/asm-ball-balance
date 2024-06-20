;-------------------------------------------------------------------------------
; music.asm
;
; Description:
;   This file contains the routines and data for playing music.
;
; Public Functions:
;   InitMusic - initialize the music variables
;   SoundTimerHandler - handles sound timer expirations, expects to be called
;                       every 10 ms.
;   PlaySequence - sets variables to play a sequence of notes
;
; Private Functions:
;   GetNote - get the next note from the current sequence
;
; Tables:
;   WinMusic - the frequency and duration of the notes for the win music
;   LoseMusic - the frequency and duration of the notes for the lose music
;   GameMusic - the frequency and duration of the notes for the game music
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/06/10 - initial revision
;   2024/06/19 - update comments
;-------------------------------------------------------------------------------



.dseg

repeat:             .byte 1 ; FALSE->play sequence once, TRUE->repeat
note_tick_cnt:      .byte 1 ; the remaining ticks (100 ms) for the current note
curr_note:          .byte 1 ; the current note index
curr_sequence:	    .byte 2 ; the current sequence byte address
playing_sequence:   .byte 1 ; TRUE->playing sequence, FALSE->not playing



;-------------------------------------------------------------------------------
.cseg

; InitMusic
;
; Description:          This procedure initializes the music variables and calls
;                       the StartSoundTimer procedure to start the sound timer.
; Operation:            The procedure sets playing_sequence and repeat to FALSE,
;                       curr_note and note_tick_cnt to 0, and curr_sequence to 0.
;                       It then calls StartSoundTimer to start the sound timer.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None. 
; Shared Variables:     playing_sequence - set to FALSE
;                       repeat - set to FALSE
;                       curr_note - set to 0
;                       note_tick_cnt - set to 0
;                       curr_sequence - set to 0x0000
;                       delay_timer - word corresponding to the sound timer is 
;                                     set to RANDOM_EVENT_TIMER_PERIOD.
; Local Variables:      tmp (r16) - used to load variables
;
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r0, r16, X, Y, SREG.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

InitMusic:
    ldi     r16, FALSE              ; prepare to set variables to FALSE
    sts     playing_sequence, r16   ; set playing_sequence to FALSE
    sts     repeat, r16             ; set repeat to FALSE
    clr     r16                     ; prepare to set variables to 0
    sts     curr_note, r16          ; set curr_note to 0
    sts     note_tick_cnt, r16      ; set note_tick_cnt to 0
    sts     curr_sequence, r16      ; set curr_sequence to 0x0000
    sts     curr_sequence+1, r16
    rcall   StartSoundTimer         ; start the sound timer
    ret                             ; all done, return



;-------------------------------------------------------------------------------
; SoundTimerHandler
;
; Description:          This procedure handles sound timer expirations. It
;                       expects to be called every 10 ms. It checks whether the
;                       current note has finished playing, and if so, it gets
;                       the next note and plays it. If the sequence has ended,
;                       it checks whether to repeat the sequence or to stop.
; Operation:            The procedure checks if playing_sequence is FALSE, and
;                       if so, it returns. It then checks if the current note
;                       has finished playing. If not, it decrements note_tick_cnt
;                       and returns. If the current note has finished playing,it
;                       increments curr_note, gets the next note, and plays it.
;                       If the sequence has ended, it checks if repeat is TRUE,
;                       and if so, it repeats the sequence. If repeat is FALSE,
;                       it initializes the music variables and stops playing.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None. 
; Shared Variables:     playing_sequence - checked, possibly set to FALSE
;                       repeat - read only
;                       curr_note - read, possibly incremented
;                       note_tick_cnt - decremented/reset
;                       curr_sequence - read, possibly reset
;                       delay_timer - read only
; Local Variables:      tmp (r16) - used to load variables
;
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r0, r2, r3, r16, r17, r20, r22, Z, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

SoundTimerHandler:
    lds     r16, playing_sequence   ; load playing_sequence to check
    cpi     r16, FALSE              ; check if playing_sequence is FALSE
    breq    SoundTimerHandlerEnd    ; if so, return
    ; brne  CheckTickCnt            ; if not, check if the current note has finished

CheckTickCnt:
    lds     r16, note_tick_cnt      ; load note_tick_cnt
    dec     r16                     ; decrement and test note_tick_cnt
    breq    NewNote                 ; if note_tick_cnt is 0, get the next note
    ; brne  ContinueNote            ; if not, continue playing the current note

ContinueNote:
    sts     note_tick_cnt, r16      ; store the decremented note_tick_cnt
    rjmp    SoundTimerHandlerEnd    ; and return

NewNote:
    lds     r16, curr_note          ; load the current note index
    inc     r16                     ; increment it to the next note
    sts     curr_note, r16          ; store the new note index
    rcall   GetNote                 ; get the next note
    lds     r18, note_tick_cnt      ; load the duration of the note
    tst     r18                     ; and check if it is 0
    brne    PlayNewNote             ; if not, then play the note
    ; breq CheckRepeat              ; if so, the sequence ends, check repeat

CheckRepeat:
    lds     r16, repeat             ; load repeat
    cpi     r16, TRUE               ; check if repeat is TRUE
    breq    RepeatSequence          ; if so, repeat the sequence
    rcall   InitMusic               ; if not, reset the music variables
    clr     r16                     ; and stop playing
    clr     r17
    rjmp    PlayNewNote             ; by playing a 0 frequency note (mute)

RepeatSequence:
    clr     r16                     ; set curr_note to 0
    sts     curr_note, r16          ; to repeat the sequence from the start
    rcall   GetNote                 ; get the first note
    ; rjmp PlayNewNote              ; and play it

PlayNewNote:
    rcall   PlayNote                ; play a new note

SoundTimerHandlerEnd:
    rcall   StartSoundTimer         ; restart the sound timer
    ret                             ; all done, return


;-------------------------------------------------------------------------------
; GetNote
;
; Description:          This procedure gets the next note from the current
;                       sequence, returns the frequency in r17|r16, and the
;                       duration in note_tick_cnt.
; Operation:            The procedure loads the current note index from curr_note
;                       and gets the note from the current sequence. It then
;                       sets note_tick_cnt to the duration of the note.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     curr_note - read
;                       curr_sequence - read
;                       note_tick_cnt - set
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
; Registers changed:    r0, r16, r17, Z.
;

GetNote:
    lds     r16, curr_note      ; load the current note index
    lsl     r16                 ; multiply by 2 since each note entry is 2 bytes

    clr     r0                  ; clear r0 for carry propagation
    lds     ZL, curr_sequence   ; load the sequence address
    lds     ZH, curr_sequence+1 ; into the Z pointer
    add     ZL, r16             ; and point Z to the current note
    adc     ZH, r0              ; propage carry to ZH
    lpm     r16, Z+             ; load the frequency of the note
    lsl     r16                 ; multiply by 2 (since previously divided)
    clr     r17                 ; clear r17 for carry propagation
    rol     r17                 ; propagate carry to r17, frequency restored
    lpm     r0, Z               ; load the duration of the note
    sts     note_tick_cnt, r0   ; set note_tick_cnt to the duration
    ret                         ; all done, return


;-------------------------------------
; PlaySequence
;
; Description:          This procedure sets the shared variables variables to 
;                       play a sequence of notes.
; Operation:            The procedure loads the first note from the sequence
;                       and plays it. It then sets the shared variables to play
;                       the sequence. It sets playing_sequence to TRUE,curr_note
;                       to 0, and note_tick_cnt to the duration of the first
;                       note. Note that this function does not handle setting
;                       or clearing the repeat flag.
;
; Arguments:            Z - the byte address of the sequence to play
; Return Value:         None.
;
; Global Variables:     None. 
; Shared Variables:     playing_sequence - set to TRUE
;                       curr_note - set to 0
;                       note_tick_cnt - set to the duration of the first note
;                       curr_sequence - set to byte address of the sequence
; Local Variables:      f (r17|r16) - used to call PlayNote
;                       tmp (r16) - used to load variables
;
; Input:                None.
; Output:               None.
;   
; Error Handling:       None.
;   
; Algorithms:           None.
; Data Structures:      None.
;
; Registers changed:    r0, r2, r3, r16, r17, r20, r22, X, Y, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/10

PlaySequence:
    lpm     r16, Z+                 ; load the frequency of the first note
    lsl     r16                     ; multiply by 2 (since previously divided)
    clr     r17                     ; clear r17 for carry propagation
    rol     r17                     ; propagate carry to r17, frequency restored
    rcall   PlayNote                ; play the frequency in r17|r16
    lpm     r16, Z                  ; load the duration of the first note
    sbiw    Z, 1                    ; point Z to the start of the sequence
    in      r0, SREG                ; critical code start
    cli
    sts     curr_sequence, ZL       ; set the sequence address (low byte)
    sts     curr_sequence+1, ZH     ; set the sequence address (high byte)
    sts     note_tick_cnt, r16      ; set node_tick_cnt to the first duration
    ldi     r16, TRUE               ; set playing_sequence to TRUE
    sts     playing_sequence, r16   
    ldi     r16, 0                  ; set curr_note to 0 since playing the first
    sts     curr_note, r16
    out     SREG, r0                ; critical code end
    ret                             ; all done, return


;-------------------------------------------------------------------------------
.cseg

; WinMusic
;
; Description:      This table contains the frequency and duration of the notes
;                   for the win music. The frequency is divided by 2 to make
;                   the frequency fit into a single byte. The sequence's end is
;                   marked by a 0x00 frequency and 0 duration.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    2024/06/18

WinMusic:
    ;db     freq / 2,   duration
	.db	    261 / 2,    10      ; C
	.db	    330 / 2,    10      ; E
	.db	    391 / 2,    10      ; G
	.db	    330 / 2,    10      ; E
	.db	    261 / 2,    10      ; C
    .db     0x00,       10      ; pause
    .db	    0x00,	    0       ; end



;-------------------------------------------------------------------------------
; LoseMusic
;
; Description:      This table contains the frequency and duration of the notes
;                   for the lose music. The frequency is divided by 2 to make
;                   the frequency fit into a single byte. The sequence's end is
;                   marked by a 0x00 frequency and 0 duration.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    2024/06/18

LoseMusic:
    ;db     freq / 2,   duration
    .db     330 / 2,    10      ; E
    .db     261 / 2,    10      ; C
    .db     245 / 2,    10      ; B
    .db     0x00,       10      ; pause
    .db     0x00,       0       ; end



;-------------------------------------------------------------------------------
; GameMusic
;
; Description:      This table contains the frequency and duration of the notes
;                   for the game music. The frequency is divided by 2 to make
;                   the frequency fit into a single byte. The sequence's end is
;                   marked by a 0x00 frequency and 0 duration.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    2024/06/18

GameMusic:
    ;db     freq / 2,   duration
    .db     261 / 2,    5       ; C
    .db     277 / 2,    5       ; C#
    .db     293 / 2,    5       ; D
    .db     311 / 2,    5       ; D#
    .db     330 / 2,    5       ; E
    .db     311 / 2,    5       ; D#
    .db     293 / 2,    5       ; D
    .db     277 / 2,    5       ; C#
    .db     0,          10      ; pause
    .db     0x00,       0       ; end
