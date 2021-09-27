
; -------------------------------------------------------------------------
;
;	Sega CD Base
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

	include	"config.asm"			; Configuration
	include	"../include/macro.asm"		; Macros
	include	"../include/cdbios.asm"		; CD BIOS definitions

; -------------------------------------------------------------------------
; Memory map
; -------------------------------------------------------------------------

PRG_RAM		EQU	$00000			; PRG-RAM
WORDRAM_2M	EQU	$80000			; Word RAM in 2M mode	
WORDRAM_1M	EQU	$C0000			; Word RAM in 1M mode
SP_START	EQU	$6000			; Start of SP program

; -------------------------------------------------------------------------
; Gate array
; -------------------------------------------------------------------------

GA_BASE		EQU	$FFFF8000		; Gate array base
PCM_BASE	EQU	$FFFF0000		; PCM chip base

; -------------------------------------------------------------------------

gaReset		EQU	$0000			; Peripheral reset
gaMemMode	EQU	$0002			; Memory mode/Write protection
gaCDCMode	EQU	$0004			; CDC mode/Device destination
gaCRS1		EQU	$0006			; CDC control register
gaCDCHost	EQU	$0008			; 16 bit CDC data to host
gaDMAAddr	EQU	$000A			; DMA offset into destination area
gaStopwatch	EQU	$000C			; CDC/gp timer 30.72us LSB
gaComFlags	EQU	$000E			; Communication flags
gaMainFlag	EQU	$000E			; Main CPU communication flag
gaSubFlag	EQU	$000F			; Sub CPU communication flag
gaCmds		EQU	$0010			; Communication commands
gaCmd0		EQU	$0010			; Communication command 0
gaCmd2		EQU	$0012			; Communication command 2
gaCmd4		EQU	$0014			; Communication command 4
gaCmd6		EQU	$0016			; Communication command 6
gaCmd8		EQU	$0018			; Communication command 8
gaCmdA		EQU	$001A			; Communication command A
gaCmdC		EQU	$001C			; Communication command C
gaCmdE		EQU	$001E			; Communication command E
gaStats		EQU	$0020			; Communication statuses
gaStat0		EQU	$0020			; Communication status 0
gaStat2		EQU	$0022			; Communication status 2
gaStat4		EQU	$0024			; Communication status 4
gaStat6		EQU	$0026			; Communication status 6
gaStat8		EQU	$0028			; Communication status 8
gaStatA		EQU	$002A			; Communication status A
gaStatC		EQU	$002C			; Communication status C
gaStatE		EQU	$002E			; Communication status E
gaInt3Timer	EQU	$0030			; Interrupt 3 timer
gaIntMask	EQU	$0032			; Interrupt mask
gaCDFader	EQU	$0034			; Fader control/Spindle speed
gaCDDCtrl	EQU	$0036			; CDD control
gaCDDComm	EQU	$0038			; CDD communication
gaFontCol	EQU	$004C			; Source color values
gaFontBits	EQU	$004E			; Font data
gaFontData	EQU	$0056			; Read only
gaStampSz	EQU	$0058			; Stamp size/Map size
gaStampMap	EQU	$005A			; Stamp map base address
gaImgVCell	EQU	$005C			; Image buffer V size in cells
gaImgStart	EQU	$005E			; Image buffer start address
gaImgOff	EQU	$0060			; Image buffer offset
gaImgHDot	EQU	$0062			; Image buffer H size in dots
gaImgVDot	EQU	$0064			; Image buffer V size in dots
gaTrace		EQU	$0066			; Trace vector base address
gaSubAddr	EQU	$0068			; Subcode top address
gaSubcode	EQU	$0100			; 64 word subcode buffer
gaSubImg	EQU	$0180			; Image of subcode buffer

GA_RESET	EQU	GA_BASE+gaReset		; Peripheral reset
GA_MEM_MODE	EQU	GA_BASE+gaMemMode	; Memory mode/Write protection
GA_CDC_MODE	EQU	GA_BASE+gaCDCMode	; CDC mode/Device destination
GA_CRS1		EQU	GA_BASE+gaCRS1		;  CDC control register
GA_CDC_HOST	EQU	GA_BASE+gaCDCHost	; 16 bit CDC data to host
GA_DMA_ADDR	EQU	GA_BASE+gaDMAAddr	; DMA offset into destination area
GA_STOPWATCH	EQU	GA_BASE+gaStopwatch	; CDC/gp timer 30.72us LSB
GA_COM_FLAGS	EQU	GA_BASE+gaFlags		; Communication flags
GA_MAIN_FLAG	EQU	GA_BASE+gaMainFlag	; Main CPU communication flag
GA_SUB_FLAG	EQU	GA_BASE+gaSubFlag	; Sub CPU communication flag
GA_CMDS		EQU	GA_BASE+gaCmds		; Communication commands
GA_CMD_0	EQU	GA_BASE+gaCmd0		; Communication command 0
GA_CMD_2	EQU	GA_BASE+gaCmd2		; Communication command 2
GA_CMD_4	EQU	GA_BASE+gaCmd4		; Communication command 4
GA_CMD_6	EQU	GA_BASE+gaCmd6		; Communication command 6
GA_CMD_8	EQU	GA_BASE+gaCmd8		; Communication command 8
GA_CMD_A	EQU	GA_BASE+gaCmdA		; Communication command A
GA_CMD_C	EQU	GA_BASE+gaCmdC		; Communication command C
GA_CMD_E	EQU	GA_BASE+gaCmdE		; Communication command E
GA_STATS	EQU	GA_BASE+gaStats		; Communication statuses
GA_STAT_0	EQU	GA_BASE+gaStat0		; Communication status 0
GA_STAT_2	EQU	GA_BASE+gaStat2		; Communication status 2
GA_STAT_4	EQU	GA_BASE+gaStat4		; Communication status 4
GA_STAT_6	EQU	GA_BASE+gaStat6		; Communication status 6
GA_STAT_8	EQU	GA_BASE+gaStat8		; Communication status 8
GA_STAT_A	EQU	GA_BASE+gaStatA		; Communication status A
GA_STAT_C	EQU	GA_BASE+gaStatC		; Communication status C
GA_STAT_E	EQU	GA_BASE+gaStatE		; Communication status E
GA_INT3_TIMER	EQU	GA_BASE+gaInt3Timer	; Interrupt 3 timer
GA_INT_MASK	EQU	GA_BASE+gaIntMask	; Interrupt mask
GA_CD_FADER	EQU	GA_BASE+gaCDFader	; Fader control/Spindle speed
GA_CDD_CTRL	EQU	GA_BASE+gaCDDCtrl	; CDD control
GA_CDD_COMM	EQU	GA_BASE+gaCDDComm	; CDD communication
GA_FONT_COLOR	EQU	GA_BASE+gaFontCol	; Source color values
GA_FONT_BITS	EQU	GA_BASE+gaFontBits	; Font data
GA_FONT_DATA	EQU	GA_BASE+gaFontData	; Read only
GA_STAMP_SIZE	EQU	GA_BASE+gaStampSz	; Stamp size/Map size
GA_STAMP_MAP	EQU	GA_BASE+gaStampMap	; Stamp map base address
GA_IMG_VCELL	EQU	GA_BASE+gaImgVCell	; Image buffer V size in cells
GA_IMG_START	EQU	GA_BASE+gaImgStart	; Image buffer start address
GA_IMG_OFFSET	EQU	GA_BASE+gaImgOff	; Image buffer offset
GA_IMG_HDOT	EQU	GA_BASE+gaImgHDot	; Image buffer H size in dots
GA_IMG_VDOT	EQU	GA_BASE+gaImgVDot	; Image buffer V size in dots
GA_IMG_TRACE	EQU	GA_BASE+gaTrace		; Trace vector base address
GA_SUBCODE_ADDR	EQU	GA_BASE+gaSubAddr	; Subcode top address
GA_SUBCODE	EQU	GA_BASE+gaSubcode	; 64 word subcode buffer
GA_SUBCODE_IMG	EQU	GA_BASE+gaSubImg	; Image of subcode buffer

; -------------------------------------------------------------------------
; PCM chip registers
; -------------------------------------------------------------------------

pcmEnv		EQU	$0000*2+1		; Volume
pcmPan		EQU	$0001*2+1		; Pan
pcmFDL		EQU	$0002*2+1		; Frequency (low)
pcmFDH		EQU	$0003*2+1		; Frequency (high)
pcmLSL		EQU	$0004*2+1		; Wave memory stop address (high)
pcmLSH		EQU	$0005*2+1		; Wave memory stop address (low)
pcmST		EQU	$0006*2+1		; Start of wave memory
pcmCtrl		EQU	$0007*2+1		; Control
pcmOnOff	EQU	$0008*2+1		; On/Off
pcmWaveAddr	EQU	$0010*2+1		; Wave address
pcmWaveData	EQU	$1000*2+1		; Wave data

; -------------------------------------------------------------------------

PCM_ENV		EQU	PCM_BASE+pcmEnv		; Volume
PCM_PAN		EQU	PCM_BASE+pcmPan		; Pan
PCM_FDL		EQU	PCM_BASE+pcmFDL		; Frequency (low)
PCM_FDH		EQU	PCM_BASE+pcmFDH		; Frequency (high)
PCM_LSL		EQU	PCM_BASE+pcmLSL		; Wave memory stop address (high)
PCM_LSH		EQU	PCM_BASE+pcmLSH		; Wave memory stop address (low)
PCM_ST		EQU	PCM_BASE+pcmST		; Start of wave memory
PCM_CTRL	EQU	PCM_BASE+pcmCtrl	; Control
PCM_ON_OFF	EQU	PCM_BASE+pcmOnOff	; On/Off
PCM_WAVE_ADDR	EQU	PCM_BASE+pcmWaveAddr	; Wave address
PCM_WAVE_DATA	EQU	PCM_BASE+pcmWaveData	; Wave data

; -------------------------------------------------------------------------
