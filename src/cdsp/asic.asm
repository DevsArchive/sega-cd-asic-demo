
; -------------------------------------------------------------------------
;
;	Sega CD ASIC demo
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

	include	"cdsp/asicdef.asm"

; -------------------------------------------------------------------------
; Start ASIC rendering
; Based on https://www.coranac.com/tonc/text/mode7.htm
; -------------------------------------------------------------------------
; PARAMETERS:
;	Cmd 0	- Camera X
;	Cmd 2	- Camera Y
;	Cmd 4	- Camera Z
;	Cmd 6	- Camera angle
; -------------------------------------------------------------------------

SP_ASICRender:
	move.w	GA_CMD_6.w,d0			; Get sine values
	andi.w	#$1FE,d0
	lea	SineTable+$10(pc),a0
	move.w	-$10(a0,d0.w),d2		; sin(a)
	move.w	$70(a0,d0.w),d3			; cos(a)

	lea	WORDRAM_2M+TRACE_TABLE,a0	; Trace table
	lea	ReciprocalLUT(pc),a1		; Reciprocal LUT

	move.w	#IMG_HEIGHT-1,d7

.LineLoop:
	move.w	(a1)+,d0			; lam = cam_pos_y / y
	mulu.w	GA_CMD_2.w,d0
	swap	d0

	move.w	d0,d1				; lsf = lam * sin(a)
	muls.w	d2,d1
	asr.l	#5,d1
	muls.w	d3,d0				; lcf = lam * cos(a)
	asr.l	#5,d0

	move.w	#IMG_WIDTH/2,d4			; lxr = center * lcf
	muls.w	d0,d4
	lsr.l	#8,d4
	move.w	#IMG_FOV,d5			; lyr = fov * lsf
	muls.w	d1,d5
	lsr.l	#8,d5

	move.w	GA_CMD_0.w,d6			; Start X = cam_pos_x - lxr + lyr
	sub.w	d4,d6
	add.w	d5,d6
	move.w	d6,(a0)+

	move.w	#IMG_WIDTH/2,d4			; lxr = center * lsf
	muls.w	d1,d4
	lsr.l	#8,d4
	move.w	#IMG_FOV,d5			; lyr = fov * lcf
	muls.w	d0,d5
	lsr.l	#8,d5

	move.w	GA_CMD_4.w,d6			; Start Y = cam_pos_z - lxr - lyr
	sub.w	d4,d6
	sub.w	d5,d6
	move.w	d6,(a0)+

	move.w	d0,d4				; Delta X = lcf
	move.w	d4,(a0)+
	move.w	d1,d4				; Delta Y = lsf
	move.w	d4,(a0)+

	dbf	d7,.LineLoop

; -------------------------------------------------------------------------

	move.w	#STAMP_MAP/4,GA_STAMP_MAP.w	; Set stamp map address
	move.w	#IMG_BUFFER/4,GA_IMG_START.w	; Set image buffer address
	
	move.w	#%111,GA_STAMP_SIZE.w		; 4096x4096 repeated map, 32x32 stamps
	move.w	#IMG_WIDTH,GA_IMG_HDOT.w	; Set image buffer horizontal resolution
	move.w	#IMG_HEIGHT,GA_IMG_VDOT.w	; Set image buffer vertical resolution
	move.w	#IMG_TILE_H-1,GA_IMG_VCELL.w
	move.w	#0,GA_IMG_OFFSET.w		; Set image buffer offset

	move.w	#TRACE_TABLE/4,GA_IMG_TRACE.w	; Set trace table address and start rendering
	rts

; -------------------------------------------------------------------------

ReciprocalLUT:
	dc.w	$8000, $5556, $4000, $3334, $2AAB, $2493, $2000, $1C72
	dc.w	$199A, $1746, $1556, $13B2, $124A, $1112, $1000, $0F10
	dc.w	$0E39, $0D7A, $0CCD, $0C31, $0BA3, $0B22, $0AAB, $0A3E
	dc.w	$09D9, $097C, $0925, $08D4, $0889, $0843, $0800, $07C2
	dc.w	$0788, $0751, $071D, $06EC, $06BD, $0691, $0667, $063F
	dc.w	$0619, $05F5, $05D2, $05B1, $0591, $0573, $0556, $053A
	dc.w	$051F, $0506, $04ED, $04D5, $04BE, $04A8, $0493, $047E
	dc.w	$046A, $0457, $0445, $0433, $0422, $0411, $0400, $03F1
	dc.w	$03E1, $03D3, $03C4, $03B6, $03A9, $039C, $038F, $0382
	dc.w	$0376, $036A, $035F, $0354, $0349, $033E, $0334, $032A
	dc.w	$0320, $0316, $030D, $0304, $02FB, $02F2, $02E9, $02E1
	dc.w	$02D9, $02D1, $02C9, $02C1, $02BA, $02B2, $02AB, $02A4
	dc.w	$029D, $0296, $0290, $0289, $0283, $027D, $0277, $0271
	dc.w	$026B, $0265, $025F, $025A, $0254, $024F, $024A, $0244
	dc.w	$023F, $023A, $0235, $0231, $022C, $0227, $0223, $021E
	dc.w	$021A, $0215, $0211, $020D, $0209, $0205, $0200, $01FD
	dc.w	$01F9, $01F5, $01F1, $01ED, $01EA, $01E6, $01E2, $01DF
	dc.w	$01DB, $01D8, $01D5, $01D1, $01CE, $01CB, $01C8, $01C4
	dc.w	$01C1, $01BE, $01BB, $01B8, $01B5, $01B3, $01B0, $01AD
	dc.w	$01AA, $01A7, $01A5, $01A2, $019F, $019D, $019A, $0198
	dc.w	$0195, $0193, $0190, $018E, $018B, $0189, $0187, $0184
	dc.w	$0182, $0180, $017E, $017B, $0179, $0177, $0175, $0173
	dc.w	$0171, $016F, $016D, $016B, $0169, $0167, $0165, $0163
	dc.w	$0161, $015F, $015D, $015B, $0159, $0158, $0156, $0154
	dc.w	$0152, $0151, $014F, $014D, $014B, $014A, $0148, $0147
	dc.w	$0145, $0143, $0142, $0140, $013F, $013D, $013C, $013A
	dc.w	$0139, $0137, $0136, $0134, $0133, $0131, $0130, $012F
	dc.w	$012D, $012C, $012A, $0129, $0128, $0126, $0125, $0124
	dc.w	$0122, $0121, $0120, $011F, $011D, $011C, $011B, $011A
	dc.w	$0119, $0117, $0116, $0115, $0114, $0113, $0112, $0110
	dc.w	$010F, $010E, $010D, $010C, $010B, $010A, $0109, $0108
	dc.w	$0107, $0106, $0105, $0104, $0103, $0102, $0100, $00FF

; -------------------------------------------------------------------------

SineTable:
	dc.w	$0000, $0006, $000C, $0012, $0019, $001F, $0025, $002B
	dc.w	$0031, $0038, $003E, $0044, $004A, $0050, $0056, $005C
	dc.w	$0061, $0067, $006D, $0073, $0078, $007E, $0083, $0088
	dc.w	$008E, $0093, $0098, $009D, $00A2, $00A7, $00AB, $00B0
	dc.w	$00B5, $00B9, $00BD, $00C1, $00C5, $00C9, $00CD, $00D1
	dc.w	$00D4, $00D8, $00DB, $00DE, $00E1, $00E4, $00E7, $00EA
	dc.w	$00EC, $00EE, $00F1, $00F3, $00F4, $00F6, $00F8, $00F9
	dc.w	$00FB, $00FC, $00FD, $00FE, $00FE, $00FF, $00FF, $00FF
	dc.w	$0100, $00FF, $00FF, $00FF, $00FE, $00FE, $00FD, $00FC
	dc.w	$00FB, $00F9, $00F8, $00F6, $00F4, $00F3, $00F1, $00EE
	dc.w	$00EC, $00EA, $00E7, $00E4, $00E1, $00DE, $00DB, $00D8
	dc.w	$00D4, $00D1, $00CD, $00C9, $00C5, $00C1, $00BD, $00B9
	dc.w	$00B5, $00B0, $00AB, $00A7, $00A2, $009D, $0098, $0093
	dc.w	$008E, $0088, $0083, $007E, $0078, $0073, $006D, $0067
	dc.w	$0061, $005C, $0056, $0050, $004A, $0044, $003E, $0038
	dc.w	$0031, $002B, $0025, $001F, $0019, $0012, $000C, $0006
	dc.w	$0000, $FFFA, $FFF4, $FFEE, $FFE7, $FFE1, $FFDB, $FFD5
	dc.w	$FFCF, $FFC8, $FFC2, $FFBC, $FFB6, $FFB0, $FFAA, $FFA4
	dc.w	$FF9F, $FF99, $FF93, $FF8B, $FF88, $FF82, $FF7D, $FF78
	dc.w	$FF72, $FF6D, $FF68, $FF63, $FF5E, $FF59, $FF55, $FF50
	dc.w	$FF4B, $FF47, $FF43, $FF3F, $FF3B, $FF37, $FF33, $FF2F
	dc.w	$FF2C, $FF28, $FF25, $FF22, $FF1F, $FF1C, $FF19, $FF16
	dc.w	$FF14, $FF12, $FF0F, $FF0D, $FF0C, $FF0A, $FF08, $FF07
	dc.w	$FF05, $FF04, $FF03, $FF02, $FF02, $FF01, $FF01, $FF01
	dc.w	$FF00, $FF01, $FF01, $FF01, $FF02, $FF02, $FF03, $FF04
	dc.w	$FF05, $FF07, $FF08, $FF0A, $FF0C, $FF0D, $FF0F, $FF12
	dc.w	$FF14, $FF16, $FF19, $FF1C, $FF1F, $FF22, $FF25, $FF28
	dc.w	$FF2C, $FF2F, $FF33, $FF37, $FF3B, $FF3F, $FF43, $FF47
	dc.w	$FF4B, $FF50, $FF55, $FF59, $FF5E, $FF63, $FF68, $FF6D
	dc.w	$FF72, $FF78, $FF7D, $FF82, $FF88, $FF8B, $FF93, $FF99
	dc.w	$FF9F, $FFA4, $FFAA, $FFB0, $FFB6, $FFBC, $FFC2, $FFC8
	dc.w	$FFCF, $FFD5, $FFDB, $FFE1, $FFE7, $FFEE, $FFF4, $FFFA
	; Extra values for cosine
	dc.w	$0000, $0006, $000C, $0012, $0019, $001F, $0025, $002B
	dc.w	$0031, $0038, $003E, $0044, $004A, $0050, $0056, $005C
	dc.w	$0061, $0067, $006D, $0073, $0078, $007E, $0083, $0088
	dc.w	$008E, $0093, $0098, $009D, $00A2, $00A7, $00AB, $00B0
	dc.w	$00B5, $00B9, $00BD, $00C1, $00C5, $00C9, $00CD, $00D1
	dc.w	$00D4, $00D8, $00DB, $00DE, $00E1, $00E4, $00E7, $00EA
	dc.w	$00EC, $00EE, $00F1, $00F3, $00F4, $00F6, $00F8, $00F9
	dc.w	$00FB, $00FC, $00FD, $00FE, $00FE, $00FF, $00FF, $00FF

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