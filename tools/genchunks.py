import sys
from os.path import *

i=1
while i < len(sys.argv):
    arg = sys.argv[i]
    if not arg.endswith(":"):
        raise Exception(f"malformed argument '{arg}'")

    chunkname = arg[0:-1]
    i += 1

    files = []
    while (i < len(sys.argv)) and not sys.argv[i].endswith(":"):
        files += [sys.argv[i]]
        i += 1

    print(f"{chunkname} 0x0300 : AT(n) {{")
    if chunkname.startswith("_"):
        print("KEEP(")
    for f in files:
        base, ext = splitext(f)
        print(f"*/{basename(base)}.o(.text .rodata .data)")
    if chunkname.startswith("_"):
        print(")")
    print(f"}}")
    print(f"{chunkname}_chunk_start = LOADADDR({chunkname});")
    print(f"{chunkname}_chunk_len = (SIZEOF({chunkname})+1)/2;")
    print(f"n = n + SIZEOF({chunkname});")
