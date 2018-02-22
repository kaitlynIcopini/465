;LED.asm by Michael Oswald and Kaitlyn Icopini
;LED control
  INCLUDE 'derivative.inc'
  XDEF _Startup, main, _VKeyboard_ISR
  XREF __SEG_END_SSTACK   ; symbol defined by linker for end of stack

;Stores KeypressISP at beginning of RAM
	ORG $60
CaseA DC.B 1
CaseB DC.B 1
C1 DC.B 1
C2 DC.B 1
C3 DC.B 1
C4 DC.B 1
D1 DC.B 1
D2 DC.B 1
D3 DC.B 1
D4 DC.B 1
D5 DC.B 1
D6 DC.B 1
AA DC.B 1
B DC.B 1
C DC.B 1
D DC.B 1

CaseB EQU 01111111
CaseA EQU #%10101010
C1 EQU #%00011000
C2 EQU #%00100100
C3 EQU #%01000010
C4 EQU #%10000001
D1 EQU #%00111100
D2 EQU #%00011110
D3 EQU #%00001111
D4 EQU #%00000111
D5 EQU #%00000011
D6 EQU #%00000001
A EQU #$65
B EQU #$66
C EQU #$67
D EQU #$68

Lettercase DS.B 1
Cntr DS.B 1
ID DS.B 1
Place DS.B 1

	org $e000
main:
_Startup:
	LDHX #__SEG_END_SSTACK
	;Turns off watchdog
  	BCLR SOPT1_COPE, SOPT1
	;Sets Port B to be outputs to LEDs
	MOV #%11111111, PTBDD

  ;set IIC to default ports (PTA2,3)
  BCLR SOPT2_IICPS, SOPT2



Mainloop:
  BRA CaseA;
New: ;braches to case soecific code to set initial conditions
  ;
  CBEQA A, CaseA;
  CBEQA B, CaseB;
  CBEQA C, CaseC;
  CBEQA D, CaseD;
  BRA other;
other:
  MOV #0, PTBD;
  BRA Wait;
CaseA: ;Initial condition for case A
  MOV #%10101010, PTBD;
  BRA Wait;
CaseB: ;iniial condition for case B
  MOV #%01111111, PTBD;
  BSET CCR_C, CCR;
  BRA Wait;
CaseC: ;initial condition for case C
  MOV #%00011000, PTBD;
  MOV #%00000000, Cntr;
  BRA Wait;
CaseD: ;initial condition for case D
  MOV #%00111100, PTBD;
  MOV #%00000000, Cntr;
  BRA Wait
continue: ;branches to code to continue case specific progression
  CBEQA A, CaseA;
  CBEQA B, ShiftB;
  CBEQA C, CheckCntr;
  CBEQA D, CheckCntr;
  BRA other;
Wait: ;wait for TPMMOD
;Delay timer set up (TPM) for 15 ms
	;Enables Time Overflow interrupt, Clock source set to BUSCLK, Sets prescale value to 64
	MOV #%01001110, TPMSC

	;TPMMOD is set to count for 15 ms
	;Sets the high end of the modulo
	MOV #$03, TPMMODH

	;Sets the low end of the modulo
	MOV #$AC, TPMMODL
	JSR Waiting
	nop;
  ;***********Check TPMMOD*********
  LDA Lettercase;
  CBEQA Place, continue;
  BRA New
Waiting:
	BRSET TPMSC_TOF, TPMSC, RTI
	BRA Waiting
ShiftB: ;shift PTBD
  LDA PTBD;
  ROLA;
  BRA Wait;
CheckCntr:
  LDA Lettercase
  CBEQA D, CntrD;
  CBEQA C, CntrC;
  BRA IorDcheck;
CntrC:
  LDA Cntr
  CBEQA #3, setbit;
  CBEQA #0, clrbit;
  BRA IorDcheck;
setbit:
  BSET 0, ID;
  BRA IorDcheck
clrbit:
  BCLR 0, ID;
  BRA IorDcheck
CntrD:
  LDA Cntr
  CBEQA #5, setbit;
  CBEQA #0, clrbit;
  BRA IorDcheck;
IorDcheck:
  LDA ID;
  CBEQA #%00000001, incloook;
  BRA declook;
inclook:
  LDA Cntr;
  INCA;
  BRA lookup
declook:
  LDA Cntr;
  DECA;
  BRA lookup
lookup:
  LDA Lettercase;
  CBEQA C, lookupC;
  CBEQA D, lookupD;
  BRA New
lookupC:
  LDA Cntr;
  CBEQA #0, LC1
  CBEQA #1, LC2
  CBEQA #2, LC1
  CBEQA #3, LC2
  BRA CaseC
lookupD:
  LDA Cntr;
  CBEQA #0, LD1
  CBEQA #1, LD2
  CBEQA #2, LD1
  CBEQA #3, LD2
  CBEQA #4, LD1
  CBEQA #5, LD2
  BRA New;
LC1:
  MOV C1, PTBD;
  BRA Wait;
LC2:
  MOV C2, PTBD;
  BRA Wait;
LC3:
  MOV C3, PTBD;
  BRA Wait;
LC4:
  MOV C4, PTBD;
  BRA Wait;
LD1:
  MOV D1, PTBD;
  BRA Wait;
LD2:
  MOV D2, PTBD;
  BRA Wait;
LD3:
  MOV D3, PTBD;
  BRA Wait;
LD4:
  MOV D4, PTBD;
  BRA Wait;
LD5:
  MOV D5, PTBD;
  BRA Wait;
LD6:
  MOV D6, PTBD;
  BRA Wait;
