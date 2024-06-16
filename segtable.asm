;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   SEGTABLE                                 ;
;                           Tables of 7-Segment Codes                        ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains tables of 7-segment codes.  The segment ordering is
; given below.  The tables included are:
;    ASCIISegTable - table of codes for 7-bit ASCII characters
;    DigitSegTable - table of codes for hexadecimal digits
;
; Revision History:
;     5/18/24  auto-generated           initial revision
;     5/18/24  Glen George              added DigitSegTable
;     5/18/24  Gavin Hua                added PortAPatterns and PortDPatterns



; local include files
;    none




;table is in the code segment
        .cseg




; ASCIISegTable
;
; Description:      This is the segment pattern table for ASCII characters.
;                   It contains the active-high segment patterns for all
;                   possible 7-bit ASCII codes.  Codes which do not have a
;                   "reasonable" way of being displayed on a 7-segment display
;                   are left blank.  None of the codes set the decimal point.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           auto-generated
; Last Modified:    May 18, 2024

ASCIISegTable:


;        DB       gfeedcba    gfeedcba   ; ASCII character

        .db     0b00000000, 0b00000000   ; NUL, SOH
        .db     0b00000000, 0b00000000   ; STX, ETX
        .db     0b00000000, 0b00000000   ; EOT, ENQ
        .db     0b00000000, 0b00000000   ; ACK, BEL
        .db     0b00000000, 0b00000000   ; backspace, TAB
        .db     0b00000000, 0b00000000   ; new line, vertical tab
        .db     0b00000000, 0b00000000   ; form feed, carriage return
        .db     0b00000000, 0b00000000   ; SO, SI
        .db     0b00000000, 0b00000000   ; DLE, DC1
        .db     0b00000000, 0b00000000   ; DC2, DC3
        .db     0b00000000, 0b00000000   ; DC4, NAK
        .db     0b00000000, 0b00000000   ; SYN, ETB
        .db     0b00000000, 0b00000000   ; CAN, EM
        .db     0b00000000, 0b00000000   ; SUB, escape
        .db     0b00000000, 0b00000000   ; FS, GS
        .db     0b00000000, 0b00000000   ; AS, US

;        DB       gfeedcba    gfeedcba   ; ASCII character

        .db     0b00000000, 0b00000000   ; space, !
        .db     0b01000010, 0b00000000   ; ", #
        .db     0b00000000, 0b00000000   ; $, %
        .db     0b00000000, 0b00000010   ; &, '
        .db     0b01111001, 0b00001111   ; (, )
        .db     0b00000000, 0b00000000   ; *, +
        .db     0b00000000, 0b10000000   ; ,, -
        .db     0b00000000, 0b00000000   ; ., /
        .db     0b01111111, 0b00000110   ; 0, 1
        .db     0b10111011, 0b10001111   ; 2, 3
        .db     0b11000110, 0b11001101   ; 4, 5
        .db     0b11111101, 0b00000111   ; 6, 7
        .db     0b11111111, 0b11000111   ; 8, 9
        .db     0b00000000, 0b00000000   ; :, ;
        .db     0b00000000, 0b10001000   ; <, =
        .db     0b00000000, 0b00000000   ; >, ?

;        DB       gfeedcba    gfeedcba   ; ASCII character

        .db     0b10111111, 0b11110111   ; @, A
        .db     0b11111111, 0b01111001   ; B, C
        .db     0b01111111, 0b11111001   ; D, E
        .db     0b11110001, 0b11111101   ; F, G
        .db     0b11110110, 0b00000110   ; H, I
        .db     0b00111110, 0b00000000   ; J, K
        .db     0b01111000, 0b00000000   ; L, M
        .db     0b00000000, 0b01111111   ; N, O
        .db     0b11110011, 0b00000000   ; P, Q
        .db     0b00000000, 0b11001101   ; R, S
        .db     0b00000000, 0b01111110   ; T, U
        .db     0b00000000, 0b00000000   ; V, W
        .db     0b00000000, 0b11000110   ; X, Y
        .db     0b00000000, 0b01111001   ; Z, [
        .db     0b00000000, 0b00001111   ; \, ]
        .db     0b00000000, 0b00001000   ; ^, _

;        DB       gfeedcba    gfeedcba   ; ASCII character

        .db     0b01000000, 0b00000000   ; `, a
        .db     0b11111100, 0b10111000   ; b, c
        .db     0b10111110, 0b00000000   ; d, e
        .db     0b00000000, 0b11001111   ; f, g
        .db     0b11110100, 0b00000100   ; h, i
        .db     0b00000000, 0b00000000   ; j, k
        .db     0b01110000, 0b00000000   ; l, m
        .db     0b10110100, 0b10111100   ; n, o
        .db     0b00000000, 0b00000000   ; p, q
        .db     0b10110000, 0b00000000   ; r, s
        .db     0b11111000, 0b00111100   ; t, u
        .db     0b00000000, 0b00000000   ; v, w
        .db     0b00000000, 0b11001110   ; x, y
        .db     0b00000000, 0b00000000   ; z, {
        .db     0b00000110, 0b00000000   ; |, }
        .db     0b00000001, 0b00000000   ; ~, rubout




; DigitSegTable
;
; Description:      This is the segment pattern table for hexadecimal digits.
;                   It contains the active-high segment patterns for all hex
;                   digits (0123456789AbCdEF).  None of the codes set the
;                   decimal point.  
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Glen George
; Last Modified:    May 18, 2024

DigitSegTable:


;       db    gfeedcba    gfeedcba   ; Hex Digit

	.db 0b01111111, 0b00000110   ; 0, 1
	.db 0b10111011, 0b10001111   ; 2, 3
	.db 0b11000110, 0b11001101   ; 4, 5
	.db 0b11111101, 0b00000111   ; 6, 7
	.db 0b11111111, 0b11000111   ; 8, 9
	.db 0b11110111, 0b11111100   ; A, b
	.db 0b01111001, 0b10111110   ; C, d
	.db 0b11111001, 0b11110001   ; E, F




; PortAPatterns
;
; Description:      This is the segment pattern table for the Port A, for the 
;                   7-segment display and the game LEDs.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    5/18/2024
PortAPatterns:
	.db	0b00000001, 0b00000010
	.db	0b00000100, 0b00001000
	.db	0b00010000, 0b00100000
	.db	0b01000000, 0b00000000
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000000


; PortDPatterns
;
; Description:      This is the segment pattern table for the Port D, for the 
;                   7-segment display and the game LEDs.
;
; Notes:            READ ONLY tables should always be in the code segment so
;                   that in a standalone system it will be located in the
;                   ROM with the code.
;
; Author:           Gavin Hua
; Last Modified:    5/18/2024
PortDPatterns:
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000000
	.db	0b00000000, 0b00000010
	.db	0b00000001, 0b00000100
	.db	0b00001000, 0b00010000
	.db	0b00100000, 0b01000000