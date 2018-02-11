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
  ;LDA #%_ _ _ _ _ _ _ 0
  ;STA IICA

  ;Set PTB pins 2-5 to be an output
  BSET PTBDD_PTBDD2, PTBDD
  BSET PTBDD_PTBDD3, PTBDD
  BSET PTBDD_PTBDD4, PTBDD
  BSET PTBDD_PTBDD5, PTBDD

  ;Turns on PTB pins 2-5
  BCLR PTBD_PTBD2, PTBD
  BCLR PTBD_PTBD3, PTBD
  BCLR PTBD_PTBD4, PTBD
  BCLR PTBD_PTBD5, PTBD

  ;Sets PTA pins 0-3 to be an input
  BCLR PTADD_PTADD0, PTADD
  BCLR PTADD_PTADD1, PTADD
  BCLR PTADD_PTADD2, PTADD
  BCLR PTADD_PTADD3, PTADD

  ;initialize pull down resistors
  ;Sets the keyboard interrupt to trigger on a rising edge on PTA pins 0-3 (pulldown)
  BSET KBIES_KBEGD0, KBIES
  BSET KBIES_KBEGD1, KBIES
  BSET KBIES_KBEGD2, KBIES
  BSET KBIES_KBEGD3, KBIES

  ;Enables internal resistors on PTA pins 0-3
  BSET PTAPE_PTAPE0, PTAPE
  BSET PTAPE_PTAPE1, PTAPE
  BSET PTAPE_PTAPE2, PTAPE
  BSET PTAPE_PTAPE3, PTAPE

  ;Sets the keyboard detection mode to detect edges
  BCLR KBISC_KBMOD, KBISC

  ;Enables keyboard interrupt
  BSET KBISC_KBIE, KBISC

  ;Turns on keyboard interrupt on PTA pins 0-3
  BSET KBIPE_KBIPE0, KBIPE
  BSET KBIPE_KBIPE1, KBIPE
  BSET KBIPE_KBIPE2, KBIPE
  BSET KBIPE_KBIPE3, KBIPE

  ;Delay timer set up (TPM) for 20 ms
  ;Enables Time Overflow interrupt, Clock source set to BUSCLK, Sets prescale value to 64
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
  ;Look for interrupt
  LDA KBISC
  CMP %000010010

  ;Cycle through PTB to find which row is triggered
  ;Run each row high

  ;interrupt found
  BEQ Start
  BRA mainLoop

Start:
  ;Clears keyboard interrupt (acknowledges interrupt)
  BSET KBISC_KBACK, KBISC

  ;Turns off keyboard interrupt
  BCLR KBISC_KBIE, KBISC

  ;Turns off each row one by one to find the right row
  ;If a row is turned off and the column that's on also turns off then it is the right row


  ;Restarts the timer module
  BCLR TPMSC_TOF, TPM

keyboardTable:
  ;uses ASCII characters 

;Once timer ends, everything is reset
Restart:
  ;Turns on keyboard interrupt
  BSET KBISC_KBIE, KBISC

  BSET PTBD_PTBD2, PTBD
  BSET PTBD_PTBD3, PTBD
  BSET PTBD_PTBD4, PTBD
  BSET PTBD_PTBD5, PTBD

  ;Reset all pins
  ;Branch to mainLoop
