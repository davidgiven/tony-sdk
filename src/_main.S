#include "tony.inc"

entry:
    lda #65
    sta p2
    stz p0
    stz p1
    lda #0xff
    sta p3
    stz p4
    ldx #SYS_DRAW_CHAR
    jsr SYSCALL

    lda #66
    sta p2
    lda #8
    sta p0
    stz p1
    lda #0xff
    sta p3
    stz p4
    ldx #SYS_DRAW_CHAR
    jsr SYSCALL

    bra entry
