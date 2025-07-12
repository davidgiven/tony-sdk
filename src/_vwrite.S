#include "tony.inc"

.text
; On entry:
;   p0, p1: (x, y) of top-left corner of window
;   i5, i6: (w, h) of size of window

entry:
    lda #0x3
    sta LCD_CONTROL

    lda #0x2b ; row address set
    sta LCD_CMD   
    stz LCD_DATA  
    lda p1
    sta LCD_DATA  
    stz LCD_DATA  
    clc
    adc i6
    dec a
    sta LCD_DATA  

    lda #0x2a ; column address set
    sta LCD_CMD   
    stz LCD_DATA  
    lda p0
    sta LCD_DATA  
    stz LCD_DATA  
    clc
    adc i5
    dec a
    sta LCD_DATA  

    lda #0x2c ; memory write
    sta LCD_CMD   
    rts
