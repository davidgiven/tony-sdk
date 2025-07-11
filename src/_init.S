#include "tony.inc"
#include "zif.inc"

.text
entry:
    stz 0x70
    stz 0x71                             
    stz 0x2A                             
    lda #0x80                            
    sta 0x6E                             
    stz 0x6D                             
    lda #0xA0                            
    sta 0x05                             
    lda #0xFF                            
    sta 0x48                             
    sta 0x49                             
    sta 0x4A                             
    lda #0x0C                            
    sta 0x4E                             
    stz 0x34                             
    lda #0x03                            
    sta 0x35                             
    lda #0x7F                            
    sta 0x09                             
    lda #0xFD                            
    sta 0x01                             
    jsr delay                           
    lda #0xBD                            
    sta 0x01                             
    jsr delay                           
    lda #0xFF                            
    sta 0x09                             
    lda #0xFD                            
    sta 0x01                             
    sta 0x0180                           
    jsr delay                           
    lda #0x11                            
    sta LCD_CMD                           
    lda #0x04                            
    sta LCD_CMD                           
    lda LCD_DATA                           
    lda LCD_DATA                           
    ldx LCD_DATA                           
    ldy LCD_DATA                           

    cmp #0x33
    zif eq
        cpx #0x30
        zif eq
            cpy #0x23
            zif eq
                chunkcall init_screen_333023
                jmp done
            zendif
        zendif
    zendif

    cmp #0xd4
    zif eq
        cpx #0x80
        zif eq
            cpy #0x66
            zif eq
                chunkcall init_screen_d48066
                bra done
            zendif
        zendif
    zendif

    cmp #0x31
    zif eq
        cpx #0x30
        zif eq
            cpy #0x21
            zif eq
                chunkcall init_screen_313021
                bra done
            zendif
        zendif
    zendif

    cmp #0x00
    zif eq
        cpx #0x91
        zif eq
            cpy #0x06
            zif eq
                chunkcall init_screen_009106
                bra done
            zendif
        zendif
    zendif

    ; anything else
    chunkcall init_screen_other

done:
    stz 0x34                             
    jsr delay                           
    lda #0xA0                            
    sta screen_height                             
    lda #0x80                            
    sta screen_width
    stz 0xB6                             

    chunkjump init_other

delay:
    ldx #0
    ldy #0
    lda #4
    zrepeat
        zrepeat
            zrepeat
                phy
                ply
                dey
            zuntil eq
            dex
        zuntil eq
        dec a
    zuntil eq
    rts                                     
