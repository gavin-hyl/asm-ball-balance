;-------------------------------------------------------------------------------
; chiptimer.asm
;
; Description:
;	This file contains the functions to setup hardware timers and handle timer
;	interrupts.
;
; Public Functions:
;	InitChipTimers - calls initialization functions for timer 0 and 1
;   Timer0CompareMatchHandler - Timer0 compare match interrupt handler, calls
;                               button debouncing, display multiplexing, and
; 								software timer handlers.
;
; Private Functions: 
;	InitTimer0 - Set timer0 to overflow and generate interrupts at 1 kHz
;   InitTimer1 - Set timer1 to toggle OC1A pin on compare match at 125 kHz
; 
; Author:
; 	Gavin Hua
;
; Revision History: 
;	2024/05/18 - Initial Revision
;	2024/06/01 - Added InitTimer1
;	2024/06/15 - Change interrupt handler name to reflect that it is called when
;				 compare match interrupt occurs, added software timer handler
;				 call in that function.
;	2024/06/19 - Rename file to chiptimer.asm and upate comments
;
;-------------------------------------------------------------------------------



.cseg

; InitChipTimers
;
; Description:          This procedure initializes timer 0 and 1 on the chip to
;						drive button debouncing, display multiplexing, and
;						software timer handling.
; Operation:            This procedure calls InitTimer0 and InitTimer1.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     None.
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
; Registers changed:    r16.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

InitChipTimers:
	rcall 	InitTimer0	; initialize timer 0 (r16 changed)
	rcall 	InitTimer1 	; initialize timer 1 (r16 changed)
	ret



;-------------------------------------------------------------------------------
; InitTimer0
;
; Description:          This procedure initializes timer 0 to generate compare
;						match interrupts at 1 kHz to drive button debouncing and
;						display multiplexing.
; Operation:            This procedure will set the prescaler and compare
;						register of timer 0 to 64 and 125 respectively, and
;						enable match interrupts to generate 1 kHz compare match
;						interrupts.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     None.
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
; Registers changed:    r16.
;
; Stack Depth:          0 bytes.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

InitTimer0:
	clr		r16						; prepare to clear timer 0 counter
	out		TCNT0, r16             	; clear timer 0 counter
	ldi		r16, TIMER_CLK_64		; use CLK/8 as timer source, gives
	ori     r16, (1 << CTC0)		; enable CTC mode
	out		TCCR0, r16		        ; 8 MHz / 64 = 125 kHz
	ldi     r16, 125				; 125 kHz / 125 = 1 kHz
	out     OCR0, r16				; set compare value for 1 kHz
	in      r16, TIMSK				; get current timer interrupt masks
	ldi     r16, 1 << OCIE0			; enable timer 0 match interrupt
	out     TIMSK, r16				; and store it back
	ret								; done, so return



;-------------------------------------------------------------------------------
; InitTimer1
;
; Description:          This procedure initializes timer 1 to operate at 125 kHz
;						to drive speaker output.
;
; Operation:            This procedure will set the timer1 to operate in CTC,
;                       toggle OC1A on compare match, and set prescaler to 64.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     None.
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
; Registers changed:    r16.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

InitTimer1:
    ldi 	r16, (1 << COM1A0)					; toggle OC1A (speaker pin) on
    out 	TCCR1A, r16							; compare match
    ldi 	r16, (1 << WGM12) | TIMER_CLK_64	; CTC mode, CLK/64 gives
    out 	TCCR1B, r16							; 8e6 / 64 = 125 kHz
	ret



;-------------------------------------------------------------------------------
; Timer0CompareMatchHandler
;
; Description:          This procedure expects to be called by the Timer0
;                       compare match interrupt every 1 ms. This procedure will
;						call the display multiplexer, button debouncer, and
;						software timer handler.
;
; Operation:            Pushes the registers (including SREG) used by the called
;						functions onto the stack, calls the aforementioend
;						functions, and pops the registers off the stack.
;
; Arguments:            None.
; Return Value:         None.
;
; Global Variables:     None.
; Shared Variables:     None.
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
; Registers changed:    None.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/19

Timer0CompareMatchHandler:
	push	r16					; push all registers including SREG
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21
	push	r22
	push	r23
	push	r24
	push	r25
	push	r26
	push	r27
	push	r28
	push	r29
	push	r30
	push	r31
	push    r0
    in      r0, SREG
    push    r0
	rcall	DisplayMux			; call display multiplexer
	rcall   DebounceButtons		; call button debouncer
	rcall   TimerHandler		; call software timer handler
    pop     r0					; pop all registers in reverse order
    out     SREG, r0
	pop     r0
	pop		r31
	pop		r30
	pop		r29
	pop		r28
	pop		r27
	pop		r26
	pop		r25
	pop		r24
	pop		r23
	pop		r22
	pop		r21
	pop		r20
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	reti						; all done, return from interrupt
