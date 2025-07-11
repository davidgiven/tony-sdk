#include "tony.inc"
#include "zif.inc"

.text
entry:
    sei                                     
    lda #0x02                            
    sta 0x7C                             
    lda #0x05                            
    sta 0x7E                             
    lda #0x81                            
    sta 0x7F                             
    stz 0x7E                             
    lda #0x01                            
    stz 0x7F                             
    lda #0x01                            
    sta 0x7B                             
    bbr3 0x7B, .                       
    lda #0x05                            
    sta 0x7D                             
    lda #0x08                            
    sta 0x28                             
    lda #0xC0                            
    sta 0x29                             
    lda #0xE8                            
    sta 0x26                             
    lda #0xCF                            
    sta 0x27                             
    ldx #0x10                            
    stz 0x3C                             
    stx 0x3E                             
    rts                                     

