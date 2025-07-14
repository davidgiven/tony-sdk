#include "tony.inc"
#include "zif.inc"

.text
entry:
	stz p0               ; 0300 9c 00 01
	lda #0x7f            ; 0303 a9 7f
	sta p1               ; 0305 8d 01 01
	lda #0x2f
	sta p2               ; 030a 8d 02 01
	ldx #0x0c            ; 030d a2 0c
	jsr SYSCALL          ; 030f 20 00 60
	lda #24
	sta p0               ; 0314 8d 00 01
	lda #0x30            ; 0317 a9 30
	sta p1               ; 0319 8d 01 01
	ldx #0
	zloop
		lda text, x         ; 0322 bd 48 03
		zbreakif eq
		jsr drawchar
		inx
	zendloop
	
	stz p0
	stz p1
	stz p2
	stz p3
	stz p4
	lda #0xff
	sta p5
	ldx #SYS_DRAW_SPRITE
	jsr SYSCALL
	rts

drawchar:
	sta p2               ; 032e 8d 02 01
	stz p3               ; 0331 9c 03 01
	lda p0               ; 0334 ad 00 01
	phx                  ; 0337 da
	pha                  ; 0338 48
	ldx #SYS_DRAW_CHAR
	jsr SYSCALL          ; 033b 20 00 60
	pla                  ; 033e 68
	plx                  ; 033f fa
	clc                  ; 0340 18
	adc #0x08            ; 0341 69 08
	sta p0               ; 0343 8d 00 01
	rts                  ; 0347 60

 text:
    .asciz "Hello, world!"
