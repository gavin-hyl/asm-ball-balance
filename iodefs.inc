;-------------------------------------------------------------------------------
; File:             iodefs.inc
; Description:      This file contains the definitions related to IO setup.
;
; Author:           Gavin Hua
; Revision History: 5/16/2024 - Initial revision
;                   5/18/2024 - Debug and test
;                   6/1/2024 - Add SPI and speaker definitions
;-------------------------------------------------------------------------------

; I/O port data direction register definitions
.equ	OUTDATA		        = 0b11111111
.equ    INDATA		        = 0b00000000

; display definitions
.equ    DISP_SINK_PORT_DDR  = DDRC
.equ    DISP_SRC_PORT0_DDR  = DDRA
.equ    DISP_SRC_PORT1_DDR  = DDRD
.equ    DISP_SINK_PORT      = PORTC
.equ    DISP_SRC_PORT0      = PORTA
.equ    DISP_SRC_PORT1      = PORTD
.equ    SEG_MSG_LENGTH      = 4

; Speaker definitions
.equ    SPEAKER_PORT        = PORTB
.equ    SPEAKER_PORT_DDR    = DDRB
.equ    SPEAKER_PIN         = 5

; SPI definitions
.equ    SPI_PORT            = PORTB
.equ    SPI_PORT_DDR        = DDRB
.equ    SPI_SS_PIN          = 0
.equ    SPI_SCK_PIN         = 1
.equ    SPI_MOSI_PIN        = 2
.equ    SPI_MISO_PIN        = 3

; IMU definitions
.equ    IMU_PORT            = SPI_PORT
.equ    IMU_SS_PIN          = SPI_SS_PIN