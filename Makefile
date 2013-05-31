# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
#
# Makefile for asm example - stolen from asmutils
#
# $Id: Makefile,v 1.5 2000/04/07 18:36:01 konst Exp $

#---------------------------------------------------------------------------#

#			CONFIGURATION PARAMETERS

#---------------------------------------------------------------------------#

# Operating system (LINUX/FREEBSD/BEOS/LIBC)

OS = LINUX

# Optimization method (SIZE/SPEED)

OPTIMIZE = SPEED

# Include version stamp into binaries

#STAMP = y

# LINUX only
#
# Kernel version (20/22)
KERNEL = 24
# ELF hack for smaller binaries - uncomment this to debug under gdb
ELF_MACROS = y

# LIBC only

#LIBC = y

#
# Use custom startup code (currently works only with C style main() stack)
# Use only with LIBC and only if utils fail without it (f.e. on BeOS)
# STARTUP = y

#---------------------------------------------------------------------------#

#			DO NOT EDIT BELOW

#---------------------------------------------------------------------------#

AS = nasm
LD = ld
LN = ln -s
LDFLAGS =
ASFLAGS = -l $(FILES).lst -O4 -D__ELF__ -D__$(OS)__ -D__OPTIMIZE__=__O_$(OPTIMIZE)__ -i ../include -i lib/

FILES = sql

LINKS =

${OS} = y

ifdef LIBC
ELF_MACROS =
LD = gcc -g
ASFLAGS += -D__LIBC__
ifndef STARTUP
LDFLAGS = -nostartfiles
endif
endif

ifdef STARTUP
ASFLAGS += -D__STARTUP__
endif

ifdef KERNEL
ASFLAGS += -D__KERNEL__=$(KERNEL)
endif
ifdef STAMP
ASFLAGS += -DSTAMP_VERSION="'asmutils 0.09'" -DSTAMP_DATE="'$(shell date "+%d-%b-%Y %H:%M")'"
endif

ifdef ELF_MACROS

ASFLAGS += -D__ELF_MACROS__ -f bin

%:	%.asm
	$(AS) $(ASFLAGS) $<
	chmod +x $*
else

ASFLAGS += -f elf

%.o:	%.asm
	$(AS) $(ASFLAGS) $<

%:	%.o
	$(LD) $(LDFLAGS) -o $* $<

endif

all:	$(FILES)


#install:
#	mkdir -p ../bin/$(OS)-$(KERNEL)
#	cp -rd $(FILES) $(LINKS) ../bin/$(OS)-$(KERNEL)

clean:
	rm -f *.o $(FILES)

