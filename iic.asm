;iic.s by Michael Oswald and Kaitlyn Icopini
;//18
;Lab1:

; Include derivative-specific definitions
		INCLUDE 'derivative.inc'

; export symbols
		XDEF _Startup, main
		XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stac

MY_ZEROPAGE: SECTION
	info: DS.B 1

;Code section
MyCode: SECTION

main:
_Startup:


mainLoop:
 	;Turn off I2C interupt flag
  	BCLR IICS_IICIF, IICS

	;Checks to see if in master mode
	BRSET IICS_MST, IICC, master

	;Slave mode checks

;Reading or transmitting
master:
	BRSET IICC_TX, IICC, transmit

;Master mode to read data
read:
	;Last byte to be read?
	;yes, generate stop, endRead
	;no, 2nd to last byte to be read?
	;yes, set TXACK = 1, endRead
	;no, endRead
	BRA endRead


endRead:
	;read data from IICD and store it
	MOV IICD, info
	RTI

;Master mode to transmit data
transmit:
	;Check to see if last byte has been transmitted
	LDA #%00000000
	CBEQA IICD, endTransmit

	;Received acknowledge
	BRSET IICS_RXAK, IICS, endTransmit

	;End of address cylce?
	;go to switchMode

;switch to receive mode
switchMode:
	BCLR IICC_TX, IICC

	;dummy read from IICD

endTransmit:
	BCLR IICC_MST, IICC
	RTI
