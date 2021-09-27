
; -------------------------------------------------------------------------
;
;	Sega CD Base
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Includes
; -------------------------------------------------------------------------

	include	"config.asm"			; Configuration
	include	"../include/macro.asm"		; Macros

; -------------------------------------------------------------------------
; Sound
; -------------------------------------------------------------------------

YM_ADDR_0	EQU	$A04000			; YM address port 0
YM_DATA_0	EQU	$A04001			; YM data port 0
YM_ADDR_1	EQU	$A04002			; YM address port 1
YM_DATA_1	EQU	$A04002			; YM data port 1
PSG_CTRL	EQU	$C00011			; PSG control port

; -------------------------------------------------------------------------
; I/O
; -------------------------------------------------------------------------

HW_VERSION	EQU	$A10001			; Hardware version
IO_A_DATA	EQU	$A10003			; I/O port A data port
IO_B_DATA	EQU	$A10005			; I/O port B data port
IO_C_DATA	EQU	$A10007			; I/O port C data port
IO_A_CTRL	EQU	$A10009			; I/O port A control port
IO_B_CTRL	EQU	$A1000B			; I/O port B control port
IO_C_CTRL	EQU	$A1000D			; I/O port C control port
CART_MODE	EQU	$A11000			; Cart mode (D-RAM/ROM)
SRAM_ENABLE	EQU	$A130F1			; SRAM enable port
TMSS_SEGA	EQU	$A14000			; TMSS "SEGA" register
TMSS_MODE	EQU	$A14100			; TMSS bus mode

; -------------------------------------------------------------------------
; Z80
; -------------------------------------------------------------------------

Z80_RAM		EQU	$A00000			; Z80 RAM start
Z80_END		EQU	$A02000			; Z80 RAM end
Z80_BUS		EQU	$A11100			; Z80 bus request
Z80_RESET	EQU	$A11200			; Z80 reset

; -------------------------------------------------------------------------
; VDP
; -------------------------------------------------------------------------

VDP_DATA	EQU	$C00000			; VDP data port
VDP_CTRL	EQU	$C00004			; VDP control port
VDP_HV		EQU	$C00008			; VDP H/V counter
VDP_DEBUG	EQU	$C0001C			; VDP debug

; -------------------------------------------------------------------------
; RAM
; -------------------------------------------------------------------------

RAM_START	EQU	$FF0000			; RAM start
RAM_END		EQU	$1000000		; RAM end

; -------------------------------------------------------------------------
; CD memory map
; -------------------------------------------------------------------------

WORDRAM_2M	EQU	$200000			; Word RAM in 2M mode
WORDRAM_1M	EQU	$200000			; Word RAM in 1M mode
VRAM_IMAGE	EQU	$220000			; VRAM image of Word RAM
IP_START	EQU	$FF0000			; Start of IP program

SUB_PRG_RAM	EQU	$00000			; PRG-RAM (Sub CPU)
SUB_WORDRAM_2M	EQU	$80000			; Word RAM in 2M mode (Sub CPU)
SUB_WORDRAM_1M	EQU	$C0000			; Word RAM in 1M mode (Sub CPU)

; -------------------------------------------------------------------------
; System RAM assignments
; -------------------------------------------------------------------------

_EXCPT		EQU	$FFFFFD00
_LEVEL6		EQU	$FFFFFD06		; V-INT
_LEVEL4		EQU	$FFFFFD0C		; H-INT
_LEVEL2		EQU	$FFFFFD12		; EXT-INT
_TRAP00		EQU	$FFFFFD18		; TRAP #00
_TRAP01		EQU	$FFFFFD1E		; TRAP #01
_TRAP02		EQU	$FFFFFD24		; TRAP #02
_TRAP03		EQU	$FFFFFD2A		; TRAP #03
_TRAP04		EQU	$FFFFFD30		; TRAP #04
_TRAP05		EQU	$FFFFFD36		; TRAP #05
_TRAP06		EQU	$FFFFFD3C		; TRAP #06
_TRAP07		EQU	$FFFFFD42		; TRAP #07
_TRAP08		EQU	$FFFFFD48		; TRAP #08
_TRAP09		EQU	$FFFFFD4E		; TRAP #09
_TRAP10		EQU	$FFFFFD54		; TRAP #10
_TRAP11		EQU	$FFFFFD5A		; TRAP #11
_TRAP12		EQU	$FFFFFD60		; TRAP #12
_TRAP13		EQU	$FFFFFD66		; TRAP #13
_TRAP14		EQU	$FFFFFD6C		; TRAP #14
_TRAP15		EQU	$FFFFFD72		; TRAP #15
_CHKERR		EQU	$FFFFFD78		; CHK exception
_ADRERR		EQU	$FFFFFD7E		; Address error
_CODERR		EQU	$FFFFFD7E		; Illegal instruction
_DIVERR		EQU	$FFFFFD84		; Division by zero error
_TRPERR		EQU	$FFFFFD8A		; TRAPV
_NOCOD0		EQU	$FFFFFD90		; Line A emulator
_NOCOD1		EQU	$FFFFFD96		; Line F emulator
_SPVERR		EQU	$FFFFFD9C		; Privilege violation
_TRACE		EQU	$FFFFFDA2		; TRACE exception

; -------------------------------------------------------------------------
; Gate array
; -------------------------------------------------------------------------

GA_BASE		EQU	$A12000			; Gate array base

; -------------------------------------------------------------------------

gaReset		EQU	$0000			; Peripheral reset
gaMemMode	EQU	$0002			; Memory mode/Write protection
gaCDCMode	EQU	$0004			; CDC mode/Device destination
gaHINT		EQU	$0006			; H-INT address
gaCDCHost	EQU	$0008			; 16 bit CDC data to host
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

GA_RESET	EQU	GA_BASE+gaReset		; Peripheral reset
GA_MEM_MODE	EQU	GA_BASE+gaMemMode	; Memory mode/Write protection
GA_CDC_MODE	EQU	GA_BASE+gaCDCMode	; CDC mode/Device destination
GA_HINT		EQU	GA_BASE+gaHINT		; H-INT address
GA_CDC_HOST	EQU	GA_BASE+gaCDCHost	; 16 bit CDC data to host
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

; -------------------------------------------------------------------------
; Other includes
; -------------------------------------------------------------------------

	include	"../include/macromd.asm"	; Mega Drive macros

; -------------------------------------------------------------------------
