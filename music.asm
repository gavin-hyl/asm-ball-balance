.dseg

repeat:             .byte 1
note_tick_cnt:      .byte 1
curr_note:          .byte 1
curr_sequence:	    .byte 2
playing_sequence:   .byte 1


.cseg

SoundTimerHandler:
    ldi     r16, TRUE
    sts     playing_sequence, r16
    lds     r16, note_tick_cnt
    dec     r16
    breq    NewNote

ContinueNote:
    sts     note_tick_cnt, r16
    rjmp    SoundTimerHandlerEnd

NewNote:
    lds     r16, curr_note
    inc     r16
    sts     curr_note, r16
    rcall   GetNote
    tst     r16
    brne    PlayNewNote
    ; breq CheckRepeat

CheckRepeat:
    lds     r16, repeat
    cpi     r16, TRUE
    breq    RepeatSequence
    ldi     r16, FALSE
    sts     playing_sequence, r16
    clr     r16
    clr     r17
    rcall   PlayNote
    rjmp    SoundTimerHandlerEnd

RepeatSequence:
    clr     r16
    sts     curr_note, r16
    rcall   GetNote
    ; rjmp PlayNewNote

PlayNewNote:
    rcall   PlayNote

SoundTimerHandlerEnd:
    rcall   StartSoundTimer
    ret


;-------------------------------------

GetNote:
    lds     r16, curr_note
    lsl     r16
    clr     r0
    lds     ZL, curr_sequence
    lds     ZH, curr_sequence+1
    add     ZL, r16
    adc     ZH, r0
    lpm     r16, Z+
    lsl     r16
    clr     r17
    adc     r17, r17
    lpm     r0, Z
    sts     note_tick_cnt, r0
    ret

;-------------------------------------


; shift by 2 to make everything fit in one byte
WinMusic:
    .db     261 / 2, 10    ; C
    .db     330 / 2, 10    ; E
    .db     330 / 2, 10    ; G
    .db     261 / 2, 10    ; E
    .db     392 / 2, 10    ; C
    .db     0x00, 0         ; end

LoseMusic:
    .db     330 / 2, 10    ; E
    .db     261 / 2, 10    ; C
    .db     245 / 2, 10    ; B
    .db     0x00,    0     ; end

GameMusic:
    .db     261 / 2, 5     ; C
    .db     277 / 2, 5     ; C#
    .db     293 / 2, 5     ; D
    .db     311 / 2, 5     ; D#
    .db     330 / 2, 5     ; E
    .db     311 / 2, 5     ; D#
    .db     293 / 2, 5     ; D
    .db     277 / 2, 5     ; C#
    .db     261 / 2, 5     ; C
    .db     0x00, 0         ; end
