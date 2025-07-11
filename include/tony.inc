#pragma once

.zeropage GPIO
GPIO_CS = 0x08

.zeropage i0, i1, i2, i3, i4, i5
.zeropage o0, i1, i2, i3
.zeropage screen_width, screen_height

.extern SYSCALL, READFLASH, CHUNKJUMP, CHUNKCALL
.extern LCD_DATA, LCD_CMD

.macro _setupchunk name
    .extern \name\()_chunk_start
    .extern \name\()_chunk_size
    lda #<\name\()_chunk_start
    sta i0
    lda #>\name\()_chunk_start
    sta i1
    lda #^\name\()_chunk_start
    sta i2
    lda #<\name\()_chunk_len
    sta i3
    lda #>\name\()_chunk_len
    sta i4
.endm

.macro chunkjump name
    _setupchunk \name
    jmp CHUNKJUMP
.endm

.macro chunkcall name
    _setupchunk \name
    jsr CHUNKCALL
.endm
