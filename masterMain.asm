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

  ;Sets the I2C lines, PTB 7 as SCL and PTB 6 as SDA
  BSET SOPT2_IICPS, SOPT2

  ;Gives master an address for I2C
  LDA #%_ _ _ _ _ _ _ 0
  STA IICA

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
  ;Sets the keyboard interupt to trigger on a rising edge on PTA pins 0-3 (pulldown)
  BSET KBIES_KBEGD0, KBIES
  BSET KBIES_KBEGD1, KBIES
  BSET KBIES_KBEGD2, KBIES
  BSET KBIES_KBEGD3, KBIES

  ;Enables pins PTA 0-3 internal resistors
  BSET PTAPE_PTAPE0, PTAPE
  BSET PTAPE_PTAPE1, PTAPE
  BSET PTAPE_PTAPE2, PTAPE
  BSET PTAPE_PTAPE3, PTAPE

  ;Sets the keyboard detection mode to detect both edges
  BCLR KBISC_KBMOD, KBISC

  ;Enables keyboard interupt
  BSET KBISC_KBIE, KBISC

  ;initialize keyboard Interupt on PTA pins 0-3
  BSET KBIPE_KBIPE0, KBIPE
  BSET KBIPE_KBIPE1, KBIPE
  BSET KBIPE_KBIPE2, KBIPE
  BSET KBIPE_KBIPE3, KBIPE

  ;Delay timer set up (TPM) for 20 ms
  ;Enables Time Overflow Interupt, Clock source set to BUSCLK, Sets prescale value to 64
  LDA #%01001110
  STA TPMSC

  ;TPMMOD is set to count for 20 ms
  ;Sets the high end of the modulo
  LDA #$09
  STA TPMMODH

  ;Sets the low end of the modulo
  LDA #$C5
  STA TPMMODL

mainLoop:
  ;Look for Interupt
  LDA KBISC
  CMP %000010010

  ;Interupt found
  BEQ delayStart
  BRA mainLoop

Start:
  ;Clears keyboard interupt
  BCLR KBISC_KBF, KBISC

  ;Restarts the timer module
  BCLR TPMSC_TOF, TPM


  ;when timer reaches the end, it turns the interupt back on
  ;proceeds to keyboard.asm find which button was pressed

  ;Reset all pins
  ;Branch to mainLoop
