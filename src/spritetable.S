#include "tony.inc"

.text
entry:
    .byte sprite_00_chunk_start@mos16lo
    .byte sprite_00_chunk_start@mos16hi
    .byte sprite_00_chunk_start@mos24bank
    .byte 0xff, 0xff, 0xff
