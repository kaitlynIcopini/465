;iic.s by Michael Oswald and KaitlynIcopini
;//18
;Lab1:

; Include derivative-specific definitions
INCLUDE 'derivative.inc'

; export symbols
XDEF _Startup, main
XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack


main:
_Startup:


mainLoop:
  ;Clear IIFCIF
  ;If Master mode
