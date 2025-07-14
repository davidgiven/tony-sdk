## Flash structure

The first 64kB of flash is special, and must contain three special routines.
Each one is referred to by a descriptor structure:

```
+0  16-bit flash address of code (the third byte of the flash address is implicitly zero)
+2  16-bit length of code, in words
```

The actual flash header is structured like this:

```
0000+3  24-bit flash address of default sprite table
0003+4  16-bit flash descriptor of initialisation routine
0007+2  16-bit flash address of default font
          1bpp, 8x16 wide array of scanlines (i.e. standard font format)
          starting with character 0x20
0009+6  encryption 'key' (leave zeroed); unencoded in flash
000f+4  first four bytes of key; stored normally (leave zeroed)
0013+4  16-bit flash descriptor of video memory write routine
0019+2  ??? stored in 01a3
001b+4  16-bit flash descriptor of event handler
001f+2  last two bytes of key; stored normally (leave zeroed)
0021+2  checksum of key (leave zeroed)
0023+4  magic string 'tony'
```

Sprite tables are an array of 24-bit flash addresses. Each entry points at a
structure:

```
+0  sprite width
+1  flags
+2  sprite height
+   compressed data
```

I don't know how the compressed data works yet.

## Memory map

```
0000+80     I/O area
  0000      GPIOs
              Seem to be multiple peripherals here; you need to configure
              something before the buttons are readable.
              input bit 1: UP
              input bit 2: LEFT
              input bit 3: RIGHT
              input bit 4: DOWN
              input bit 5: START
              input bit 6: VOLUME
              input bit 7: A
  0001      GPIOs
              input bit 0: B
              output bit 1: LCD backlight
  0002      GPIOs
              output bit 3: SPI CS line
  0008      GPDIR for GPIO0
  0009      GPDIR for GPIO1
  000a      GPDIR for GPIO2
  0010      SPI r/w register, high byte
  0011      SPI r/w register, low byte
  0013      SPI status register
  0035      something to do with LCD control
  0058+2    DMA source address
  005a+2    DMA dest address
  005c+2    DMA length
0080-07ff   RAM
  0080+80   ZP RAM
    0080+8  input parameters for the flash routines (i0, i1, i2...)
    008c    display list status
              bit 0: display list non-empty
              bit 2: initialise to background colour
              bit 3: initialise to video
    008d+4  destination buffer for the flash routines (o0, i1, i2...)
    0094+3  24-bit flash address of current sprite table
    0097    screen width
    0098    screen height
    0099    flash encryption key (just a value which is XORd with each byte...)
    0100+?  input/output parameters for screen routines, plus scratch space?
    017f    top of CPU stack
    0180    shadow copy of write-only I/O register 01
    018e    chunk stack pointer
    018f+20 chunk stack (enough space for four nested chunk calls)
    01db    shadow copy of write-only I/O register 00
  0300+???? chunk execution buffer
  0489+3    24-bit flash address of video playback table
  048d+80   scanline buffer 1
  04dd+80   display list item X ordinate
  052d+80   scanline buffer 3
  057d+80   display list item Y ordinate
  05cd+80   display list item flash address byte 0
  061d+80   display list item flash address byte 1
  066d+80   display list item flash address byte 2
  06bd+80   scanline buffer 8
  070d+80   display list item types
  075d      display list bottom scanline
  075e      display list top scanline
  075f      display list background colour
  0760      pixel data buffer
6000+1fff   ROM
  6000      SYSCALL: graphics library entrypoint
              opcode in X; parameters in 0100...
              0x00: draw sprite from current sprite table (?) immediate
                p0, p1: (X, Y) position
                p3p2: sprite index
              0x04: fill rectangle immediate
                p0, p1: (X, Y) position
                p2, p3: (W, H) size
                p4: pixel value to fill with
              0x06: get sprite info form current sprite table
                p1p0: sprite index
                returns:
                  i2i1i0: flash address of sprite data
                  i5, i6: sprite flags
              0x08: add sprite to display list
                p0, p1: (X, Y) position
                p3p2: sprite index
                p4: flags
                p5: more flags?
              0x0a: clear display list and then add sprite
                as for 0x08
              0x0c: reset display list to solid colour
                p0: top scanline to draw
                p1: bottom scanline to draw
                p2: background colour pixel value
              0x0e: reset display list to video
                p0: top scanline to draw
                p1: bottom scanline to draw
                p3p2: sprite index 
              0x24: add character to display list
                Warning: uses memory all the way down to 0x3da, meaning you can
                only use this from very short chunks!
                p0, p1: (X, Y) position
                p2: ASCII character
                p3: foreground colour
                p4: background colour
              0x26: draw character immediate
                p0, p1: (X, Y) position
                p2: ASCII character
                p3: foreground colour
                p4: background colour
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
ffda        extended interrupt table (actually a mirror of its real location in 7fda)
```

LICENSE
=======

The distribution contains parts of the libstb utility library, written by
Sean T Barrett et al. This is public domain where possible and MIT licensed
otherwise. Please see https://github.com/nothings/stb/blob/master/LICENSE
for more information.

