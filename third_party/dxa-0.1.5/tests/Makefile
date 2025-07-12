# simple universal parallelizable test harness for GNU and BSD make

RM = rm
XA = xa
CMP = cmp
DXA = ../dxa
ECHO = echo
TOUCH = touch

# compatible with BSD and GNU
VECTORS = $(wildcard *.t)
VECTORS != echo *.t
TESTS = $(VECTORS:.t=.g)

.DEFAULT: clean all

.PHONY: all clean

.SUFFIXES: .s .o .g .t

.PRECIOUS: .s .o

all: ${TESTS}
	@echo ""
	@echo "*** ALL TESTS PASS ***"
	@echo ""
	$(MAKE) clean

clean:
	${RM} -f *.o *.s *.g

# BSD make only has suffix rules
.t.s:
	${DXA} $< > $@

.s.o:
	${XA} -o $@ $<

.o.g:
	${CMP} $*.o $*.t
	${RM} $*.s $*.o
	${TOUCH} $@

