An SDK for the tony games console
=================================

## What?

This is a rather hacked together and preliminary SDK for the WDT65c02-based tony
games console (which you are unlikely to have heard of). The tony has 2kB of
RAM, 8kB of fast ROM containing graphics and sound routines. It runs at 8MHz and
has a hardware-accelerated 24MHz link to a SPI flash chip for storage.

The display is handled via a 160x128 ST7735 screen, with another fast link, and
the sound is done on-chip and appears to have 3(?) channels.

I did a video on reverse engineering this!

[![Video from my Youtube channel](https://img.youtube.com/vi/jJ0XmZvR4bU/0.jpg)](https://www.youtube.com/watch?v=jJ0XmZvR4bU)

## How?

You will need the `llvm-mos` toolchain. There's no C here, but I am using the
`llvm-mos` assembler and linker for putting together the ROMs.  Once you have
all the poorly documented dependencies, doing `make` will built the tools and a
demo ROM. You can then just flash this.

## Tooling

There are a number of tools in the `tools` directory, which will get built into
binaries in `bin`.

  - `dechunker`: analyses a tony flash image and attempts to find all the chunks
  therein. It does this by looking for the fixed code sequences which both the
  original flash image and SDK images use for calling chunks. This means it'll
  miss any chunks which are called in any other way. It will also generate a
  `.dot` file containing the call graph, as it knows it, which can by compiled
  with `dotty` into an SVG file.

  - `deresourcer`: analyses a tony flash image and extracts all the resources in the
  default resource table. Currently it only supports sprite resources, which get
  emitted as PNGs. Any other resource type will produce a garbage image.

  - `extractpalette`: analyses a tony mask ROM and extracts the 8-bit palette as
  a C include file.

  - `spritify`: converts an image into a tony sprite resource. The build system
  uses this when compiling resources. Each pixel in the source image will be
  looked up in the palette and the nearest colour found.

## Device documentation

This is all super preliminary.

### Principles

The built-in OS is weird. There's only 2kB of RAM, and code has to execute out
of RAM, so the OS will copy data into RAM from flash and execute it there on
demand. This means that your program has to be divided into chunks, each of
which executes at 0x0300. 

There are OS calls to jump to a different chunk (CHUNKJUMP) and to call a
different chunk (CHUNKCALL). The chunk stack is four levels deep. Parameters get
passed around in zero page scratch space, a special OS parameter area, or in
application memory (depending on what you're doing).

The application gets 289 bytes of persistent RAM from 0x1df to 0x2ff; it also
gets 80 bytes of zero page from 0xb0 to 0xff. 

### Graphics

There's not enough RAM for a framebuffer so instead the OS uses a display list
system. You can have up to 80 sprites on the display list, and then this is
computed and rendered out to the screen for every scanline. Sprite data is
fetched directly from flash on demand. It's much faster than it sounds. The sprites
are RLE encoded in flash for, I think, performance reasons rather than size.

Internally it uses 8bpp graphics with a fixed palette, even though the ST7735
supports 16-bit graphics. Colour index 0xff represents transparency. This means
you can't have true white in a sprite.

### Sound

Unknown. Some kind of FM synthesis polyphonic thing.

### Flash structure

The first 64kB of flash is special, and must contain three special routines.
Each one is referred to by a descriptor structure:

```
+0  16-bit flash address of code (the third byte of the flash address is implicitly zero)
+2  16-bit length of code, in words
```

The actual flash header is structured like this:

```
0000+3  24-bit flash address of default resource table
0003+4  16-bit flash descriptor of initialisation routine
0007+2  16-bit flash address of default font
          1bpp, 8x16 wide array of scanlines (i.e. standard font format)
          starting with character 0x20
0009+6  encryption 'key' (leave zeroed); unencoded in flash
          This produces a simple XOR value via the formula:
            ((b0 - b1 | b2) ^ b3) + b4 & b5
          But given it's one byte long, never changes, and there's a magic fixed
          string at 0023, it's easier to get it from there...
000f+4  first four bytes of key; stored normally (leave zeroed)
0013+4  16-bit flash descriptor of video memory write routine
0019+2  ??? stored in 01a3
001b+4  16-bit flash descriptor of event handler
001f+2  last two bytes of key; stored normally (leave zeroed)
0021+2  checksum of key (leave zeroed)
0023+4  magic string 'tony'
```

Resource tables are an array of 24-bit flash addresses. Each entry points at a
structure of various different kinds. So far I've figured out sprites:

```
+0  sprite width
+1  flags
+2  sprite height
+   scanlines
```

See `tools/spritify.cc` for how the compressed data works.

The ROM seems to support two ways of accessing the flash, both via SPI,
controlled via bit 6 of 0x009a. Primary SPI (bit enabled) is the normal flash
chip. Secondary SPI (bit disabled) works identically but uses a different CS
pin. I don't know what this refers to yet.

### Memory map

```
0000+80     I/O area
  0000      GPIOs
              Seem to be multiple peripherals here; you need to configure
              something before the buttons are readable.
              output bit 0: secondary SPI CS enable?
              i/o bit 1: UP
              i/o bit 2: LEFT
              i/o bit 3: RIGHT
              i/o bit 4: DOWN
              i/o bit 5: START
              i/o bit 6: VOLUME
              i/o bit 7: A
  0001      GPIOs
              i/o bit 0: B
              output bit 1: LCD backlight via MOSFET
              i/o bit 2: U2 pin 4
              i/o bit 3: U2 pin 3
              i/o bit 4: U2 pin 2
              i/o bit 6: LCD reset line
  0002      GPIOs
              output bit 3: SPI CS line
  0008      GPDIR for GPIO0
              set high for output
  0009      GPDIR for GPIO1
              set high for output
  000a      GPDIR for GPIO2
              set high for output
              always set to 0b00001101
  0010      SPI r/w register, high byte
  0011      SPI r/w register, low byte
  0013      SPI status register
  0035      something to do with LCD control
  0058+2    DMA source/dest address
  005a+2    DMA transfer flags?
  005c+2    DMA length
  005e      DMA address select; if 0, 0058 sets source address; if 1, 0058 sets destination
  005f      more DMA transfer flags
0080-07ff   RAM
  0080+80   ZP RAM
    0080+8  input parameters for the flash routines (i0, i1, i2...)
    008c    display list status
              bit 0: display list non-empty
              bit 2: initialise to background colour
              bit 3: initialise to video
    008d+4  destination buffer for the flash routines (o0, i1, i2...)
    0093    event flags?
    0094+3  24-bit flash address of current sprite table
    0097    screen width
    0098    screen height
    0099    flash encryption key (just a value which is XORd with each byte...)
    009a    flags
               bit 6: enables primary SPI vs secondary SPI (which is unknown)
    00a3    flags used by the sound system
    b0-ff   application storage
  0100-01de OS storage
    0100+?  input/output parameters for screen routines, plus scratch space?
    017f    top of CPU stack
    0180    shadow copy of write-only I/O register 01
    018e    chunk stack pointer
    018f+20 chunk stack (enough space for four nested chunk calls)
    01a5+9*3 sound channel data
      for each channel:
        +0..2 flash address of audio data
        +4..7 data currently being played back
    01c0    user interrupt flag
              bit 7: clear to enable user interrupts
    01db    shadow copy of write-only I/O register 00
  01df-02ff application storage
    01df    user interrupt entrypoint (if enabled)
  0300+???? chunk execution buffer
  0489+3    24-bit flash address of video playback table
  048d+80   display list item draw flags (p5 parameter)
  04dd+80   display list item X ordinate
  052d+80   display list item draw flags (p4 parameter)
  057d+80   display list item Y ordinate
  05cd+80   display list item flash address byte 0
  061d+80   display list item flash address byte 1
  066d+80   display list item flash address byte 2
  06bd+80   display list item draw flags (flag byte from resource)
  070d+80   display list item types
  075d      display list bottom scanline
  075e      display list top scanline
  075f      display list background colour
  0760-7ff  pixel data buffer
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
                p5: more flags
                  0x00 draws a silhouette
                  0xff draws a normal sprite
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
              This takes about 50µs to execute and reads four bytes.
              i2i1i0: source address
              o0..o3: result data
  6052      CHUNKJUMP: transfer control to a chunk
              Downloading a chunk from flash happens at about 5µs/byte.
              i2i1i0: flash address of chunk
              i4i3: length of chunk
  60de      CHUNKCALL: nested call to a chunk
              parameters as for CHUNKJUMP
  6176      RESET: CPU reset handler
8000        LCD w/o command register
c000        LCD r/w data register
ffda        extended interrupt table (actually a mirror of its real location in 7fda)
  ffee      sets the top bit of 93 --- vsync?
  fff0      general interrupt vector
  fff2,4,6  audio interrupts?
  fff8      user interrupt vector
  fffa      6502 NMI vector (just goes to an RTI)
  fffc      reset vector
  fffe      6502 IRQ vector (just goes to an RTI)
```

LICENSE
=======

The distribution contains parts of the libstb utility library, written by
Sean T Barrett et al. This is public domain where possible and MIT licensed
otherwise. Please see https://github.com/nothings/stb/blob/master/LICENSE
for more information.

