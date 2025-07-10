MEMORY {
    ram (rw) : ORIGIN = 0x300, LENGTH = 0x18d
    image (rw) : ORIGIN = 0, LENGTH = 0x10000
}

SECTIONS {
    header : {
        SHORT(0x1234);
        SHORT(init_entry);
        SHORT(main_entry);
    } >image

    n = LOADADDR(header) + SIZEOF(header);
    .init 0x0300 : AT(n) { */init.o(.text) }
    n = n + SIZEOF(.init);
    .main 0x0300 : AT(n) { */main.o(.text) }
}

OUTPUT_FORMAT{
    TRIM(image)
}
