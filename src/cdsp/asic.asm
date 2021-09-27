
; -------------------------------------------------------------------------
;
;	Sega CD ASIC demo
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

	include	"cdsp/asicdef.asm"

; -------------------------------------------------------------------------
; Start ASIC rendering
; -------------------------------------------------------------------------
; PARAMETERS:
;	Cmd 0	- Stamp size
;	Cmd 2	- Image buffer width
;	Cmd 4	- Image buffer height
;	Cmd 6	- Image buffer offset
; -------------------------------------------------------------------------

SP_ASICRender:
	move.w	#STAMP_MAP/4,GA_STAMP_MAP.w	; Set stamp map address
	move.w	#IMG_BUFFER/4,GA_IMG_START.w	; Set image buffer address
	
	move.w	GA_CMD_0.w,GA_STAMP_SIZE.w	; Set stamp size
	move.w	GA_CMD_2.w,GA_IMG_HDOT.w	; Set image buffer horizontal resolution
	move.w	GA_CMD_4.w,d0			; Set image buffer vertical resolution
	move.w	d0,GA_IMG_VDOT.w
	lsr.w	#3,d0
	subq.w	#1,d0
	move.w	d0,GA_IMG_VCELL.w
	move.w	GA_CMD_6.w,GA_IMG_OFFSET.w	; Set image buffer offset
	
	move.w	#TRACE_TABLE/4,GA_IMG_TRACE.w	; Set trace table address and start rendering
	rts

; -------------------------------------------------------------------------
; Check ASIC status
; -------------------------------------------------------------------------
; RETURNS:
;	Stat 0	- 0 if inactive, -1 if busy
; -------------------------------------------------------------------------

SP_CheckASIC:
	tst.w	GA_STAMP_SIZE.w			; Is the ASIC busy?
	bmi.s	.Busy				; If so, branch
	move.w	#0,GA_STAT_0.w			; Mark as inactive
	rts

.Busy:
	move.w	#-1,GA_STAT_0.w			; Mark as busy
	rts

; -------------------------------------------------------------------------