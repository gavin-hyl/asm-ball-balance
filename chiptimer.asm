;-------------------------------------------------------------------------------
; File:             timer.asm
; Description:      This file contains the functions to setup the timers, and
;                   the interrupt service routines for the timers.
; Public Functions: TimerInit   - Initialize the timers
;                   Timer0OverflowHandler - Timer0 overflow interrupt handler
;
; Author:           Gavin Hua
; Revision History: 2024/05/18 	- Initial Revision
;					2024/06/01  - Added Timer1Init
;-------------------------------------------------------------------------------

.cseg


; TimerInit
;
; Description:          This procedure initializes timer0 and timer1 for driving
;                       the LEDs and speaker.
; Operation:            This procedure calls Timer0Init and Timer1Init.
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
; Last Modified:        5/4/2024

InitChipTimers:
	rcall 	Timer0Init
	rcall 	Timer1Init
	ret


; Timer0Init
;
; Description:          This procedure initializes timer0 for driving the LEDs
;                       and button debouncing.
; Operation:            This procedure will set the timer0 to overflow at 4 kHz,
;                       and enable the timer0 overflow interrupt.
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
; Last Modified:        5/4/2024

Timer0Init:
	clr		r16
	out		TCNT0, r16             	; clear timer 0 counter
	ldi		r16, TIMER_CLK_8		; use CLK/8 as timer source, gives
	out		TCCR0, r16		        ; 8 MHz / 8 / 256, rate = 4 kHz
	in		r16, TIMSK		    	; get current timer interrupt masks
	ori		r16, 1 << TOV0			; turn on timer 0 interrupts
	out		TIMSK, r16
	ret


; Timer1Init
;
; Description:          This procedure initializes timer1 for driving the speaker.
; Operation:            This procedure will set the timer1 to operate in CTC,
;                       toggle OC1A on compare match, and set prescaler to 64
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
; Last Modified:        5/31/2024

Timer1Init:
    ldi 	r16, (1 << COM1A0)					; toggle OC1A on compare match
    out 	TCCR1A, r16
    ldi 	r16, (1 << WGM12) | TIMER_CLK_64	; CTC mode, CLK/64 gives 125 kHz
    out 	TCCR1B, r16
	ret


; DisplayTimerIRQ
;
; Description:          This procedure expects to be called by the Timer0
;                       overflow interrupt. This procedure will call the display
;                       multiplexer, which will update the display LEDs.
; Operation:            Pushes the registers onto the stack, calls the display
;                       multiplexer, and pops the registers off the stack.
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
; Stack Depth:          16 bytes.
;
; Author:               Gavin Hua
; Last Modified:        5/18/2024

Timer0OverflowHandler:
	push	r16
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
	rcall	DisplayMux
	rcall   DebounceButtons
	rcall   TimerHandler
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
	reti
