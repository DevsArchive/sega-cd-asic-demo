
; -------------------------------------------------------------------------
;
;	Sega CD Base
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

	include	"../include/subcpu.asm"

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

ROOT_DIR	EQU	$8000			; Root directory buffer

; -------------------------------------------------------------------------
; Header
; -------------------------------------------------------------------------

	org	SP_START

	dc.b	"MAIN RALA  ", 0
	dc.w	$0001, $0000
	dc.l	$00000000
	dc.l	$00000000
	dc.l	$00000020
	dc.l	$00000000

	dc.w	SP_Init-(SP_START+$20)
	dc.w	SP_Main-(SP_START+$20)
	dc.w	SP_Int2-(SP_START+$20)
	dc.w	SP_Null-(SP_START+$20)
	dc.w	0

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

SP_Init:
	andi.b	#$E2,GA_MEM_MODE+1.w		; Disable priority mode, set to 2M mode

SP_Null:
	rts

; -------------------------------------------------------------------------
; Main
; -------------------------------------------------------------------------

SP_Main:
	BIOS_CDBSTAT				; Check the BIOS
	move.w	(a0),d0
	andi.w	#$F000,d0			; Is it ready?
	bne.s	SP_Main				; If not, wait

	lea	BIOSParams(pc),a0		; Initialize the drive
	BIOS_DRVINIT
	BIOS_CDCSTOP				; Stop CDC				; Stop CDDA

	lea	CDReadVars(pc),a6		; Read primary volume descriptor
	bsr.w	ReadCD

	move.l	ROOT_DIR+$A2,(a6)		; Get root directory
	move.l	ROOT_DIR+$AA,d0
	moveq	#11,d1
	lsr.l	d1,d0
	move.l	d0,4(a6)
	move.l	#ROOT_DIR,8(a6)
	bsr.w	ReadCD

	lea	.MainProgram(pc),a0		; Load Main CPU program file
	lea	PRG_RAM+$40000,a1
	bsr.w	ReadFile

.WaitWordRAM:
	btst	#1,GA_MEM_MODE+1.w		; Wait for Word RAM access
	beq.s	.WaitWordRAM

	lea	PRG_RAM+$40000,a0		; Copy Main CPU program to Word RAM
	lea	WORDRAM_2M,a1
	move.w	#filesize("_files/MAINPRG.MCD")/4-1,d0

.CopyMainPrg:
	move.l	(a0)+,(a1)+
	dbf	d0,.CopyMainPrg

.SendWordRAM:					; Give the Main CPU Word RAM
	bset	#0,GA_MEM_MODE+1.w
	beq.s	.SendWordRAM

.WaitMain:
	cmpi.b	#"R",GA_MAIN_FLAG.w		; Is the Main CPU done with the security code?
	bne.s	.WaitMain			; If not, branch
	move.b	#"G",GA_SUB_FLAG.w		; Tell the Main CPU we got the memo

.WaitMain2:
	tst.b	GA_MAIN_FLAG.w			; Is the Main CPU ready to send commands?
	bne.s	.WaitMain2			; If not, branch
	move.b	#"R",GA_SUB_FLAG.w		; Mark as ready to retrieve commands

; -------------------------------------------------------------------------

.WaitCommand:
	moveq	#0,d0
	move.b	GA_MAIN_FLAG.w,d0		; Get command ID
	beq.s	.WaitCommand			; Wait if we if the ID is 0

	move.b	#"B",GA_SUB_FLAG.w		; Mark as busy
	
.WaitMain3:
	tst.b	GA_MAIN_FLAG.w			; Is the Main CPU ready to send commands again?
	bne.s	.WaitMain3			; If not, branch

	add.w	d0,d0				; Go to command
	add.w	d0,d0
	jsr	.Commands-4(pc,d0.w)

	move.b	#"R",GA_SUB_FLAG.w		; Mark as ready
	bra.s	.WaitCommand			; Loop

; -------------------------------------------------------------------------
; Commands
; -------------------------------------------------------------------------

.Commands:
	bra.w	SP_PlayCDDA			; Play CDDA music
	bra.w	SP_LoopCDDA			; Loop CDDA music
	bra.w	SP_StopCDDA			; Stop CDDA music
	bra.w	SP_LoadFile			; Load file
	bra.w	SP_ReqWordRAM			; Request Word RAM access
	bra.w	SP_ASICRender			; Start ASIC rendering
	bra.w	SP_CheckASIC			; Check ASIC status

; -------------------------------------------------------------------------

.MainProgram:
	dc.b	"MAINPRG.MCD", 0		; Main program file
	even

; -------------------------------------------------------------------------
; Prepare to play CDDA music
; -------------------------------------------------------------------------

PrepareCDDA:
	BIOS_MSCSTOP				; Stop any other music

	lea	BIOSParams(pc),a0		; Set the new track
	move.w	GA_CMD_0.w,(a0)
	rts

; -------------------------------------------------------------------------
; Command to play CDDA music
; -------------------------------------------------------------------------
; PARAMETERS:
;	Cmd 0	- Track ID
; -------------------------------------------------------------------------

SP_PlayCDDA:
	bsr.s	PrepareCDDA			; Prepare to play

PlayCCDA2:
	BIOS_MSCPLAY				; Play the music track

SP_WaitCDDA:
	BIOS_CDBSTAT				; Check the BIOS
	move.w	(a0),d0
	andi.w	#$FF00,d0			; Is it done seeking?
	cmpi.w	#$800,d0
	beq.s	SP_WaitCDDA			; If not, wait
	cmpi.w	#$100,d0			; Is it playing yet?
	bne.s	SP_WaitCDDA			; If not, wait
	rts

; -------------------------------------------------------------------------
; Command to loop CDDA music
; -------------------------------------------------------------------------
; PARAMETERS:
;	Cmd 0	- Track ID
; -------------------------------------------------------------------------

SP_LoopCDDA:
	bsr.s	PrepareCDDA			; Prepare to play
	BIOS_MSCPLAYR				; Play the music track
	bra.s	SP_WaitCDDA

; -------------------------------------------------------------------------
; Command to stop CDDA music
; -------------------------------------------------------------------------

SP_StopCDDA:
	BIOS_MSCSTOP				; Stop CDDA
	rts

; -------------------------------------------------------------------------
; Command to load file
; -------------------------------------------------------------------------
; PARAMETERS:
;	Cmd 0-A	- File name
;	Cmd C-E	- Destination buffer
; RETURNS:
;	Stat 0	- 0 if loaded, -1 if failed
; -------------------------------------------------------------------------

SP_LoadFile:
	lea	Buffer(pc),a0			; Load file
	lea	GA_CMD_0.w,a1
	move.l	(a1)+,(a0)
	move.l	(a1)+,4(a0)
	move.l	(a1),8(a0)
	movea.l	GA_CMD_C.w,a1
	lea	CDReadVars(pc),a6
	bsr.w	ReadFile
	bcs.s	.Failed
	
	clr.l	GA_STAT_0.w			; Return file sector
	rts

.Failed:
	move.l	#-1,GA_STAT_0.w			; Return -1 if not found
	rts

; -------------------------------------------------------------------------
; Acknowledge Main CPU Word RAM access request
; -------------------------------------------------------------------------

SP_ReqWordRAM:
	bset	#0,GA_MEM_MODE+1.w		; Give the Main CPU Word RAM access
	beq.s	SP_ReqWordRAM
	rts

; -------------------------------------------------------------------------
; Find a file
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- File name
; -------------------------------------------------------------------------
; RETURNS:
;	cc/cs	- Successful/Failed
;	d0.l	- File sector
;	d1.l	- File size
; -------------------------------------------------------------------------

FindFile:
	moveq	#0,d0
	lea	ROOT_DIR,a2			; Get root directory

.FileLoop:
	move.b	(a2),d0				; Is this the end of the directory?
	beq.s	.NotFound			; If so, branch
	lea	$21(a2),a3			; Go to file name
	movea.l	a0,a4

.ChkName:
	move.b	(a4)+,d1			; Check if this is the termination flag
	beq.s	.Found				; If so, branch
	cmp.b	(a3)+,d1			; Do the characters match?
	beq.s	.ChkName			; If so, branch

	add.l	d0,a2				; Next file
	bra.s	.FileLoop

.NotFound:
	ori	#1,ccr				; Set carry flag
	rts

.Found:
	move.b	6(a2),d0			; Get file size
	lsl.l	#8,d0
	move.b	7(a2),d0
	lsl.l	#8,d0
	move.b	8(a2),d0
	lsl.l	#8,d0
	move.b	9(a2),d0

	move.b	$E(a2),d1			; Get file sector
	lsl.l	#8,d1
	move.b	$F(a2),d1
	lsl.l	#8,d1
	move.b	$10(a2),d1
	lsl.l	#8,d1
	move.b	$11(a2),d1

	andi	#$FFFE,ccr			; Clear carry flag
	rts

; -------------------------------------------------------------------------
; Read a file into a buffer
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l	- File name
;	a1.l	- Destination buffer
;	a6.l	- CD read parameters (see variable section)
; -------------------------------------------------------------------------
; RETURNS:
;	cc/cs	- Successful/Failed
; -------------------------------------------------------------------------

ReadFile:
	bsr.s	FindFile			; Find the file
	bcs.s	.NotFound

	move.l	d0,(a6)				; Set sector
	move.l	d1,d0				; Get sector count
	moveq	#11,d2
	lsr.l	d2,d1
	andi.w	#$7FF,d0			; Is the end of the file not aligned to a sector?
	beq.s	.Aligned			; If not, branch
	addq.l	#1,d1				; If so, load an extra sector to get the full file

.Aligned:
	move.l	d1,4(a6)			; Set sector count
	move.l	a1,8(a6)			; Set destination buffer
	bsr.s	ReadCD				; Read the file

	andi	#$FFFE,ccr			; Clear carry flag

.NotFound:
	rts

; -------------------------------------------------------------------------
; Read a number of sectors from the CD
; -------------------------------------------------------------------------
; PARAMETERS:
;	a6.l	- CD read parameters (see variable section)
; -------------------------------------------------------------------------

ReadCD:
	movea.l	a6,a0				; Copy CD read parameters to a0 for BIOS
	BIOS_CDCSTOP				; Stop CDC
	BIOS_ROMREADN				; Begin operation

.WaitPrepare:
	BIOS_CDCSTAT				; Wait for when the data has been prepared
	bcs.s	.WaitPrepare

.WaitRead:
	BIOS_CDCREAD				; Wait for when a frame of data was read
	bcs.s	.WaitRead

.WaitTrns:
	movea.l	8(a6),a0			; Transfer the data
	lea	$C(a6),a1
	BIOS_CDCTRN
	bcs.s	.WaitTrns

	BIOS_CDCACK				; Finish

	addi.l	#$800,8(a6)			; Next sector
	addq.l	#1,(a6)
	move.l	#ROOT_DIR,$C(a6)
	subq.l	#1,4(a6)
	bne.s	.WaitPrepare			; If we are not done, keep reading
	rts

; -------------------------------------------------------------------------
; ASIC functions
; -------------------------------------------------------------------------

	include	"cdsp/asic.asm"

; -------------------------------------------------------------------------
; Interrupt level 2
; -------------------------------------------------------------------------

SP_Int2:
	rts

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

BIOSParams:
	dc.b	$01, $FF, $00, $00		; BIOS parameters
	dc.b	$00, $00, $00, $00

Buffer:
	dcb.b	$10, 0				; Buffer

CDReadVars:
	; Prepared for reading primary volume descriptor
	dc.l	$10				; Start sector
	dc.l	1				; Number of sectors
	dc.l	ROOT_DIR			; Read buffer
	dc.l	SP_End, 0			; Header buffer

; -------------------------------------------------------------------------

SP_End:
	dc.l	0

; -------------------------------------------------------------------------