;Main.s by Michael Oswald and Kaitlyn Icopini
;//18
;Lab1:

; Include derivative-specific definitions
INCLUDE 'derivative.inc'

; export symbols
XDEF _Startup, main
XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack


main:
_Startup:

  ;Turns off watchdog
  BCLR SOPT1_COPE, SOPT1

  ;Sets pin 2 to BKGD mode
  BSET SOPT1_BKGDPE, SOPT1

  ;Sets pin 1 to RESET
  BSET SOPT1_RESTPE, SOPT1

  ;Sets PTA pins 0-3 to be an input
  BCLR PTADD_PTADD0, PTADD
  BCLR PTADD_PTADD1, PTADD
  BCLR PTADD_PTADD2, PTADD
  BCLR PTADD_PTADD3, PTADD

  ;Set PTB pins 2-5 to be an output
  BSET PTBDD_PTBDD2, PTBDD
  BSET PTBDD_PTBDD3, PTBDD
  BSET PTBDD_PTBDD4, PTBDD
  BSET PTBDD_PTBDD5, PTBDD

  ;initialize pull down resistors
  ;Sets the keyboard interupt to trigger on a rising edge on PTA pins 0-3
  BSET KBIES_KBEGD0, KBIES
  BSET KBIES_KBEGD1, KBIES
  BSET KBIES_KBEGD2, KBIES
  BSET KBIES_KBEGD3, KBIES

  ;Enables pins PTA 0-3 internal resistors
  BSET PTAPE_PTAPE0, PTAPE
  BSET PTAPE_PTAPE1, PTAPE
  BSET PTAPE_PTAPE2, PTAPE
  BSET PTAPE_PTAPE3, PTAPE

  ;initialize keypad Interupt on PTA pins 0-3
  BSET KBIPE_KBIPE0, KBIPE
  BSET KBIPE_KBIPE1, KBIPE
  BSET KBIPE_KBIPE2, KBIPE
  BSET KBIPE_KBIPE3, KBIPE

  ;Delay timer set up (TPM) for 20 ms


mainLoop:
  ;Look for Interupt
  ;Interupt found
  ;keypad interupt turns timer on and turn itself off
  ;when timer reaches the end, it turns the interupt back on
  ;proceeds to find which button was pressed


  ;Look for which bit has been changed in columns
  ;Look for which bit had been changed in rows

  ;Store information in a variable that can be sent to LED S08
  ;Reset all pins
  ;Branch to mainLoop
