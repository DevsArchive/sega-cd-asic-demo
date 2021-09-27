
; -------------------------------------------------------------------------
;
;	Sega CD Base
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

	include	"../include/maincpu.asm"

; -------------------------------------------------------------------------
; Main program
; -------------------------------------------------------------------------

	org	IP_START
	incbin	"cdip/sec_us.bin"

.SendWordRAM:
	bset	#1,GA_MEM_MODE+1		; Send Word RAM access to the Sub CPU
	beq.s	.SendWordRAM
	
	move.b	#"R",GA_MAIN_FLAG		; Tell Sub CPU that security code is done running

.Wait:
	cmpi.b	#"G",GA_SUB_FLAG		; Wait for the Sub CPU to finish initializing
	bne.s	.Wait

	clr.b	GA_MAIN_FLAG			; Mark as ready for commands

.Wait2:
	cmpi.b	#"R",GA_SUB_FLAG		; Wait for the Sub CPU to get ready to send commands
	bne.s	.Wait2

	lea	WORDRAM_2M,a0			; Copy program to regular RAM
	lea	RAM_START+$600,a1
	move.w	#filesize("_files/MAINPRG.MCD")/4-1,d0

.Copy:
	move.l	(a0)+,(a1)+
	dbf	d0,.Copy

	bra.s	RAM_START+$600			; Go to main program

; -------------------------------------------------------------------------
