;Main.s by Michael Oswald and Kaitlyn Icopini
;//18
;Lab1:

; Include derivative-specific definitions
		INCLUDE 'derivative.inc'

; export symbols
		XDEF _Startup, main
		XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack

	ORG $60
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
  	BSET SOPT1_RSTPE, SOPT1

  	;Sets the I2C lines, PTB 7 as SCL and PTB 6 as SDA
  	BSET SOPT2_IICPS, SOPT2

  	;Gives master an address for I2C
  	;LDA #%_ _ _ _ _ _ _ 0
  	;STA IICA

  	;Set PTB pins 2-5 to be an output
 	MOV #%00111100, PTBDD

  	;Turns on PTB pins 2-5
  	MOV #%00111100, PTBD

  	;initialize pull down resistors
  	;Sets the keyboard interrupt to trigger on a rising edge on PTA pins 0-3 (pulldown)
  	MOV #%00001111, KBIES

	;Enables internal resistors on PTA pins 0-3
	MOV #%00001111, PTAPE

 	;Enables keyboard interrupt
  	BSET KBISC_KBIE, KBISC

  	;Turns on keyboard interrupt on PTA pins 0-3
  	MOV #%00001111, KBIPE

	;Sets PTA pins 0-3 to be an input
  	MOV #%00000000, PTADD

	;Sets column to 0
  	MOV #%00000000, column

mainLoop:
  	;Look for interrupt, if found, goes to start
  	BRSET KBISC_KBF, KBISC, Start
  	BRA mainLoop

Start:
	;Delay timer set up (TPM) for 15 ms
  	;Enables Time Overflow interrupt, Clock source set to BUSCLK, Sets prescale value to 64
  	MOV #%01001110, TPMSC

  	;TPMMOD is set to count for 15 ms
  	;Sets the high end of the modulo
  	MOV #$03, TPMMODH

  	;Sets the low end of the modulo
  	MOV #$AC, TPMMODL

  	;Clears keyboard interrupt (acknowledges interrupt)
	BSET KBISC_KBACK, KBISC

delay:
	;wait for about 15 ms, check the interupt again, then send
	BRSET TPMSC_TOF, TPMSC, findButton
	BRA delay

findButton:
	;Checks to see if interupt is still on, goes to mainLoop if not
	BRCLR KBISC_KBF, KBISC, mainLoop

	;Copies PTAD to column in order to find the right button
	MOV PTAD, column

	;Clears inturpt
	BSET KBISC_KBACK, KBISC
	BCLR KBISC_KBIE, KBISC
	BRA turnOffPTBD2

;Once timer ends, everything is reset
Restart:
	;Turns on keyboard interrupt
	BSET KBISC_KBIE, KBISC

	;Turns rows back on
	MOV #%00111100, PTBD

	MOV #$00, charCode
	MOV #$00, column
	BRA mainLoop

;Keyboard Table uses ASCII characters
;1
R1C1:
	MOV #$31, charCode
	BRA Restart
;2
R1C2:
	MOV #$32, charCode
	BRA Restart
;3
R1C3:
	MOV #$33, charCode
	BRA Restart
;A
R1C4:
	MOV #$41, charCode
	BRA Restart
;4
R2C1:
	MOV #$34, charCode
	BRA Restart
;5
R2C2:
	MOV #$35, charCode
	BRA Restart
;6
R2C3:
	MOV #$36, charCode
	BRA Restart
;B
R2C4:
	MOV #$42, charCode
	BRA Restart
;7
R3C1:
	MOV #$37, charCode
	BRA Restart
;8
R3C2:
	MOV #$38, charCode
	BRA Restart
;9
R3C3:
	MOV #$39, charCode
	BRA Restart
;C
R3C4:
	MOV #$43, charCode
	BRA Restart
;*
R4C1:
	MOV #$2A, charCode
	BRA Restart
;0
R4C2:
	MOV #$30, charCode
	BRA Restart
;#
R4C3:
	MOV #$23, charCode
	BRA Restart
;D
R4C4:
	MOV #$44, charCode
	BRA Restart
;If there is an error, send !
error:
	MOV #$21, charCode
	BRA Restart

;Turns off each row one by one to find the right row
;If a row is turned off and the column that's on also turns off then it is the right row
turnOffPTBD2:
	BCLR PTBD_PTBD2, PTBD
	LDA PTAD
	CMP column
	BNE turnOffPTBD3
findInRow1:
	LDA column
	CBEQA #%00000001, R1C1
	CBEQA #%00000010, R1C2
	CBEQA #%00000100, R1C3
	CBEQA #%00001000, R1C4
turnOffPTBD3:
	BCLR PTBD_PTBD3, PTBD
	CMP column
	BNE turnOffPTBD4
findInRow2:
	LDA column
	CBEQA #%00000001, R2C1
	CBEQA #%00000010, R2C2
	CBEQA #%00000100, R2C3
	CBEQA #%00001000, R2C4
turnOffPTBD4:
	BCLR PTBD_PTBD4, PTBD
	CMP column
	BNE turnOffPTBD5
findInRow3:
	LDA column
	CBEQA #%00000001, R3C1
	CBEQA #%00000010, R3C2
	CBEQA #%00000100, R3C3
	CBEQA #%00001000, R3C4
turnOffPTBD5:
	BCLR PTBD_PTBD5, PTBD
	CMP column
	BNE error
findInRow4:
	CBEQA #%00000001, R4C1
	CBEQA #%00000010, R4C2
	CBEQA #%00000100, R4C3
	CBEQA #%00001000, R4C4
