#include "tony.inc"
.text
entry:
	stz p0               ; 0300 9c 00 01
	lda #0x7f            ; 0303 a9 7f
	sta p1               ; 0305 8d 01 01
	lda 0x2ff            ; 0308 a9 37
    inc 0x2ff
	sta p2               ; 030a 8d 02 01
	ldx #0x0c            ; 030d a2 0c
	jsr SYSCALL          ; 030f 20 00 60
	lda #24
	sta p0               ; 0314 8d 00 01
	lda #0x30            ; 0317 a9 30
	sta p1               ; 0319 8d 01 01
	ldx #0
L0322:
	lda text, x         ; 0322 bd 48 03
	beq L0347            ; 0327 f0 1e
	jsr L032e            ; 0329 20 2e 03
	bra L0322            ; 032c 80 f4
L032e:
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
	inx                  ; 0346 e8
L0347:
	rts                  ; 0347 60
 text:
    .asciz "Hello, world!"
