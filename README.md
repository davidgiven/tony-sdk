## Flash structure

The first 64kB of flash is special, and must contain three special routines. Each one is referred to by a descriptor structure:

```
+0  16-bit flash address of code (the third byte of the flash address is implicitly zero)
+2  16-bit length of code, in words

0003+4  16-bit flash descriptor of initialisation routine
0009+6  encryption 'key' (leave zeroed); unencoded in flash
000f+4  first four bytes of key; stored normally (leave zeroed)
0013+4  16-bit flash descriptor of video memory write routine
001b+4  16-bit flash descriptor of event handler
001f+2  last two bytes of key; stored normally (leave zeroed)
0021+2  checks of key (leave zeroed)
0023+4  magic string 'tony'
```

## Memory map

```
0000+80     I/O area
  0002      GPIOs? SPI CS line is in bit 3
  0010      SPI r/w register, high byte
  0011      SPI r/w register, low byte
  0013      SPI status register
  0034      something to do with LCD control
  0058+2    DMA source address
  005a+2    DMA dest address
  005c+2    DMA length
0080-07ff   RAM
  0080+80   ZP RAM
    0080+8  input parameters for the flash routines (i0, i1, i2...)
    008d+4  destination buffer for the flash routines (o0, i1, i2...)
    0096    screen width
    0097    screen height
    0099    flash encryption key (just a value which is XORd with each byte...)
    0100+?  input/output parameters for screen routines, plus scratch space?
    017f    top of CPU stack
    018e    chunk stack pointer
    018f+20 chunk stack (enough space for four nested chunk calls)
    01db    shadow copy of write-only I/O register 00
  0300+???? chunk execution buffer
  048d+80   scanline buffer 1
  04dd+80   scanline buffer 2
  052d+80   scanline buffer 3
  057d+80   scanline buffer 4
  05cd+80   scanline buffer 5
  061d+80   scanline buffer 6
  066d+80   scanline buffer 7
  06bd+80   scanline buffer 8
  070d+80   dirty buffer?
6000+1fff   ROM
  6000      SYSCALL: graphics library entrypoint
              opcode in X; parameters in 0100...
  6003      READFLASH: reads four bytes of flash
              i2i1i0: source address
              o0..o3: result data
  6052      CHUNKJUMP: transfer control to a chunk
              i2i1i0: flash address of chunk
              i4i3: length of chunk
  60de      CHUNKCALL: nested call to a chunk
              parameters as for CHUNKJUMP
  6176      RESET: CPU reset handler
8000        LCD w/o command register
c000        LCD r/w data register
ffda        extended interrupt table (actually of its real location in 7fda)
```
