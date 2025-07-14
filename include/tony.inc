#pragma once

.zeropage GPIO1, GPIO2, GPDIR0, GPDIR1, LCD_CONTROL
GPIO1_LCD_BACKLIGHT = 0x02
GPIO2_CS = 0x08

SYS_DRAW_SPRITE_IMM              = 0x00
SYS_FILL_RECTANGLE_IMM           = 0x04
SYS_GET_SPRITE_INFO              = 0x06
SYS_DRAW_SPRITE                  = 0x08
SYS_CLEAR_DISPLAY_LIST_TO_SPRITE = 0x0a
SYS_CLEAR_DISPLAY_LIST_TO_COLOUR = 0x0c
SYS_CLEAR_DISPLAY_LIST_TO_VIDEO  = 0x0e
SYS_DRAW_CHAR                    = 0x24
SYS_DRAW_CHAR_IMM                = 0x26

.zeropage i0, i1, i2, i3, i4, i5, i6
.zeropage o0, i1, i2, i3
.zeropage screen_width, screen_height

.extern p0, p1, p2, p3, p4, p5, p6, p7, p8
.extern SYSCALL, READFLASH, CHUNKJUMP, CHUNKCALL
.extern LCD_DATA, LCD_CMD
.extern shadow_01

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

.macro resource_reference name
    .byte \name\()_chunk_start@mos16lo
    .byte \name\()_chunk_start@mos16hi
    .byte \name\()_chunk_start@mos24bank
.endm
