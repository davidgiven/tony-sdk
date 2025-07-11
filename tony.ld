MEMORY {
    ram (rw) : ORIGIN = 0x300, LENGTH = 0x200
    image (rw) : ORIGIN = 0, LENGTH = 0x10000
}

SECTIONS {
    i0 = 0x80;
    i1 = 0x81;
    i2 = 0x82;
    i3 = 0x83;
    i4 = 0x84;

    screen_width = 0x97;
    screen_height = 0x98;

    SYSCALL = 0x6000;
    READFLASH = 0x6003;
    CHUNKJUMP = 0x6052;
    CHUNKCALL = 0x60de;
    
    LCD_CMD = 0x8000;
    LCD_DATA = 0xc000;

    header : {
        . = 3;
        SHORT(LOADADDR(_init));
        SHORT(SIZEOF(_init));
        ASSERT(LOADADDR(_init) < 0x10000, "_init chunk not in first 64kB of flash");
        . = 0x13;
        SHORT(LOADADDR(_vwrite))
        SHORT(SIZEOF(_vwrite))
        ASSERT(LOADADDR(_vwrite) < 0x10000, "_vwrite chunk not in first 64kB of flash");
        . = 0x1b;
        SHORT(LOADADDR(_main));
        SHORT(SIZEOF(_main));
        ASSERT(LOADADDR(_main) < 0x10000, "_main chunk not in first 64kB of flash");
        . = 0x23;
        BYTE(116);
        BYTE(111);
        BYTE(110);
        BYTE(121);
    } >image

    n = LOADADDR(header) + SIZEOF(header);
    INCLUDE generated-chunks.ld
}

OUTPUT_FORMAT{
    TRIM(image)
}
