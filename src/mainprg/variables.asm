
; -------------------------------------------------------------------------
;
;	Sega CD Base
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	RAM_START+$FF00E000

vars_start	rs.b	0

palette		rs.b	$80			; Palette buffer
fade_palette	rs.b	$80			; Fade palette buffer
sprites		rs.b	$280			; Sprite buffer
hscroll		rs.b	$380			; HScroll buffer
vscroll		rs.b	$50			; VScroll buffer
scroll_end	rs.b	0

fade_info	rs.b	0			; Fade info
fade_start	rs.b	1			; Fade start
fade_length	rs.b	1			; Fade length

frame_count	rs.w	1			; Frame count

p1_ctrl		rs.b	0			; Player 1 controls
p1_held		rs.b	1			; Player 1 controls (held)
p1_press	rs.b	1			; Player 1 controls (pressed)
p2_ctrl		rs.b	0			; Player 2 controls
p2_held		rs.b	1			; Player 2 controls (held)
p2_press	rs.b	1			; Player 2 controls (pressed)

		rsEven
vars_end	rs.b	0

; -------------------------------------------------------------------------
