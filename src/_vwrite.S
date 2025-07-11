#include "tony.inc"

entry:
    lda #0
    sta 2
    lda #8
    sta 2
    bra entry
