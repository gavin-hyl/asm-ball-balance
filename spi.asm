;-------------------------------------------------------------------------------
; spi.asm
;
; Description:
;   This file contains the functions to set up and use the SPI interface. The
;   settings are configured to match the MPU6500's requirements.
;
; Public Functions:
;   SPIInit - Initialize SPI
;   SPITxRx - Transmit and receive data over SPI
;
; Author:
;   Gavin Hua
;
; Revision History:
;   2024/06/01 - initial revision
;   2024/06/20 - add comments
;-------------------------------------------------------------------------------



.cseg

; SPIInit
;
; Description:  Initializes the SPI control register to conform to the MPU6500's
;               SPI communication requirements.
; Operation:    Disables SPI interrupt, enables SPI, sets MSB first, master mode,
;               SCK idle high, sample on rising edge, f_spi = f_osc/16.
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
; Registers changed:    r16, SREG
;
; Author:               Gavin Hua
; Last Modified:        2024/06/01

InitSPI:
    ldi     r16, ~(1 << SPIE)   ; disable SPI interrupt
    ori     r16, (1 << SPE)     ; enable SPI
    andi    r16, ~(1 << DORD)   ; MSB first
    ori     r16, (1 << MSTR)    ; master mode
    ori     r16, (1 << CPOL)    ; SCK idle high
    ori     r16, (1 << CPHA)    ; sample on rising edge
    andi    r16, ~(1 << SPR1)   ; f_spi = f_osc/16 (SPR[1:0] = 0b01)
    ori     r16, (1 << SPR0)    ; since MPU6500 SPI max frequency is 1MHz
    out     SPCR, r16           ; set control register
    cbi     SPSR, SPIF          ; clear to avoid problems in first transmission
    ret



;-------------------------------------------------------------------------------
; SPITxRx
;
; Description:  Transmits and receives a byte of data over SPI. This function
;               does not toggle the SS pin, and the caller is responsible for
;               toggling the SS pin before and after calling this function.
; Operation:    Loads data to be transmitted into SPDR, waits for transmission
;               to complete, reads received data from SPDR.
;
; Arguments:    r16 - data to be transmitted.
; Return Value: r16 - received data.
;
; Global Variables: None.
; Shared Variables: None.
; Local Variables: None.
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

SPITxRx:
    out     SPDR, r16       ; load data to be transmitted
    ; rjmp TransmitWait     ; start transmission

TransmitWait:
    sbis    SPSR, SPIF      ; wait for transmission to complete (SPIF set)
    rjmp    TransmitWait    ; if not done yet, keep looping and checking
    ; rjmp TransmitFinish   ; if done, read received data

TransmitFinish:
    in      r16, SPDR       ; read received data
    ret                     ; all done, return
