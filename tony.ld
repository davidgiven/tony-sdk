MEMORY {
    ram (rw) : ORIGIN = 0x300, LENGTH = 0x10000
    image (rw) : ORIGIN = 0, LENGTH = 0x1000000
}

SECTIONS {
    GPIO0 = 0x00;
    GPIO1 = 0x01;
    GPIO2 = 0x02;
    GPDIR0 = 0x08;
    GPDIR1 = 0x09;
    GPDIR2 = 0x0a;
    LCD_CONTROL = 0x35;

    i0 = 0x80;
    i1 = 0x81;
    i2 = 0x82;
    i3 = 0x83;
    i4 = 0x84;
    i5 = 0x85;
    i6 = 0x86;

    o0 = 0x8d;
    o1 = 0x8e;
    o2 = 0x8f;
    o3 = 0x90;

    p0 = 0x100;
    p1 = 0x101;
    p2 = 0x102;
    p3 = 0x103;
    p4 = 0x104;
    p5 = 0x105;
    p6 = 0x106;
    p7 = 0x107;

    screen_width = 0x97;
    screen_height = 0x98;
    flash_encryption_key = 0x99;
    shadow_00 = 0x1db;
    shadow_01 = 0x180;

    SYSCALL = 0x6000;
    READFLASH = 0x6003;
    CHUNKJUMP = 0x6052;
    CHUNKCALL = 0x60de;
    
    LCD_CMD = 0x8000;
    LCD_DATA = 0xc000;

    header : {
        . = 0x00;
        BYTE(LOADADDR(resourcetable))
        BYTE(LOADADDR(resourcetable)>>8)
        BYTE(LOADADDR(resourcetable)>>16)
        . = 0x03;
        SHORT(LOADADDR(_init));
        SHORT(SIZEOF(_init));
        ASSERT(LOADADDR(_init) < 0x10000, "_init chunk not in first 64kB of flash");
        . = 0x07;
        SHORT(LOADADDR(_font));
        ASSERT(LOADADDR(_font) < 0x10000, "_font chunk not in first 64kB of flash");
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
