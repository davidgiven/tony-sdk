# dxa makefile
# marko's originally, hacked up by cameron

TARGET = dxa
OBJECTS = scan.o vector.o dump.o table.o label.o main.o
VERSION = 0.1.5

# choose the compiler and flags

CC = gcc
#CC = cc

CFLAGS = -Wall -Wmissing-prototypes -O2
#CFLAGS = -Wall -Wmissing-prototypes -ggdb

all: $(TARGET)

$(TARGET) : $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS)

scan.o : structures.h proto.h options.h opcodes.h
vector.o : structures.h proto.h options.h
dump.o : structures.h proto.h options.h opcodes.h
table.o : structures.h proto.h
label.o : structures.h proto.h
main.o : structures.h proto.h options.h opcodes.h

clean:
	rm -f $(OBJECTS) $(TARGET) core
	cd tests && $(MAKE) clean

dist: clean
	cd ..;tar cvf dxa-$(VERSION).tar dxa-$(VERSION);gzip dxa-$(VERSION).tar

test: all
	cd tests && $(MAKE)
