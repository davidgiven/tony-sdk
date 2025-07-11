.text
entry:
    lda 2
    and #0xf7
    sta 2
    ora #8
    sta 2
    bra entry