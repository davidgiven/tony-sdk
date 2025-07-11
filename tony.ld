MEMORY {
    ram (rw) : ORIGIN = 0x300, LENGTH = 0x18d
    image (rw) : ORIGIN = 0, LENGTH = 0x10000
}

SECTIONS {
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
