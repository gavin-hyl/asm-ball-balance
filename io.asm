;-------------------------------------------------------------------------------
; File:             io.asm
; Description:  	This file contains the initialization routines for the I/Os
;               	of the board.
; Public Functions: IOInit      - initialize the DDRx registers for the display,
;               	sound, and SPI I/Os
;
; Author:           Gavin Hua
; Revision History: 2024/06/01  - Initial revision
;-------------------------------------------------------------------------------


.cseg

; IoInit
;
; Description:          This procedure initializes the IO ports for the display,
;                       sound, and SPI.
; Operation:            This procedure calls the DisplayIOInit, SoundIOInit, and
;                       SPIIOInit procedures to initialize the DDRx registers for
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
; Stack Depth:          0 bytes.
;
; Author:               Gavin Hua
; Last Modified:        2024/06/01

InitIO:
    rcall   DisplayIOInit
    rcall   SoundIOInit
    rcall   SPIIOInit
    rcall   SwitchIOInit
    ret


; DisplayIOInit
;
; Description:          This procedure initializes the I/O for the display.
; Operation:            This procedure will set the sink and source ports of the
;                       display to output.
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
; Last Modified:        5/16/2024

DisplayIOInit:
    ldi	    r16,	OUTDATA
    out     DISP_SRC_PORT0_DDR,   r16
    out	    DISP_SRC_PORT1_DDR,   r16
    out     DISP_SINK_PORT_DDR,   r16
    ret


; SoundIOInit
;
; Description:          This procedure initializes the I/O for the sound.
; Operation:            This procedure will set the speaker pin to be an output.
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
; Last Modified:        5/16/2024

SoundIOInit:
    sbi     SPEAKER_PORT, SPEAKER_PIN
    ret


; SPIIOInit
;
; Description:          This procedure initializes the I/O for SPI communication.
; Operation:            This procedure will set the MOSI, SCK, and SS pins to be
;                       outputs and the MISO pin to be an input in the SPI port.
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
; Last Modified:        5/16/2024

SPIIOInit:
    in      r16, SPI_PORT_DDR
    ; set MOSI, SCK, and SS as outputs
    ori     r16, (1 << SPI_MOSI_PIN) | (1 << SPI_SCK_PIN) | (1 << SPI_SS_PIN)
    andi    r16, ~(1 << SPI_MISO_PIN)  ; set MISO as input
    out     SPI_PORT_DDR, r16
    ret


SwitchIOInit:
    ldi		r16,	INDATA
    out		DDRE,	r16
    ret