import sys

BASE = 0x0300

data = [0] * 0x10000
is_output = [False] * 0x10000
is_code = [False] * 0x10000
is_label = [False] * 0x10000
leads = {BASE}

LABELS = {
    0x6000: "SYSCALL",
    0x6003: "READFLASH",
    0x6052: "CHUNKJUMP",
    0x60DE: "CHUNKCALL",
    0x8000: "LCD_CMD",
    0xc000: "LCD_DATA",
    0x80: "i0",
    0x81: "i1",
    0x82: "i2",
    0x83: "i3",
    0x84: "i4",
    0x85: "i5",
    0x8D: "o0",
    0x8E: "o1",
    0x8F: "o2",
    0x90: "o3",
    0x100: "p0",
    0x101: "p1",
    0x102: "p2",
    0x103: "p3",
    0x104: "p4",
    0x105: "p5",
    0x106: "p6",
    0x99: "flash_encryption_key",
    0x180: "shadow_01",
    0x18E: "chunksp",
    0x18F: "chunkstack",
}

with open(sys.argv[1], mode="rb") as f:
    pc = BASE
    for b in f.read():
        data[pc] = b
        is_output[pc] = True
        pc += 1


def sign_extend(value, bits):
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)


def readword(pos):
    return data[pos] + (data[pos + 1] << 8)


def readrel(pc):
    return sign_extend(data[pc + 1], 8) + pc + 2


def render_abs_label(t):
    if t in LABELS:
        return LABELS[t]
    if is_output[t]:
        return "L%04x" % t
    else:
        return "0x%04x" % t


def render_zp_label(t):
    if t in LABELS:
        return LABELS[t]
    if is_output[t]:
        return "L%02x" % t
    else:
        return "0x%02x" % t


def render_bytes(pc, len):
    return " ".join([("%02x" % b) for b in data[pc : pc + len]])


class Opcode:
    len = 1

    def __init__(self, name, terminating=False):
        self.name = name.lower()
        self.terminating = terminating

    def mark(self, pc):
        if not self.terminating:
            leads.add(pc + self.len)

    def render(self, pc):
        pass


class SimpleOp(Opcode):
    def render(self, pc):
        return self.name


class AbsOp(Opcode):
    len = 3

    def mark(self, pc):
        super().mark(pc)
        d = readword(pc + 1)
        is_label[d] = True

    def render(self, pc):
        return "%s %s" % (self.name, render_abs_label(readword(pc + 1)))


class AbsXOp(AbsOp):
    len = 3

    def render(self, pc):
        return "%s %s, x" % (self.name, render_abs_label(readword(pc + 1)))


class AbsYOp(AbsOp):
    len = 3

    def render(self, pc):
        return "%s %s, y" % (self.name, render_abs_label(readword(pc + 1)))


class AbsIndXOp(AbsOp):
    len = 3

    def render(self, pc):
        return "%s (%s, x)" % (self.name, render_abs_label(data[pc + 1]))


class ZpOp(Opcode):
    len = 2

    def mark(self, pc):
        super().mark(pc)
        d = data[pc + 1]
        is_label[d] = True

    def render(self, pc):
        return "%s %s" % (self.name, render_zp_label(data[pc + 1]))


class ZpXOp(ZpOp):
    len = 2

    def render(self, pc):
        return "%s %s, x" % (self.name, render_zp_label(data[pc + 1]))


class ZpYOp(ZpOp):
    len = 2

    def render(self, pc):
        return "%s %s, y" % (self.name, render_zp_label(data[pc + 1]))


class ZpIndOp(ZpOp):
    len = 2

    def render(self, pc):
        return "%s (%s)" % (self.name, render_zp_label(data[pc + 1]))


class ZpIndXOp(ZpOp):
    len = 2

    def render(self, pc):
        return "%s (%s, x)" % (self.name, render_zp_label(data[pc + 1]))


class ZpIndYOp(ZpOp):
    len = 2

    def render(self, pc):
        return "%s (%s),y" % (self.name, render_zp_label(data[pc + 1]))


class ZpRelOp(Opcode):
    len = 3

    def mark(self, pc):
        super().mark(pc)
        d = data[pc + 1]
        is_label[d] = True

        t = readrel(pc + 1)
        is_label[t] = True
        leads.add(t)

    def render(self, pc):
        z = data[pc + 1]
        t = readrel(pc + 1)
        return "%s %s, %s" % (
            self.name,
            render_zp_label(z),
            render_abs_label(t),
        )


class ImmOp(Opcode):
    len = 2

    def render(self, pc):
        return "%s #0x%02x" % (self.name, data[pc + 1])


class AccOp(Opcode):
    len = 1

    def render(self, pc):
        return "%s a" % self.name


class RelOp(Opcode):
    len = 2

    def mark(self, pc):
        super().mark(pc)
        t = readrel(pc)
        is_label[t] = True
        leads.add(t)

    def render(self, pc):
        t = readrel(pc)
        return "%s %s" % (self.name, render_abs_label(t))


class JmpOp(Opcode):
    len = 3

    def mark(self, pc):
        super().mark(pc)
        t = readword(pc + 1)
        is_label[t] = True
        leads.add(t)

    def render(self, pc):
        return "%s %s" % (self.name, render_abs_label(readword(pc + 1)))


class IndJmpOp(Opcode):
    len = 3

    def mark(self, pc):
        super().mark(pc)
        t = readword(pc + 1)
        is_label[t] = True

    def render(self, pc):
        return "%s (%s)" % (self.name, render_abs_label(readword(pc + 1)))


OPCODES = {
    0x00: SimpleOp("BRK", terminating=True),
    0x01: AbsXOp("ORA"),
    0x05: ZpOp("ORA"),
    0x04: ZpOp("TSB"),
    0x06: ZpOp("ASL"),
    0x07: ZpOp("RMB0"),
    0x08: SimpleOp("PHP"),
    0x09: ImmOp("ORA"),
    0x0A: AccOp("ASL"),
    0x0C: AbsOp("TSB"),
    0x0D: AbsOp("ORA"),
    0x0E: AbsOp("ASL"),
    0x0F: ZpRelOp("BBR0"),
    #
    0x10: RelOp("BPL"),
    0x11: ZpIndYOp("ORA"),
    0x12: ZpIndOp("ORA"),
    0x14: ZpOp("TRB"),
    0x15: ZpXOp("ORA"),
    0x16: ZpXOp("ASL"),
    0x17: ZpOp("RMB1"),
    0x18: SimpleOp("CLC"),
    0x19: AbsYOp("ORA"),
    0x1A: AccOp("INC"),
    0x1C: AbsOp("TRB"),
    0x1D: AbsXOp("ORA"),
    0x1E: AbsXOp("ASL"),
    0x1F: ZpRelOp("BBR1"),
    #
    0x20: JmpOp("JSR"),
    0x21: AbsXOp("AND"),
    0x24: ZpOp("BIT"),
    0x25: ZpOp("AND"),
    0x26: ZpOp("ROL"),
    0x27: ZpOp("RMB2"),
    0x28: SimpleOp("PLP"),
    0x29: ImmOp("AND"),
    0x2A: AccOp("ROL"),
    0x2C: AbsOp("BIT"),
    0x2D: AbsOp("AND"),
    0x2E: AbsOp("ROL"),
    0x2F: ZpRelOp("BBR2"),
    #
    0x30: RelOp("BMI"),
    0x31: ZpIndYOp("AND"),
    0x32: ZpIndOp("AND"),
    0x34: ZpXOp("BIT"),
    0x35: ZpXOp("AND"),
    0x36: ZpXOp("ROL"),
    0x37: ZpOp("RMB3"),
    0x38: SimpleOp("SEC"),
    0x39: AbsYOp("AND"),
    0x3A: AccOp("DEC"),
    0x3C: AbsXOp("BIT"),
    0x3D: AbsXOp("AND"),
    0x3E: AbsXOp("ROL"),
    0x3F: ZpRelOp("BBR3"),
    #
    0x40: SimpleOp("RTI", terminating=True),
    0x41: ZpIndXOp("EOR"),
    0x45: ZpOp("EOR"),
    0x46: ZpOp("LSR"),
    0x47: ZpOp("RMB4"),
    0x48: SimpleOp("PHA"),
    0x49: ImmOp("EOR"),
    0x4A: AccOp("LSR"),
    0x4C: JmpOp("JMP", terminating=True),
    0x4D: AbsOp("EOR"),
    0x4E: AbsOp("LSR"),
    0x4F: ZpRelOp("BBR4"),
    #
    0x50: RelOp("BVC"),
    0x51: ZpIndYOp("EOR"),
    0x52: ZpIndOp("EOR"),
    0x55: ZpXOp("EOR"),
    0x56: ZpXOp("LSR"),
    0x57: ZpOp("RMB5"),
    0x58: SimpleOp("CLI"),
    0x59: AbsYOp("EOR"),
    0x5A: SimpleOp("PHY"),
    0x5D: AbsXOp("EOR"),
    0x5E: AbsXOp("LSR"),
    0x5F: ZpRelOp("BBR5"),
    #
    0x60: SimpleOp("RTS", terminating=True),
    0x61: ZpIndXOp("ADC"),
    0x64: ZpOp("STZ"),
    0x65: ZpOp("ADC"),
    0x66: ZpOp("ROR"),
    0x67: ZpOp("RMB6"),
    0x68: SimpleOp("PLA"),
    0x69: ImmOp("ADC"),
    0x6A: AccOp("ROR"),
    0x6C: IndJmpOp("JMP", terminating=True),
    0x6D: AbsOp("ADC"),
    0x6E: AbsOp("ROR"),
    0x6F: ZpRelOp("BBR6"),
    #
    0x70: RelOp("BVS"),
    0x71: ZpIndYOp("ADC"),
    0x72: ZpIndOp("ADC"),
    0x74: ZpXOp("STZ"),
    0x75: ZpXOp("ADC"),
    0x76: ZpXOp("ROR"),
    0x77: ZpOp("RMB7"),
    0x78: SimpleOp("SEI"),
    0x79: AbsYOp("ADC"),
    0x7A: SimpleOp("PLY"),
    0x7C: AbsIndXOp("JMP"),
    0x7D: AbsXOp("ADC"),
    0x7E: AbsXOp("ROR"),
    0x7F: ZpRelOp("BBR7"),
    #
    0x80: RelOp("BRA"),
    0x81: ZpIndXOp("STA"),
    0x84: ZpOp("STY"),
    0x85: ZpOp("STA"),
    0x86: ZpOp("STX"),
    0x87: ZpOp("SMB0"),
    0x88: SimpleOp("DEY"),
    0x89: ImmOp("BIT"),
    0x8A: SimpleOp("TXA"),
    0x8C: AbsOp("STY"),
    0x8D: AbsOp("STA"),
    0x8E: AbsOp("STX"),
    0x8F: ZpRelOp("BBS0"),
    #
    0x90: RelOp("BCC"),
    0x91: ZpIndYOp("STA"),
    0x92: ZpIndOp("STA"),
    0x94: ZpXOp("STY"),
    0x95: ZpXOp("STA"),
    0x96: ZpXOp("STX"),
    0x97: ZpOp("SMB1"),
    0x98: SimpleOp("TYA"),
    0x99: AbsYOp("STA"),
    0x9A: SimpleOp("TXS"),
    0x9C: AbsOp("STZ"),
    0x9D: AbsXOp("STA"),
    0x9E: AbsXOp("STZ"),
    0x9F: ZpRelOp("BBS1"),
    #
    0xA0: ImmOp("LDY"),
    0xA1: ZpIndXOp("LDA"),
    0xA2: ImmOp("LDX"),
    0xA4: ZpOp("LDY"),
    0xA5: ZpOp("LDA"),
    0xA6: ZpOp("LDX"),
    0xA7: ZpOp("SMB2"),
    0xA8: SimpleOp("TAY"),
    0xA9: ImmOp("LDA"),
    0xAA: SimpleOp("TAX"),
    0xAC: AbsOp("LDY"),
    0xAD: AbsOp("LDA"),
    0xAE: AbsOp("LDX"),
    0xAF: ZpRelOp("BBS2"),
    #
    0xB0: RelOp("BCS"),
    0xB1: ZpIndYOp("LDA"),
    0xB2: ZpIndOp("LDA"),
    0xB4: ZpXOp("LDY"),
    0xB5: ZpXOp("LDA"),
    0xB6: ZpXOp("LDX"),
    0xB7: ZpOp("SMB3"),
    0xB8: SimpleOp("CLV"),
    0xB9: AbsYOp("LDA"),
    0xBA: SimpleOp("TSX"),
    0xBC: AbsXOp("LDY"),
    0xBD: AbsXOp("LDA"),
    0xBE: AbsXOp("LDX"),
    0xBF: ZpRelOp("BBS3"),
    #
    0xC0: ImmOp("CPY"),
    0xC1: ZpIndXOp("CMP"),
    0xC4: ZpOp("CPY"),
    0xC5: ZpOp("CMP"),
    0xC6: ZpOp("DEC"),
    0xC7: ZpOp("SMB4"),
    0xC8: SimpleOp("INY"),
    0xC9: ImmOp("CMP"),
    0xCA: SimpleOp("DEX"),
    0xCB: SimpleOp("WAI"),
    0xCC: AbsOp("CPY"),
    0xCD: AbsOp("CMP"),
    0xCE: AbsOp("DEC"),
    0xCF: ZpRelOp("BBS4"),
    #
    0xD0: RelOp("BNE"),
    0xD1: ZpIndYOp("CMP"),
    0xD2: ZpIndOp("CMP"),
    0xD5: ZpXOp("CMP"),
    0xD6: ZpXOp("DEC"),
    0xD7: ZpOp("SMB5"),
    0xD8: SimpleOp("CLD"),
    0xD9: AbsYOp("CMP"),
    0xDA: SimpleOp("PHX"),
    0xDD: AbsXOp("CMP"),
    0xDE: AbsXOp("DEC"),
    0xDF: ZpRelOp("BBS5"),
    #
    0xE0: ImmOp("CPX"),
    0xE1: ZpIndXOp("SBC"),
    0xE4: ZpOp("CPX"),
    0xE5: ZpOp("SBC"),
    0xE6: ZpOp("INC"),
    0xE7: ZpOp("SMB6"),
    0xE8: SimpleOp("INX"),
    0xE9: ImmOp("SBC"),
    0xEA: SimpleOp("NOP"),
    0xEC: AbsOp("CPX"),
    0xED: AbsOp("SBC"),
    0xEE: AbsOp("INC"),
    0xEF: ZpRelOp("BBS6"),
    #
    0xF0: RelOp("BEQ"),
    0xF1: ZpIndYOp("SBC"),
    0xF2: ZpIndOp("SBC"),
    0xF5: ZpXOp("SBC"),
    0xF6: ZpXOp("INC"),
    0xF7: ZpOp("SMB7"),
    0xF8: SimpleOp("SED"),
    0xF9: AbsYOp("SBC"),
    0xFA: SimpleOp("PLX"),
    0xFD: AbsXOp("SBC"),
    0xFE: AbsXOp("INC"),
    0xFF: ZpRelOp("BBS7"),
}


def is_chunkjump(pc):
    return (
        (data[pc + 0] == 0xA9)
        and (data[pc + 2] == 0x85)
        and (data[pc + 3] == 0x80)
        and (data[pc + 4] == 0xA9)
        and (data[pc + 6] == 0x85)
        and (data[pc + 7] == 0x81)
        and (data[pc + 8] == 0xA9)
        and (data[pc + 10] == 0x85)
        and (data[pc + 11] == 0x82)
        and (data[pc + 12] == 0xA9)
        and (data[pc + 14] == 0x85)
        and (data[pc + 15] == 0x83)
        and (data[pc + 16] == 0xA9)
        and (data[pc + 18] == 0x85)
        and (data[pc + 19] == 0x84)
        and (data[pc + 20] == 0x4C)
        and (data[pc + 21] == 0x52)
        and (data[pc + 22] == 0x60)
    )

def is_chunkcall(pc):
    return (
        (data[pc + 0] == 0xA9)
        and (data[pc + 2] == 0x85)
        and (data[pc + 3] == 0x80)
        and (data[pc + 4] == 0xA9)
        and (data[pc + 6] == 0x85)
        and (data[pc + 7] == 0x81)
        and (data[pc + 8] == 0xA9)
        and (data[pc + 10] == 0x85)
        and (data[pc + 11] == 0x82)
        and (data[pc + 12] == 0xA9)
        and (data[pc + 14] == 0x85)
        and (data[pc + 15] == 0x83)
        and (data[pc + 16] == 0xA9)
        and (data[pc + 18] == 0x85)
        and (data[pc + 19] == 0x84)
        and (data[pc + 20] == 0x20)
        and (data[pc + 21] == 0xde)
        and (data[pc + 22] == 0x60)
    )

def render_chunkjump(name, pc):
    return f"{name} c{data[pc+9]:02x}{data[pc+5]:02x}{data[pc+1]:02x}"

while leads:
    pc = leads.pop()
    if is_code[pc] or not is_output[pc]:
        continue

    if is_chunkjump(pc):
        is_code[pc] = True
    elif is_chunkcall(pc):
        is_code[pc] = True
        leads.add(pc+23)
    else:
        b = data[pc]
        if b in OPCODES:
            is_code[pc] = True
            op = OPCODES[b]
            op.mark(pc)
        else:
            pc += 1

print('#include "tony.inc"\n.text\nentry:')
pc = BASE
while is_output[pc]:
    if is_label[pc]:
        print("L%04x:" % pc)
    if is_code[pc]:
        if is_chunkjump(pc):
            print("\t%-20s ; %04x %s" % (render_chunkjump("chunkjump", pc), pc, render_bytes(pc, 23)))
            pc += 23
        elif is_chunkcall(pc):
            print("\t%-20s ; %04x %s" % (render_chunkjump("chunkcall", pc), pc, render_bytes(pc, 23)))
            pc += 23
        else:
            op = OPCODES[data[pc]]
            s = op.render(pc)
            print(
                "\t%-20s ; %04x %s" % (op.render(pc), pc, render_bytes(pc, op.len))
            )
            pc += op.len
    else:
        print(
            "\t.byte 0x%02x           ; %04x %s"
            % (data[pc], pc, render_bytes(pc, 1))
        )
        pc += 1
