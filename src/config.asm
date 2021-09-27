
; -------------------------------------------------------------------------
;
;	Sega CD Base
;		By Ralakimus 2021
;
; -------------------------------------------------------------------------

	opt	l.				; Use "." for local labels
	opt	op+				; Optimize to PC relative addressing
	opt	os+				; Optimize short branches
	opt	ow+				; Optimize absolute long addressing
	opt	oz+				; Optimize zero displacements
	opt	oaq+				; Optimize to addq
	opt	osq+				; Optimize to subq
	opt	omq+				; Optimize to moveq
	opt	ae-				; Disable automatic evens

; -------------------------------------------------------------------------
