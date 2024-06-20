;-------------------------------------------------------------------------------
; iodefs.inc
; Description:
;   This file contains the definitions related to IO setup.
;
; Author:
;   Gavin Hua
; Revision History:
;   2024/05/16 - initial revision
;   2024/05/18 - debug and test
;   2024/06/01 - add SPI and speaker definitions
;   2024/06/19 - update comments
;-------------------------------------------------------------------------------



; I/O port data direction register definitions
.equ	OUTDATA		        = 0b11111111    ; all pins are output
.equ    INDATA		        = 0b00000000    ; all pins are input

; display definitions
.equ    DISP_SRC_PORT_DDR   = DDRC  
.equ    DISP_SINK_PORT0_DDR = DDRA
.equ    DISP_SINK_PORT1_DDR = DDRD
.equ    DISP_SRC_PORT       = PORTC
.equ    DISP_SINK_PORT0     = PORTA
.equ    DISP_SINK_PORT1     = PORTD

; Speaker definitions
.equ    SPEAKER_PORT        = PORTB         ; port where the speaker is on
.equ    SPEAKER_PORT_DDR    = DDRB          ; DDR for the speaker port
.equ    SPEAKER_PIN         = 5             ; pin where the speaker is on

; SPI definitions
.equ    SPI_PORT            = PORTB         ; port where SPI pins are on
.equ    SPI_PORT_DDR        = DDRB          ; DDR for the SPI port
.equ    SPI_SS_PIN          = 0             ; pin for SPI slave select
.equ    SPI_SCK_PIN         = 1             ; pin for SPI clock
.equ    SPI_MOSI_PIN        = 2             ; pin for SPI MOSI
.equ    SPI_MISO_PIN        = 3             ; pin for SPI MISO

; IMU definitions
.equ    IMU_PORT            = SPI_PORT      ; IMU uses the SPI port
.equ    IMU_SS_PIN          = SPI_SS_PIN    ; IMU uses the SPI slave select pin

; Switch definitions
.equ    SWITCH_PORT         = PORTE         ; port where the switches are on
.equ    SWITCH_PORT_DDR     = DDRE          ; DDR for the switch port