
; -------------------------------------------------------------------------
;
;	Sega CD Base
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

DoTransition:
	move	#$2700,sr			; Disable interrupts
	move.l	#VInterrupt,_LEVEL6+2.w		; Set interrupts
	move.l	#IntBlank,_LEVEL4+2.w
	move.w	#_LEVEL4,GA_HINT

	z80Stop					; Initialize controllers
	moveq	#$40,d0
	move.b	d0,IO_A_CTRL
	move.b	d0,IO_B_CTRL
	move.b	d0,IO_C_CTRL
	z80Start

	lea	vars_start.w,a0			; Clear variables
	move.w	#(vars_end-vars_start)/2-1,d0

.ClearRAM:
	clr.w	(a0)+
	dbf	d0,.ClearRAM

	lea	VDP_CTRL,a0			; Set VDP registers
	move.w	#$8004,(a0)
	move.w	#$8174,(a0)
	move.w	#$8D3F,(a0)
	move.w	#$9001,(a0)

	lea	palette.w,a1			; Prepare to copy palette
	moveq	#$80/2-1,d0

.WaitVBlank:
	move.w	(a0),ccr			; Wait until we are in the VBlank period first
	bmi.s	.WaitVBlank
	
	move.l	#$00000020,(a0)			; Now copy the palette

.CopyPal:
	move.w	-4(a0),(a1)+
	dbf	d0,.CopyPal

	bsr.w	FadeToBlack			; Fade the colors to black

	move	#$2700,sr			; Disable interrupts
	bra.w	Main				; Go to main program

; -------------------------------------------------------------------------