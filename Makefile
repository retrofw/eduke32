TARGET = eduke32/eduke32.dge

CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CC  := $(CROSS_COMPILE)gcc
CXX := $(CROSS_COMPILE)g++
LD  := $(CROSS_COMPILE)gcc
STRIP := $(CROSS_COMPILE)strip
RC  := $(CROSS_COMPILE)windres

SYSROOT     := $(shell $(CXX) --print-sysroot)
SDL_CFLAGS  := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS    := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

export TARGET CHAINPREFIX CROSS_COMPILE CC CXX LD STRIP RC SYSROOT SDL_CFLAGS SDL_LIBS

all:
	make -C src

clean:
	make -C src clean

ipk: all
	@rm -rf /tmp/.eduke32-ipk/ && mkdir -p /tmp/.eduke32-ipk/root/home/retrofw/games/eduke32 /tmp/.eduke32-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r eduke32/eduke32.dge eduke32/eduke32.png eduke32/duke3d.grp eduke32/eduke32.cfg eduke32/eduke32.man.txt eduke32/mapster32.dge eduke32/settings.cfg /tmp/.eduke32-ipk/root/home/retrofw/games/eduke32
	@cp eduke32/eduke32.lnk /tmp/.eduke32-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" eduke32/control > /tmp/.eduke32-ipk/control
	@cp eduke32/conffiles /tmp/.eduke32-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.eduke32-ipk/control.tar.gz -C /tmp/.eduke32-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.eduke32-ipk/data.tar.gz -C /tmp/.eduke32-ipk/root/ .
	@echo 2.0 > /tmp/.eduke32-ipk/debian-binary
	@ar r eduke32/eduke32.ipk /tmp/.eduke32-ipk/control.tar.gz /tmp/.eduke32-ipk/data.tar.gz /tmp/.eduke32-ipk/debian-binary

opk: all
	@mksquashfs \
	eduke32/default.retrofw.desktop \
	eduke32/eduke32.dge \
	eduke32/eduke32.png \
	eduke32/eduke32.man.txt \
	eduke32/duke3d.grp \
	eduke32/eduke32.cfg \
	eduke32/mapster32.dge \
	eduke32/settings.cfg \
	eduke32/eduke32.opk \
	-all-root -noappend -no-exports -no-xattrs
