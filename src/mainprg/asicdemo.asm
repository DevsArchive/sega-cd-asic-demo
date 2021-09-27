
; -------------------------------------------------------------------------
;
;	Sega CD ASIC demo
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

	include	"cdsp/asicdef.asm"

; -------------------------------------------------------------------------
; Constants
; -------------------------------------------------------------------------

IMG_WIDTH	EQU	256			; Image buffer width
IMG_HEIGHT	EQU	224			; Image buffer height
IMG_SIZE	EQU	(IMG_WIDTH/8)*(IMG_HEIGHT/8)*$20

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

scale:		dc.w	0			; Scale value
asicDone:	dc.b	0			; ASIC done flag
bufferID:	dc.b	0			; Buffer ID

; -------------------------------------------------------------------------
; Main program
; -------------------------------------------------------------------------

Main:
	move.l	#VInt_ASIC,_LEVEL6+2.w		; Set vertical interrupt
	bsr.w	ClearScreen			; Clear screen
	bsr.w	RequestWordRAM			; Request Word RAM access

	move.w	#$8134,VDP_CTRL			; Disable display
	move.w	#$8200|($E000/$400),VDP_CTRL	; Set plane A to same address as plane B
	move.w	#$8500|($F800/$200),VDP_CTRL	; Set sprite table to $FC00
	move.w	#$8C00,VDP_CTRL			; H32 mode

	lea	ASICStamps,a0			; Load stamp data
	lea	WORDRAM_2M+STAMP_DATA+$200,a1
	bsr.w	CompDec
	
	lea	ASICStampMap,a0			; Load stamp map
	lea	WORDRAM_2M+STAMP_MAP,a1
	move.w	#(ASICStampMap_End-ASICStampMap)/4-1,d0

.LoadStampMap:
	move.l	(a0)+,(a1)+
	dbf	d0,.LoadStampMap

	lea	ASICPalette,a0			; Load palette
	lea	palette.w,a1
	moveq	#$10/4-1,d0

.LoadPal:
	move.l	(a0)+,(a1)+
	dbf	d0,.LoadPal

	move.l	#$60800003,d0			; Load tilemap
	moveq	#1,d4				; (Tiles are arranged vertically)
	moveq	#2-1,d5
	move.w	#$8F80,VDP_CTRL

.LoadMap:
	moveq	#IMG_WIDTH/8-1,d1
	moveq	#IMG_HEIGHT/8-1,d2

.MapCol:
	move.l	d0,VDP_CTRL
	add.l	#$20000,d0
	move.w	d2,d3

.MapTile:
	move.w	d4,VDP_DATA
	addq.w	#1,d4
	dbf	d3,.MapTile
	dbf	d1,.MapCol

	move.l	#$60C00003,d0
	dbf	d5,.LoadMap
	move.w	#$8F02,VDP_CTRL

	move.l	#$40000010,VDP_CTRL		; Move to top of map
	move.l	#$00080008,VDP_DATA

; -------------------------------------------------------------------------

.Loop:
	bsr.w	VSync				; VSync

	lea	WORDRAM_2M+TRACE_TABLE,a0	; Set up trace table
	move.w	#IMG_HEIGHT-1,d0
	moveq	#0,d1
	move.w	scale,d2			; Make scale value 5.11 fixed point for delta
	lsl.w	#8,d2

.TraceTable:
	clr.w	(a0)+				; X start
	move.w	d1,(a0)+			; Y start
	add.w	scale,d1			; Use scale to get next Y
	move.w	d2,(a0)+			; X delta
	clr.w	(a0)+				; Y delta
	dbf	d0,.TraceTable

	addq.w	#1,scale			; Increase scale value
	andi.w	#$7F,scale

						; Start rendering
	moveq	#%011,d0
	move.w	#IMG_WIDTH,d1
	move.w	#IMG_HEIGHT,d2
	moveq	#0,d3
	bsr.s	ASICRender

.Wait:
	bsr.s	CheckASIC			; Wait until ASIC is done
	bne.s	.Wait
	bsr.w	RequestWordRAM			; Request Word RAM access
	move.b	#1,asicDone			; Mark ASIC as done

	bra.w	.Loop				; Loop

; -------------------------------------------------------------------------
; Start ASIC rendering
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w	- Stamp size
;	d1.w	- Image buffer width
;	d2.w	- Image buffer height
;	d3.w	- Image buffer offset
; -------------------------------------------------------------------------

ASICRender:
	move.w	d0,GA_CMD_0			; Start ASIC rendering
	move.w	d1,GA_CMD_2
	move.w	d2,GA_CMD_4
	move.w	d3,GA_CMD_6
	moveq	#6,d0
	bsr.w	SubCPUCmd
	bra.w	SubCPUCmd_Wait

; -------------------------------------------------------------------------
; Check ASIC status
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne	- Inactive/Busy
; -------------------------------------------------------------------------

CheckASIC:
	moveq	#7,d0				; Check ASIC status
	bsr.w	SubCPUCmd
	bsr.w	SubCPUCmd_Wait
	tst.w	GA_STAT_0
	rts

; -------------------------------------------------------------------------
; Vertical interrupt
; -------------------------------------------------------------------------

VInt_ASIC:
	move	#$2700,sr			; Disable interrupts
	pusha					; Push all registers
	
	z80Stop					; Stop Z80
	bsr.w	ReadControllers			; Read controllers

	lea	VDP_CTRL,a6			; VDP control
	dma68k	palette,0,$80,CRAM,a6		; Transfer palette data
	
	bclr	#0,asicDone			; Transfer ASIC graphics data
	beq.w	.NoASIC

	tst.b	bufferID
	beq.s	.Buffer0
	dma68k	WORDRAM_2M+IMG_BUFFER+2,$20,IMG_SIZE,VRAM,a6
	vdpCmd	move.l,$20,VRAM,WRITE,(a6)
	move.l	WORDRAM_2M+IMG_BUFFER,-4(a6)
	bra.s	.ASICDone

.Buffer0:
	dma68k	WORDRAM_2M+IMG_BUFFER+2,$20+IMG_SIZE,IMG_SIZE,VRAM,a6
	vdpCmd	move.l,$20+IMG_SIZE,VRAM,WRITE,(a6)
	move.l	WORDRAM_2M+IMG_BUFFER,-4(a6)

.ASICDone:
	not.b	bufferID			; Swap buffer
	bne.s	.HScrollBuf1
	move.l	#$7C000003,(a6)
	move.l	#$00000000,-4(a6)
	bra.s	.Display

.HScrollBuf1:
	move.l	#$7C000003,(a6)
	move.l	#$01000100,-4(a6)

.Display:
	move.w	#$8174,(a6)			; Enable display

.NoASIC:
	z80Start				; Start Z80

	addq.w	#1,frame_count.w		; Increment frame count
	popa					; Pop all registers
	rte

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

ASICStamps:
	incbin	"mainprg/data/stamps.comp"
	even

ASICStampMap:
	incbin	"mainprg/data/stampmap.bin"
ASICStampMap_End:
	even

ASICPalette:
	incbin	"mainprg/data/palette.bin"
	even

; -------------------------------------------------------------------------