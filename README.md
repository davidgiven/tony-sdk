An SDK for "1.8 game" / "tony" 65C02-based handhelds
====================================================

## What?

This is a rather hacked together and preliminary SDK for the
["1.8 game"](https://bootleggames.fandom.com/wiki/%221.8%22_Handheld_Games)
series of cheap game consoles and mini arcade machines, henceforth referred to
as "tony" (from a magic string in the ROM). These devices are based on the
Sitronix/mCore ST2302U microcontroller, which houses a W65C02S CPU core running
at 8MHz, 2kB of RAM, 8kB of fast ROM containing graphics and sound routines and
a hardware-accelerated 24MHz link to a SPI flash chip for storage.

The display is a 1.8 inch 160x128 TFT screen (with its own driver and
framebuffer) connected as a memory mapped device, using a region of the MCU's
address space meant for external ROM or RAM. Several different driver chips are
supported, including the Sitronix ST7735 and Ilitek ILI9163. Sound is built into
the MCU and consists of 4 channels of which only 3 are used. Each channel can
produce a square wave or play 8-bit PCM samples; there may also be an extra
12-bit PCM channel that goes unused, though this is unconfirmed.

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

  - `decrypter`: analyses a tony flash image and removes the encryption from it.
  The new flash image will work fine; it just won't have any encryption.

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

This is all super preliminary. There is no public datasheet available for the
ST2302U, however the chip seems to a cut-down version of the ST2205U for which a
comprehensive "user's manual" is available, containing detailed register level
documentation. The
[MAME driver for both chips](https://github.com/mamedev/mame/blob/master/src/devices/cpu/m6502/st2205u.cpp)
and [ST2205U implementation in Miuchiz emulator emiu2](https://github.com/coremaze/emiu2/tree/master/src/miuchiz/st2205u)
are also useful as a reference.

It's worth pointing out that the ST2205U is in turn related to the Game King's
ST2204, [documented here](http://blog.kevtris.org/blogfiles/Game%20King%20Inside.txt);
many peripherals are similar, if moved and altered due to running off SPI flash,
while the Game King ran off NAND flash. Some of them however, such as the sound
generator, have significant differences.

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

Sound handling in the OS is currently undocumented. Only 3 of the 4 available
PSG channels seem to be used; the last channel is kept disabled and its timer is
instead used to generate periodic interrupts for housekeeping purposes.

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
0000-007f   I/O area
  0000      PA (GPIO port A data)
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
  0001      PB (GPIO port B data)
              i/o bit 0: B
              output bit 1: LCD backlight via MOSFET
              i/o bit 2: U2 pin 4
              i/o bit 3: U2 pin 3
              i/o bit 4: U2 pin 2
              i/o bit 6: LCD reset line
              bit 7: something sound related?
  0002      PC (GPIO port C data)
              output bit 3: SPI CS line
  0003      PD (GPIO port D data - nonexistent?)
  0004      PE (GPIO port E data - nonexistent?)
  0005      PL (GPIO port L data - nonexistent?)
  0006      PSC (GPIO port C pullup/open drain control)
              in input mode: set high to enable pull resistors
              in output mode: set low to enable open drain mode
  0008      PCA (GPIO port A direction)
              set high for output
  0009      PCB (GPIO port B direction)
              set high for output
  000a      PCC (GPIO port C direction)
              set high for output
              always set to 0b00001101
  000b      PCD (GPIO port D direction - nonexistent?)
  000c      PCE (GPIO port E direction - nonexistent?)
  000d      PCL (GPIO port L direction - nonexistent?)
  000e      PFC (GPIO port C alternate function)
              always set to 0b00000111, bits 0-2 are likely SCK/MISO/MOSI
  000f      PFD (GPIO port D alternate function - nonexistent?)
  0010      SDATAL (SPI data, low/first byte)
  0011      SDATAH (SPI data, high/second byte)
  0012      SCTR (SPI control)
              always set to 0b10000001
  0013      SCKR (SPI clock configuration)
              always set to 0b0000ffff
  0014      SSR (SPI status)
              bit 0: BCERR (RX bit count error)
              bit 1: OERR (RX overrun error)
              bit 2: MDERR (mode fault error)
              bit 4: SBZ (SPI busy)
              bit 5: TXEMP
              bit 6: RXRDY
  0015      SMOD (SPI I2S mode)
  0016      MULL (multiplier operand 1 / result middle)
  0017      MULH (multiplier operand 2 / result high)
              Per the ST2205U datasheet, this is a 16x8->24 multiplier that can
              be used by:
              - writing the low byte of the 16-bit operand to MULH;
              - writing the high byte of the 16-bit operand to MULH;
              - writing the 8-bit operand to MULL;
              - waiting at least 6 cycles;
              - reading the middle byte of the result from MULL and the high 
              byte from MULH. The low byte is discarded.
  0018      unknown
  0020      T0CL (timer 0 counter low)
  0021      T0CH (timer 0 counter high)
  0022      T1CL (timer 1 counter low)
  0023      T1CH (timer 1 counter high)
  0024      T2CL (timer 2 counter low)
  0025      T2CH (timer 2 counter high)
              Timers 0-2 are used as frequency generators for sound channels
              0-2. They fire an interrupt when the respective channel's FIFO
              needs to be refilled.
  0026      T3CL (timer 3 counter low)
  0027      T3CH (timer 3 counter high)
              Timer 3 is used by the OS as an interrupt source only, without
              driving sound channel 3.
  0028      TIEN (timer interrupt enable)
              bits 0-3: allow timers 0-3 to fire interrupts
              bits 4-7: unknown
  0029      PRS (timer prescaler)
              when read: returns current prescaler counter
              when written:
              - bit 5: SENT (clock source, 0=system clock, 1=INTX pin)
              - bit 6: SENA (enable prescaler)
              - bit 7: SRES (set high to reset counter)
  002a      BTEN (base timer interrupt enable)
              each bit controls whether the respective BTSR bit will fire an
              interrupt once set
  002b      BTSR/BTCLR (base timer status / status clear)
              bit 0: set at 2Hz
              bit 1: set at 32Hz
              bit 2: set at 64Hz
              bit 3: set at 128Hz
              bit 4: set at 256Hz
              bit 5: set at 512Hz
              bit 6: set at 2048Hz
              bit 7: set at (8192/BTC)Hz
              each bit stays on until manually cleared by writing 1 to it
  002c      BTC (base timer custom rate divider)
              the divider is 256 when set to 0x00
  002d      T4C (timer 4 counter - nonexistent?)
  002e      RCTR (RTC control - nonexistent?)
  0030      IRRL (bank select for 4000-7fff during IRQ handling - nonexistent?)
  0031      IRRH (CS select for 4000-7fff during IRQ handling - nonexistent?)
  0032      PRRL (bank select for 4000-7fff - nonexistent?)
  0033      PRRH (CS select for 4000-7fff - nonexistent?)
              The ST2302U probably lacks these registers and only supports
              mapping program memory to the internal mask ROM.
  0034      DRRL (bank select for 8000-ffff)
  0035      DRRH (CS select for 8000-ffff)
              The ROM sets this to 3 when accessing the LCD, and 0 otherwise.
              According to the GK documentation, mode 3 will be either /CE 8 or
              3.
  0038      MISC (watchdog control and test)
  0039      SYS (system control)
  003a      unknown, possibly PMCR? (GPIO misc. configuration)
              Does not match the ST2205U's PMCR according to MAME.
  003c      IREQL (interrupt pending register)
              write 0 to clear IENAL
  003d      IREQH (interrupt pending register)
              write 0 to clear IENAH
  003e      IENAL (interrupt enable/pending register)
              bit 0: GPIO E edge interrupt?
              bit 1: timer 0 interrupt
              bit 2: timer 1 interrupt
              bit 3: timer 2 interrupt
              bit 4: timer 3 interrupt
              bit 5: GPIO A edge (button press) interrupt
              bit 6: base timer interrupt
              bit 7: built-in LCD interrupt - nonexistent?
  003f      IENAH (interrupt enable/pending register)
              bit 0: SPI TX interrupt?
              bit 1: SPI RX interrupt?
              bit 2: UART TX interrupt - nonexistent?
              bit 3: UART RX interrupt - nonexistent?
              bit 4: USB interrupt - nonexistent?
              bit 5: reserved
              bit 6: PCM interrupt?
              bit 7: RTC interrupt - nonexistent?
  0040      PSG0A (sound channel 0 data / DPCM add)
  0041      PSG0B (sound channel 0 DPCM subtract)
  0042      PSG1A (sound channel 1 data / DPCM add)
  0043      PSG1B (sound channel 1 DPCM subtract)
  0044      PSG2A (sound channel 2 data / DPCM add)
  0045      PSG2B (sound channel 2 DPCM subtract)
  0046      PSG3A (sound channel 3 data / DPCM add)
  0047      PSG3B (sound channel 3 DPCM subtract)
              in square wave mode:
              - PSGA controls amplitude (acts as a second volume control)
              in PCM mode:
              - writing x to PSGA pushes x to sample FIFO
              in DPCM mode:
              - writing x to PSGA pushes (lastSample+x) to sample FIFO
              - writing x to PSGB pushes (lastSample-x) to sample FIFO
  0048      VOL0 (sound channel 0 volume)
  0049      VOL1 (sound channel 1 volume)
  004a      VOL2 (sound channel 2 volume)
  004b      VOL3 (sound channel 3 volume)
              bits 0-5: volume level (0-63)
              bit 7: if set, volume changes will be deferred to the next sample
  004c      VOLM0 (sound mixer 0 output volume)
              bits 0-5: volume level of channels 0 and 1 after mixing (0-63)
  004d      VOLM1 (sound mixer 1 output volume)
              bits 0-5: volume level of channels 2 and 3 after mixing (0-63)
              bit 6: clipping control? (datasheet is unclear)
  004e      PSGC (sound control)
              bit 0: mute control (1=mute), unconfirmed
              bits 1-2: output mode, always 0b11 (current DAC)
              bit 3: 12-bit PCM channel enable (nonexistent?)
              bits 4-7: channel 0-3 enable
  004f      PSGM (sound channel mode)
              bits 0-1: channel 0 mode
              bits 2-3: channel 1 mode
              bits 4-5: channel 2 mode
              bits 6-7: channel 3 mode
              valid modes: 0b00=PCM, 0b01=square wave, 0b11=DPCM
  0058      DPTRL (DMA source/dest address low)
  0059      DPTRH (DMA source/dest address high)
  005a      DBKRL (DMA transfer flags?)
  005b      DBKRH (DMA transfer flags?)
  005c      DCNTL (DMA length low)
  005d      DCNTH (DMA length high)
  005e      DCTR (DMA control / address select)
              bit 0: if 0, DPTR sets source address; if 1, DPTR sets destination
              bit 1: channel selection, unconfirmed (are there 2 DMA channels?)
  005f      DMOD (more DMA transfer flags)
  006d      unknown
  006e      unknown
  0070      USBCON (USB control - nonexistent?)
  0071      USBIEN (USB interrupt enable - nonexistent?)
  0072      USBIRQ (USB interrupt pending - nonexistent?)
  0073      USBBFS (USB buffer status - nonexistent?)
  0074      EP0CON (USB endpoint 0 control - nonexistent?)
  0075      EP0LEN (USB endpoint 0 length - nonexistent?)
  0076      BKCON (USB bulk endpoint control - nonexistent?)
  0077      BKOLEN (USB bulk endpoint length - nonexistent?)
              The ST2302U likely has no USB functionality, however the ROM does
              zero out USBCON and USBIEN.
  007b      unknown
              There is code in the ROM that writes 0x01 to this register, then
              waits for bit 3 to be set. This does not map to any register
              listed in the ST2205U documentation.
  007c      unknown
  007d      unknown
  007e      unknown
  007f      unknown
              007e and 007f seem to be part of a 16-bit register that feeds into
              a FIFO. Registers 007b-007f are set up in the same function that
              initializes timer 3, so they might be timer-related.

0080-07ff   RAM
  0080+80   ZP RAM
    0080+8  input parameters for the flash routines (i0, i1, i2...)
    008c    display list status
              bit 0: display list non-empty
              bit 2: initialise to background colour
              bit 3: initialise to video
    008d+4  destination buffer for the flash routines (o0, i1, i2...)
    0093    event flags?
              bit 7: button state changed
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
    01db    shadow copy of write-only I/O register PA
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

6000-7fff   "program memory" region, mapped to internal ROM
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

8000-ffd9   "data memory" region, mapped to LCD driver
  8000      LCD w/o command register
  c000      LCD r/w data register

ffda-ffff   extended interrupt table (mirror of its real location in 7fda)
  ffda      RTC interrupt - nonexistent?              (unused by ROM)
  ffdc      PCM interrupt?                            (unused by ROM)
  ffde      reserved                                  (unused by ROM)
  ffe0      USB interrupt - nonexistent?              (unused by ROM)
  ffe2      UART RX interrupt - nonexistent?          (unused by ROM)
  ffe4      UART TX interrupt - nonexistent?          (unused by ROM)
  ffe6      SPI RX interrupt?                         (unused by ROM)
  ffe8      SPI TX interrupt?                         (unused by ROM)
  ffea      built-in LCD interrupt - nonexistent?     (unused by ROM)
  ffec      base timer interrupt                      (sets top bit of 00af)
  ffee      GPIO A edge (button) interrupt            (sets top bit of 0093)
  fff0      timer 3 interrupt                         (used as general interrupt?)
  fff2      timer 2 interrupt                         (used to refill audio FIFO)
  fff4      timer 1 interrupt                         (used to refill audio FIFO)
  fff6      timer 0 interrupt                         (used to refill audio FIFO)
  fff8      GPIO E edge interrupt?                    (used as user interrupt?)
  fffa      6502 NMI vector - reserved                (unused by ROM)
  fffc      reset vector
  fffe      6502 IRQ vector - used by ST2302U for BRK (unused by ROM)
```

## See also

  - [MAME driver for SPI-based "1.8 game" devices](https://github.com/mamedev/mame/blob/master/src/mame/handheld/st2302u_bbl_spi.cpp)

  - [emiu2 Miuchiz emulator (similar hardware, ST2205U + ST7626 LCD)](https://github.com/coremaze/emiu2)

  - [Die shot of the ST2205U](https://siliconprawn.org/map/sitronix/st2205u/miuchizreborn_mz);
  the 65C02 core is clearly visible in the middle
  ([65C02 die for comparison](https://siliconprawn.org/map/rockwell/65c02/bunnie_boli10xir)).
  The ST2205U datasheet makes no mention of the architecture but some of the
  datasheets for other ST22xx parts do, so it's unclear if Sitronix actually
  licensed the core or simply ripped it off (as Nintendo famously did).

LICENSE
=======

The distribution contains parts of the libstb utility library, written by
Sean T Barrett et al. This is public domain where possible and MIT licensed
otherwise. Please see https://github.com/nothings/stb/blob/master/LICENSE
for more information.

