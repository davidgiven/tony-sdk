import sys

rs = sorted(sys.argv[1:])

print('#include "tony.inc"')
for r in rs:
    print(f"\tresource_reference {r}")
print(f"\t.byte 0xff, 0xff, 0xff")

for i in range(0, len(rs)):
    v = rs[i].upper()
    print(f".global {v}_RSRCID")
    print(f"{v}_RSRCID = {i}")
