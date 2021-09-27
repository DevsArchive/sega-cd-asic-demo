
; -------------------------------------------------------------------------
;
;	Sega CD Base
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

	include	"../include/maincpu.asm"

; -------------------------------------------------------------------------
; Header
; -------------------------------------------------------------------------

	org	0

	dc.b	"SEGADISCSYSTEM  "		; Disk type ID
	dc.b	"MCD_ASIC   ", 0		; Volume ID
	dc.w	$0100				; Volume version
	dc.w	$0001				; CD-ROM = $0001
	dc.b	"MEGA_CD    ", 0		; System name
	dc.w	$0001				; System version
	dc.w	$0000				; Always 0
	dc.l	$00000200			; IP disk address
	dc.l	$00000600			; IP load size
	dc.l	$00000000			; IP entry offset
	dc.l	$00000000			; IP work RAM size
	dc.l	$00000800			; SP disk address
	dc.l	$00007800			; SP load size
	dc.l	$00000000			; SP entry offset
	dc.l	$00000000			; SP work RAM size
	align	$100

	dc.b	"SEGA MEGA DRIVE "		; Hardware ID
	dc.b	"RALA  SEP26 2021"		; Release date
	dc.b	"SEGA CD ASIC DEM"		; Japanese game name
	dc.b	"O BY RALAKIMUS  "
	dc.b	"                "
	dc.b	"SEGA CD ASIC DEM"		; Overseas game name
	dc.b	"O BY RALAKIMUS  "
	dc.b	"                "
	dc.b	"GM 69420 HA-HA  "		; Game version
	dc.b	"J               "		; I/O support
	dc.b	"                "		; Space
	dc.b	"                "
	dc.b	"                "
	dc.b	"                "
	dc.b	"                "
	dc.b	"U               "		; Region

; -------------------------------------------------------------------------
; Programs
; -------------------------------------------------------------------------

	incbin	"cdip/ip.bin"
	align	$800
	incbin	"cdsp/sp.bin"
	align	$8000

; -------------------------------------------------------------------------
; File data
; -------------------------------------------------------------------------

	incbin	"files.bin", $8000
	align	$8000

; -------------------------------------------------------------------------