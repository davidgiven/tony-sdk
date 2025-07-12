#include "tony.inc"

.macro scanline n
    .byte \n, \n
.endm

scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000

scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000
scanline 0b00011000
scanline 0b00000000

scanline 0b01101100
scanline 0b01101100
scanline 0b01101100
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000

scanline 0b00110110
scanline 0b00110110
scanline 0b01111111
scanline 0b00110110
scanline 0b01111111
scanline 0b00110110
scanline 0b00110110
scanline 0b00000000

scanline 0b00001100
scanline 0b00111111
scanline 0b01101000
scanline 0b00111110
scanline 0b00001011
scanline 0b01111110
scanline 0b00011000
scanline 0b00000000

scanline 0b01100000
scanline 0b01100110
scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b01100110
scanline 0b00000110
scanline 0b00000000

scanline 0b00111000
scanline 0b01101100
scanline 0b01101100
scanline 0b00111000
scanline 0b01101101
scanline 0b01100110
scanline 0b00111011
scanline 0b00000000

scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000

scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b00110000
scanline 0b00110000
scanline 0b00011000
scanline 0b00001100
scanline 0b00000000

scanline 0b00110000
scanline 0b00011000
scanline 0b00001100
scanline 0b00001100
scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b00000000

scanline 0b00000000
scanline 0b00011000
scanline 0b01111110
scanline 0b00111100
scanline 0b01111110
scanline 0b00011000
scanline 0b00000000
scanline 0b00000000

scanline 0b00000000
scanline 0b00011000
scanline 0b00011000
scanline 0b01111110
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00011000
scanline 0b00011000
scanline 0b00110000

scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b01111110
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000

scanline 0b00000000
scanline 0b00000110
scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b01100000
scanline 0b00000000
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01101110
scanline 0b01111110
scanline 0b01110110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b00011000
scanline 0b00111000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b01111110
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b00000110
scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b01111110
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b00000110
scanline 0b00011100
scanline 0b00000110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b00001100
scanline 0b00011100
scanline 0b00111100
scanline 0b01101100
scanline 0b01111110
scanline 0b00001100
scanline 0b00001100
scanline 0b00000000

scanline 0b01111110
scanline 0b01100000
scanline 0b01111100
scanline 0b00000110
scanline 0b00000110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b00011100
scanline 0b00110000
scanline 0b01100000
scanline 0b01111100
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b01111110
scanline 0b00000110
scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b00110000
scanline 0b00110000
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01100110
scanline 0b00111110
scanline 0b00000110
scanline 0b00001100
scanline 0b00111000
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000
scanline 0b00011000
scanline 0b00011000
scanline 0b00110000

scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b01100000
scanline 0b00110000
scanline 0b00011000
scanline 0b00001100
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b01111110
scanline 0b00000000
scanline 0b01111110
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000

scanline 0b00110000
scanline 0b00011000
scanline 0b00001100
scanline 0b00000110
scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b00001100
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000
scanline 0b00011000
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01101110
scanline 0b01101010
scanline 0b01101110
scanline 0b01100000
scanline 0b00111100
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01111110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00000000

scanline 0b01111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01111100
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b01111000
scanline 0b01101100
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01101100
scanline 0b01111000
scanline 0b00000000

scanline 0b01111110
scanline 0b01100000
scanline 0b01100000
scanline 0b01111100
scanline 0b01100000
scanline 0b01100000
scanline 0b01111110
scanline 0b00000000

scanline 0b01111110
scanline 0b01100000
scanline 0b01100000
scanline 0b01111100
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01100000
scanline 0b01101110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01111110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00000000

scanline 0b01111110
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b01111110
scanline 0b00000000

scanline 0b00111110
scanline 0b00001100
scanline 0b00001100
scanline 0b00001100
scanline 0b00001100
scanline 0b01101100
scanline 0b00111000
scanline 0b00000000

scanline 0b01100110
scanline 0b01101100
scanline 0b01111000
scanline 0b01110000
scanline 0b01111000
scanline 0b01101100
scanline 0b01100110
scanline 0b00000000

scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b01111110
scanline 0b00000000

scanline 0b01100011
scanline 0b01110111
scanline 0b01111111
scanline 0b01101011
scanline 0b01101011
scanline 0b01100011
scanline 0b01100011
scanline 0b00000000

scanline 0b01100110
scanline 0b01100110
scanline 0b01110110
scanline 0b01111110
scanline 0b01101110
scanline 0b01100110
scanline 0b01100110
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b01111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01111100
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01101010
scanline 0b01101100
scanline 0b00110110
scanline 0b00000000

scanline 0b01111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01111100
scanline 0b01101100
scanline 0b01100110
scanline 0b01100110
scanline 0b00000000

scanline 0b00111100
scanline 0b01100110
scanline 0b01100000
scanline 0b00111100
scanline 0b00000110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b01111110
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000

scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00011000
scanline 0b00000000

scanline 0b01100011
scanline 0b01100011
scanline 0b01101011
scanline 0b01101011
scanline 0b01111111
scanline 0b01110111
scanline 0b01100011
scanline 0b00000000

scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00011000
scanline 0b00111100
scanline 0b01100110
scanline 0b01100110
scanline 0b00000000

scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000

scanline 0b01111110
scanline 0b00000110
scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b01100000
scanline 0b01111110
scanline 0b00000000

scanline 0b01111100
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b01111100
scanline 0b00000000

scanline 0b00000000
scanline 0b01100000
scanline 0b00110000
scanline 0b00011000
scanline 0b00001100
scanline 0b00000110
scanline 0b00000000
scanline 0b00000000

scanline 0b00111110
scanline 0b00000110
scanline 0b00000110
scanline 0b00000110
scanline 0b00000110
scanline 0b00000110
scanline 0b00111110
scanline 0b00000000

scanline 0b00011000
scanline 0b00111100
scanline 0b01100110
scanline 0b01000010
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b11111111

scanline 0b00011100
scanline 0b00110110
scanline 0b00110000
scanline 0b01111100
scanline 0b00110000
scanline 0b00110000
scanline 0b01111110
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00111100
scanline 0b00000110
scanline 0b00111110
scanline 0b01100110
scanline 0b00111110
scanline 0b00000000

scanline 0b01100000
scanline 0b01100000
scanline 0b01111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01111100
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00111100
scanline 0b01100110
scanline 0b01100000
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b00000110
scanline 0b00000110
scanline 0b00111110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111110
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00111100
scanline 0b01100110
scanline 0b01111110
scanline 0b01100000
scanline 0b00111100
scanline 0b00000000

scanline 0b00011100
scanline 0b00110000
scanline 0b00110000
scanline 0b01111100
scanline 0b00110000
scanline 0b00110000
scanline 0b00110000
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00111110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111110
scanline 0b00000110
scanline 0b00111100

scanline 0b01100000
scanline 0b01100000
scanline 0b01111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00000000

scanline 0b00011000
scanline 0b00000000
scanline 0b00111000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00111100
scanline 0b00000000

scanline 0b00011000
scanline 0b00000000
scanline 0b00111000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b01110000

scanline 0b01100000
scanline 0b01100000
scanline 0b01100110
scanline 0b01101100
scanline 0b01111000
scanline 0b01101100
scanline 0b01100110
scanline 0b00000000

scanline 0b00111000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00111100
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00110110
scanline 0b01111111
scanline 0b01101011
scanline 0b01101011
scanline 0b01100011
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b01111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b01111100
scanline 0b01100110
scanline 0b01100110
scanline 0b01111100
scanline 0b01100000
scanline 0b01100000

scanline 0b00000000
scanline 0b00000000
scanline 0b00111110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111110
scanline 0b00000110
scanline 0b00000111

scanline 0b00000000
scanline 0b00000000
scanline 0b01101100
scanline 0b01110110
scanline 0b01100000
scanline 0b01100000
scanline 0b01100000
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b00111110
scanline 0b01100000
scanline 0b00111100
scanline 0b00000110
scanline 0b01111100
scanline 0b00000000

scanline 0b00110000
scanline 0b00110000
scanline 0b01111100
scanline 0b00110000
scanline 0b00110000
scanline 0b00110000
scanline 0b00011100
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111110
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111100
scanline 0b00011000
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b01100011
scanline 0b01101011
scanline 0b01101011
scanline 0b01111111
scanline 0b00110110
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b01100110
scanline 0b00111100
scanline 0b00011000
scanline 0b00111100
scanline 0b01100110
scanline 0b00000000

scanline 0b00000000
scanline 0b00000000
scanline 0b01100110
scanline 0b01100110
scanline 0b01100110
scanline 0b00111110
scanline 0b00000110
scanline 0b00111100

scanline 0b00000000
scanline 0b00000000
scanline 0b01111110
scanline 0b00001100
scanline 0b00011000
scanline 0b00110000
scanline 0b01111110
scanline 0b00000000

scanline 0b00001100
scanline 0b00011000
scanline 0b00011000
scanline 0b01110000
scanline 0b00011000
scanline 0b00011000
scanline 0b00001100
scanline 0b00000000

scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000
scanline 0b00011000
scanline 0b00011000
scanline 0b00011000
scanline 0b00000000

scanline 0b00110000
scanline 0b00011000
scanline 0b00011000
scanline 0b00001110
scanline 0b00011000
scanline 0b00011000
scanline 0b00110000
scanline 0b00000000

scanline 0b00110001
scanline 0b01101011
scanline 0b01000110
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000
scanline 0b00000000

scanline 0b11111111
scanline 0b11111111
scanline 0b11111111
scanline 0b11111111
scanline 0b11111111
scanline 0b11111111
scanline 0b11111111
scanline 0b11111111
