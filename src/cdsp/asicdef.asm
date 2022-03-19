
; -------------------------------------------------------------------------
;
;	Sega CD ASIC demo
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

STAMP_DATA	EQU	$00000			; Stamp data location in Word RAM
STAMP_MAP	EQU	$10000			; Stamp map location in Word RAM
TRACE_TABLE	EQU	$20000			; Trace table location in Word RAM
IMG_BUFFER	EQU	$30000			; Image buffer location in Word RAM

IMG_WIDTH	EQU	256			; Image buffer width
IMG_HEIGHT	EQU	112			; Image buffer height
IMG_FOV		EQU	128			; FOV
IMG_TILE_H	EQU	(IMG_HEIGHT+((7-(IMG_HEIGHT&7))&7))/8
IMG_SIZE	EQU	(IMG_WIDTH/8)*(IMG_HEIGHT/8)*$20

; -------------------------------------------------------------------------