#include "tony.inc"
#include "zif.inc"

FRAME_ID = 0x2ff

.text
entry:
	; Clear the display list to one of our background frames.

	stz p0
	stz p1

	clc
	lda FRAME_ID
	adc #<FRAME0_RSRCID
	sta p2
	lda #0
	adc #>FRAME0_RSRCID
	sta p3

	stz p4
	lda #0xff
	sta p5
	ldx #SYS_CLEAR_DISPLAY_LIST_TO_SPRITE
	jsr SYSCALL

	; Advance to the next frame.

	lda FRAME_ID
	inc a
	cmp #14
	zif eq
		lda #0
	zendif
	sta FRAME_ID

	; Unsure how this works. I think it sets the GPIO ports to input (except for
	; the bit in GPIO1 which controls the backlight), and then lets the drivers
	; float high so that the buttons can pull them low.

	lda #0xfe
	sta GPDIR1
	lda shadow_01
	ora #1
	sta GPIO1

	lda #0xff
	stz GPDIR0
	sta GPIO0

	; This delay is necessary before reading the GPIOs or you get glitching.
	; For some reason.

	ldx #15
	zrepeat
		pha
		pla
		dex
	zuntil eq

	; Draw the overlay.

	lda #3
	sta p0
	sta p1

	lda GPIO0
	eor #0xff
	jsr hex8
	jsr space

	lda GPIO1
	eor #0xff
	jsr hex8
	jsr space

	rts

hex8:
	pha
    lsr a
    lsr a
    lsr a
    lsr a
    jsr print_h4
    pla
    and #0x0f
print_h4:
	ldx p0
	ldy p1
	phx
	phy

	clc
	adc #<N0_RSRCID
	sta p2
	lda #0
	adc #>N0_RSRCID
	sta p3

	stz p4
	lda #0xff
	sta p5
	ldx #SYS_DRAW_SPRITE
	jsr SYSCALL
	
	ply
	plx
	stx p0
	sty p1
space:
	clc       
	lda p0
	adc #0x0a
	sta p0  
	rts    
