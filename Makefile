export LLVM = /opt/pkg/llvm-mos/bin
export CC6502 = $(LLVM)/mos-cpm65-clang
export LD6502 = $(LLVM)/ld.lld
export AR6502 = $(LLVM)/llvm-ar

export OBJ = .obj

export CFLAGS6502 = -Os -g
export LDFLAGS6502 = -mlto-zp=0

.PHONY: all
all: +all
	
include build/ab.mk
