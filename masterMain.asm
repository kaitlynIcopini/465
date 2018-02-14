;Main.s by Michael Oswald and Kaitlyn Icopini
;//18
;Lab1:

; Include derivative-specific definitions
INCLUDE 'derivative.inc'

; export symbols
XDEF _Startup, main
XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack

MY_ZEROPAGE: SECTION
 	charCode: DS.B 1
 	column: DS.B 1

;Code section
MyCode: SECTION

main:
_Startup:

 	;Turns off watchdog
 	BCLR SOPT1_COPE, SOPT1

  	;Sets pin 2 to BKGD mode
  	BSET SOPT1_BKGDPE, SOPT1

  	;Sets pin 1 to RESET
  	BSET SOPT1_RESTPE, SOPT1

  	;Sets the I2C lines, PTB 7 as SCL and PTB 6 as SDA
  	BSET SOPT2_IICPS, SOPT2

  	;Gives master an address for I2C
  	;LDA #%_ _ _ _ _ _ _ 0
  	;STA IICA

  	;Set PTB pins 2-5 to be an output
 	  MOV #%00111100, PTBDD

  	;Turns on PTB pins 2-5
  	MOV #%00111100, PTBD

  	;Sets PTA pins 0-3 to be an input
  	MOV #%00001111, PTADD

  	;Turns off PTA pins 0-3
  	MOV #%00000000, PTAD

  	;initialize pull down resistors
  	;Sets the keyboard interrupt to trigger on a rising edge on PTA pins 0-3 (pulldown)
  	MOV #%00001111, KBIES

	  ;Enables internal resistors on PTA pins 0-3
	  MOV #%00001111, PTAPE

	  ;Sets the keyboard detection mode to detect edges
	  BCLR KBISC_KBMOD, KBISC

 	  ;Enables keyboard interrupt
  	BSET KBISC_KBIE, KBISC

  	;Turns on keyboard interrupt on PTA pins 0-3
  	MOV #%00001111, KBIPE

  	;Delay timer set up (TPM) for 20 ms
  	;Enables Time Overflow interrupt, Clock source set to BUSCLK, Sets prescale value to 64
  	MOV #%01001110, TPMSC

  	;TPMMOD is set to count for 20 ms
  	;Sets the high end of the modulo
  	MOV #$09, TPMMODH

  	;Sets the low end of the modulo
  	MOV #$C5, TPMMODL

mainLoop:
    ;Look for interrupt
  	LDA KBISC
  	CMP #%000010010

  	;Cycle through PTB to find which row is triggered
  	;Run each row high

  	;interrupt found
  	BEQ Start
  	BRA mainLoop

Start:
  	;Clears keyboard interrupt (acknowledges interrupt)
	BSET KBISC_KBACK, KBISC
	MOV PTAD, column

;Turns off each row one by one to find the right row
;If a row is turned off and the column that's on also turns off then it is the right row
turnOffPTBD2:
	BCLR PTBD_PTBD2, PTBD
	LDA PTA
	CMP column
	BNE turnOffPTB3
	findInRow1:
		LDA column
		CBEQ #%00000001, R1C1
		CBEQ #%00000010, R1C2
		CBEQ #%00000100, R1C3
		CBEQ #%00001000, R1C4
turnOffPTBD3:
	BCLR PTBD_PTBD3, PTBD
	LDA PTA
	CMP column
	BNE turnOffPTB4
	findInRow2:
		LDA column
		CBEQ #%00000001, R2C1
		CBEQ #%00000010, R2C2
		CBEQ #%00000100, R2C3
		CBEQ #%00001000, R2C4
turnOffPTBD4:
	BCLR PTBD_PTBD4, PTBD
	LDA PTA
	CMP column
	BNE turnOffPTB5
	findInRow3:
		LDA column
		CBEQ #%00000001, R3C1
		CBEQ #%00000010, R3C2
		CBEQ #%00000100, R3C3
		CBEQ #%00001000, R3C4
turnOffPTBD5:
	BCLR PTBD_PTBD5, PTBD
	LDA PTA
	CMP column
	BNE error
	findInRow4:
		CBEQ #%00000001, R4C1
		CBEQ #%00000010, R4C2
		CBEQ #%00000100, R4C3
		CBEQ #%00001000, R4C4

;keyboardTable uses ASCII characters
;1
R1C1:
	MOV #$31, charCode
;2
R1C2:
	MOV #$32, charCode
;3
R1C3:
	MOV #$33, charCode
;A
R1C4:
	MOV #$41, charCode
;4
R2C1:
	MOV #$34, charCode
;5
R2C2:
	MOV #$35, charCode
;6
R2C3:
	MOV #$36, charCode
;B
R2C4:
	MOV #$42, charCode
;7
R3C1:
	MOV #$37, charCode
;8
R3C2:
	MOV #$38, charCode
;9
R3C3:
	MOV #$39, charCode
;C
R3C4:
	MOV #$43, charCode
;*
R4C1:
	MOV #$2A, charCode
;0
R4C2:
	MOV #$30, charCode
;#
R4C3:
	MOV #$23, charCode
;D
R4C4:
	MOV #$44, charCode
;If there is an error, send !
error:
	MOV #$21, charcode

;Once timer ends, everything is reset
Restart:
	;Turns on keyboard interrupt
	BSET KBISC_KBIE, KBISC

	LDA #%00111100
	STA PTBD

	;Reset all pins
	;Branch to mainLoop
