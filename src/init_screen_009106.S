#include "tony.inc"
#include "zif.inc"

.text
entry:
    lda #0xFE                            
    sta LCD_CMD                           
    lda #0xFE                            
    sta LCD_CMD                           
    lda #0xEF                            
    sta LCD_CMD                           
    lda #0xB3                            
    sta LCD_CMD                           
    lda #0x03                            
    sta LCD_DATA                           
    lda #0xB6                            
    sta LCD_CMD                           
    lda #0x01                            
    sta LCD_DATA                           
    lda #0xA3                            
    sta LCD_CMD                           
    lda #0x11                            
    sta LCD_DATA                           
    lda #0x21                            
    sta LCD_CMD                           
    lda #0x36                            
    sta LCD_CMD                           
    lda #0xA0                            
    sta LCD_DATA                           
    lda #0x3A                            
    sta LCD_CMD                           
    lda #0x05                            
    sta LCD_DATA                           
    lda #0xB4                            
    sta LCD_CMD                           
    lda #0x21                            
    sta LCD_DATA                           
    lda #0xB1                            
    sta LCD_CMD                           
    lda #0xC0                            
    sta LCD_DATA                           
    lda #0xE6                            
    sta LCD_CMD                           
    lda #0x50                            
    sta LCD_DATA                           
    lda #0x43                            
    sta LCD_DATA                           
    lda #0xE7                            
    sta LCD_CMD                           
    lda #0x38                            
    sta LCD_DATA                           
    lda #0x43                            
    sta LCD_DATA                           
    lda #0xF0                            
    sta LCD_CMD                           
    lda #0x0C                            
    sta LCD_DATA                           
    lda #0x46                            
    sta LCD_DATA                           
    lda #0x25                            
    sta LCD_DATA                           
    lda #0x56                            
    sta LCD_DATA                           
    lda #0xAC                            
    sta LCD_DATA                           
    lda #0x24                            
    sta LCD_DATA                           
    lda #0x25                            
    sta LCD_DATA                           
    lda #0x00                            
    sta LCD_DATA                           
    lda #0x00                            
    sta LCD_DATA                           
    lda #0x12                            
    sta LCD_DATA                           
    lda #0x15                            
    sta LCD_DATA                           
    lda #0x16                            
    sta LCD_DATA                           
    lda #0x17                            
    sta LCD_DATA                           
    lda #0x0F                            
    sta LCD_DATA                           
    lda #0xF1                            
    sta LCD_CMD                           
    lda #0x00                            
    sta LCD_DATA                           
    lda #0x26                            
    sta LCD_DATA                           
    lda #0x25                            
    sta LCD_DATA                           
    lda #0x3A                            
    sta LCD_DATA                           
    lda #0xB9                            
    sta LCD_DATA                           
    lda #0x0F                            
    sta LCD_DATA                           
    lda #0x10                            
    sta LCD_DATA                           
    lda #0x00                            
    sta LCD_DATA                           
    lda #0x00                            
    sta LCD_DATA                           
    lda #0x07                            
    sta LCD_DATA                           
    lda #0x07                            
    sta LCD_DATA                           
    lda #0x17                            
    sta LCD_DATA                           
    lda #0x16                            
    sta LCD_DATA                           
    lda #0x0F                            
    sta LCD_DATA                           
    lda #0x35                            
    sta LCD_CMD                           
    lda #0x00                            
    sta LCD_DATA                           
    lda #0x44                            
    sta LCD_CMD                           
    lda #0x00                            
    sta LCD_DATA                           
    lda #0xFE                            
    sta LCD_CMD                           
    lda #0xFF                            
    sta LCD_CMD                           
    lda #0x11                            
    sta LCD_CMD                           
    jsr delay                           
    lda #0x29                            
    sta LCD_CMD                           
    rts                                     

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

