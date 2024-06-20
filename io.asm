;-------------------------------------------------------------------------------
; io.asm
;
; Description:
;   This file contains the initialization routines for the I/Os of the board.
;
; Public Functions:
;   IOInit - initialize IO for the display, sound, and SPI
;
; Private Functions:
;   DisplayIOInit - initialize the I/O for the display
;   SoundIOInit - initialize the I/O for the sound
;   SPIIOInit - initialize the I/O for SPI communication
;   SwitchIOInit - initialize the I/O for the switches
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/06/01 - initial revision
;   2024/06/19 - update comments and replace magic numbers with constants
;-------------------------------------------------------------------------------



.cseg

; IOInit
;
; Description:          This procedure initializes the IO ports for the display,
;                       sound, and SPI.
; Operation:            This procedure calls the DisplayIOInit, SoundIOInit, and
;                       SPIIOInit procedures to initialize the IO registers for
;                       the respective functions.
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
; Last Modified:        2024/06/01

InitIO:
    rcall   DisplayIOInit   ; initialize IO for display multiplexing
    rcall   SoundIOInit     ; initialize IO for speaker
    rcall   SPIIOInit       ; initialize IO for SPI communication
    rcall   SwitchIOInit    ; initialize IO for switch inputs
    ret                     ; all done, return



;-------------------------------------------------------------------------------
; DisplayIOInit
;
; Description:          This procedure initializes the I/O for the display.
; Operation:            This procedure will set the sink (A & D) and source (C) 
;                       ports of the display to output.
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
; Last Modified:        5/16/2024

DisplayIOInit:
    ldi	    r16, OUTDATA            ; load all outputs into r16
    out     DISP_SRC_PORT0_DDR, r16 ; set source port as output
    out	    DISP_SRC_PORT1_DDR, r16 ; set source port as output
    out     DISP_SINK_PORT_DDR, r16 ; set sink port as output
    ret



;-------------------------------------------------------------------------------
; SoundIOInit
;
; Description:          This procedure initializes the I/O for the sound.
; Operation:            This procedure will set the speaker pin to be an output
;                       in the speaker port (PORTB)
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

SoundIOInit:
    sbi     SPEAKER_PORT_DDR, SPEAKER_PIN   ; set the speaker pin as output
    ret                                     ; all done, return



;-------------------------------------------------------------------------------
; SPIIOInit
;
; Description:          This procedure initializes the I/O for SPI communication.
; Operation:            This procedure will set the MOSI, SCK, and SS pins to be
;                       outputs and the MISO pin to be an input in the SPI port
;                       (PORTB).
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

SPIIOInit:
    in      r16, SPI_PORT_DDR           ; read the current DDR value
    ; set MOSI, SCK, and SS as outputs
    ori     r16, (1 << SPI_MOSI_PIN) | (1 << SPI_SCK_PIN) | (1 << SPI_SS_PIN)
    andi    r16, ~(1 << SPI_MISO_PIN)   ; set MISO as input
    out     SPI_PORT_DDR, r16           ; write the new DDR value
    ret                                 ; all done, return



;-------------------------------------------------------------------------------
; SwitchIOInit
;
; Description:          This procedure initializes the I/O for switch inputs.
; Operation:            This procedure will set all pins on the switch port
;                       (PORTE) be inputs.
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
;
SwitchIOInit:
    ldi		r16, INDATA             ; load all inputs into r16
    out		SWITCH_PORT_DDR, r16    ; set all pins as inputs
    ret                             ; return