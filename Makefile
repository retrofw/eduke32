#
# EDuke32 Makefile for GNU Make
#

# DEFINES

# Use colored output
PRETTY_OUTPUT = 0

# SDK locations - adjust to match your setup
DXROOT=../sdk/dx
#DXROOT=c:/sdks/directx/dx8

# Engine options
SUPERBUILD = 1
POLYMOST = 0
POLYMER = 0
USE_OPENGL = 0
NOASM = 1
LINKED_GTK = 0
BUILD32_ON_64 = 0
NEDMALLOC = 0

# Debugging/Build options
RELEASE?=1
DEBUGANYWAY?=0
KRANDDEBUG?=0
NOSOUND?=0
OPTLEVEL?=2
PROFILER?=0

ifneq (0,$(KRANDDEBUG))
    RELEASE=0
endif
ifneq (0,$(PROFILER))
    DEBUGANYWAY=1
endif

# Build locations
SRC=source
RSRC=rsrc
EROOT=build
ESRC=$(EROOT)/src
EINC=$(EROOT)/include
INC=$(SRC)
o=o
# ENETROOT=$(ESRC)/enet

ifneq (0,$(RELEASE))
    # Debugging disabled
    debug=-fomit-frame-pointer -funswitch-loops -O$(OPTLEVEL) $(F_NO_STACK_PROTECTOR)
    LIBS=-lm
else
    # Debugging enabled
    debug=-ggdb -O0 -DDEBUGGINGAIDS
    LIBS=-lm -rdynamic

    ifneq (0,$(KRANDDEBUG))
      debug+=-fno-inline -fno-inline-functions -fno-inline-functions-called-once
      debug+=-DKRANDDEBUG=1
    endif
endif

ifneq (0,$(DEBUGANYWAY))
    debug+=-ggdb
endif

JAUDIOLIBDIR=$(SRC)/jaudiolib
JAUDIOLIB=libjfaudiolib.a

ENETDIR=$(SRC)/enet
ENETLIB=libenet.a


CHAINPREFIX := /opt/mipsel-linux-uclibc
CROSS_COMPILE := $(CHAINPREFIX)/usr/bin/mipsel-linux-

CC  := $(CROSS_COMPILE)gcc
CXX := $(CROSS_COMPILE)g++
LD  := $(CROSS_COMPILE)gcc
STRIP := $(CROSS_COMPILE)strip
RC  := $(CROSS_COMPILE)windres

SYSROOT := $(shell $(CC) --print-sysroot)
SDL_CFLAGS := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

ARCH=-fstrength-reduce -fthread-jumps -fexpensive-optimizations -fomit-frame-pointer -frename-registers -pipe -G 0 -ffast-math
#CC=gcc
#CXX=g++
#RC=windres
#STRIP=strip

SDL_FRAMEWORK=$(CHAINPREFIX)/mipsel-buildroot-linux-uclibc/sysroot/usr/include/

OURCFLAGS=$(debug) -W -Wall -Wimplicit \
    -funsigned-char -fno-strict-aliasing -DNO_GCC_BUILTINS \
    -I$(INC) -I$(EINC) -I$(SRC)/jmact -I$(JAUDIOLIBDIR)/include -I$(ENETDIR)/include -D_FORTIFY_SOURCE=2 \
    $(F_JUMP_TABLES) $(ARCH)

OURCXXFLAGS=-fno-exceptions -fno-rtti

NASMFLAGS= -s
EXESUFFIX=.elf

include $(EROOT)/Makefile.shared

ifeq ($(PLATFORM),WINDOWS)
    OBJ=obj_win
    EOBJ=eobj_win
    LIBS+= $(L_SSP) -Wl,--enable-auto-import
else
    LIBS+= -ldl
    OBJ=obj
    EOBJ=eobj
endif

JMACTOBJ=$(OBJ)/file_lib.$o \
	$(OBJ)/control.$o \
	$(OBJ)/keyboard.$o \
	$(OBJ)/mouse.$o \
	$(OBJ)/mathutil.$o \
	$(OBJ)/scriplib.$o \
	$(OBJ)/animlib.$o

GAMEOBJS=$(OBJ)/game.$o \
	$(OBJ)/actors.$o \
	$(OBJ)/anim.$o \
	$(OBJ)/config.$o \
	$(OBJ)/demo.$o \
	$(OBJ)/gamedef.$o \
	$(OBJ)/gameexec.$o \
	$(OBJ)/gamevars.$o \
	$(OBJ)/global.$o \
	$(OBJ)/menus.$o \
	$(OBJ)/namesdyn.$o \
	$(OBJ)/net.$o \
	$(OBJ)/player.$o \
	$(OBJ)/premap.$o \
	$(OBJ)/savegame.$o \
	$(OBJ)/sector.$o \
	$(OBJ)/rts.$o \
	$(OBJ)/osdfuncs.$o \
	$(OBJ)/osdcmds.$o \
	$(OBJ)/grpscan.$o \
	$(OBJ)/sounds.$o \
	$(JMACTOBJ)

EDITOROBJS=$(OBJ)/astub.$o \
	$(OBJ)/m32def.$o \
	$(OBJ)/m32exec.$o \
	$(OBJ)/m32vars.$o \
	$(OBJ)/mathutil.$o

# PLATFORM SPECIFIC SETTINGS

ifeq ($(PLATFORM),LINUX)
    OURCFLAGS	+= -fno-pic
    NASMFLAGS	+= -f elf
    LIBS		+= -lvorbisfile -lvorbis -logg
endif

ifeq ($(PLATFORM),DARWIN)
    ifeq (1,$(SDL_FRAMEWORK))
        OURCFLAGS += -fno-pic -IApple/include -I/Library/Frameworks/SDL.framework/Headers \
                -I-I/Library/Frameworks/SDL_mixer.framework/Headers
        LIBS += -read_only_relocs suppress -LApple/lib -lvorbisfile -lvorbis -logg -lm \
                -Wl,-framework,SDL -Wl,-framework,SDL_mixer Apple/lib/libSDLmain.a \
                -Wl,-framework,Cocoa -Wl,-framework,Carbon -Wl,-framework,OpenGL \
                -Wl,-framework,CoreMidi -Wl,-framework,AudioUnit \
                -Wl,-framework,AudioToolbox -Wl,-framework,IOKit -Wl,-framework,AGL \
                -Wl,-framework,QuickTime -lm

    else
        OURCFLAGS += -fno-pic -I$(SDLROOT)/include -I$(SDLROOT)/include/SDL
        LIBS += -read_only_relocs suppress -lvorbisfile -lvorbis -logg -lm -lSDL_mixer \
                -Wl,-framework,Cocoa -Wl,-framework,Carbon -Wl,-framework,OpenGL \
                -Wl,-framework,CoreMidi -Wl,-framework,AudioUnit \
                -Wl,-framework,AudioToolbox -Wl,-framework,IOKit -Wl,-framework,AGL \
                -Wl,-framework,QuickTime -lm
    endif
    NASMFLAGS += -f Mach-O
endif

ifeq ($(PLATFORM),WINDOWS)
    OURCFLAGS	+= -fno-pic -DUNDERSCORES -I$(DXROOT)/include
    NASMFLAGS+= -DUNDERSCORES -f win32
    LIBS		+= -L$(JAUDIOLIBDIR)/third-party/mingw32/lib -lvorbisfile -lvorbis -logg -lwsock32 -lws2_32 -lwinmm -ldsound
    GAMEOBJS+= $(OBJ)/gameres.$o $(OBJ)/winbits.$o $(OBJ)/startwin.game.$o $(OBJ)/music.$o $(OBJ)/midi.$o $(OBJ)/mpu401.$o
    EDITOROBJS+= $(OBJ)/buildres.$o
    JAUDIOLIB=libjfaudiolib_win32.a
    ENETLIB=libenet_win32.a
else
# -lGLU to build with gluBuild2DMipmaps
    ifeq ($(RENDERTYPE),SDL)
        ifeq (0,$(SDL_FRAMEWORK))
            OURCFLAGS+= $(subst -Dmain=SDL_main,,$(SDL_CFLAGS))
            LIBS+= -lSDL_mixer
        else
            OURCFLAGS   += -DSDL_FRAMEWORK
        endif

        GAMEOBJS+= $(OBJ)/game_icon.$o $(OBJ)/sdlmusic.$o
        EDITOROBJS+= $(OBJ)/build_icon.$o
    endif
endif


EDITOROBJS+= $(OBJ)/sounds_mapster32.$o
OURCFLAGS+= $(BUILDCFLAGS)
OURCXXFLAGS+= $(BUILDCFLAGS)

MISCLINKOPTS=
ifneq (0,$(KRANDDEBUG))
    MISCLINKOPTS=-Wl,-Map=$@.memmap
endif
ifneq (0,$(PROFILER))
    MISCLINKOPTS=-pg
endif

.PHONY: clean all engine $(EOBJ)/$(ENGINELIB) $(EOBJ)/$(EDITORLIB) $(JAUDIOLIBDIR)/$(JAUDIOLIB) $(ENETDIR)/$(ENETLIB)

# TARGETS

all: notice eduke32/eduke32$(EXESUFFIX) eduke32/mapster32$(EXESUFFIX)

all:
	$(BUILD_FINISHED)
	@ls -l eduke32/eduke32$(EXESUFFIX)
	@ls -l eduke32/mapster32$(EXESUFFIX)

notice:
	$(BUILD_STARTED)

eduke32/eduke32$(EXESUFFIX): $(GAMEOBJS) $(EOBJ)/$(ENGINELIB) $(JAUDIOLIBDIR)/$(JAUDIOLIB) $(ENETDIR)/$(ENETLIB)
	$(LINK_STATUS)
	$(CC) -o $@ $^  $(STDCPPLIB) $(MISCLINKOPTS) -lSDL_mixer -lSDL -logg -lvorbisidec

eduke32/mapster32$(EXESUFFIX): $(EDITOROBJS) $(EOBJ)/$(EDITORLIB) $(EOBJ)/$(ENGINELIB) $(JAUDIOLIBDIR)/$(JAUDIOLIB) $(ENETDIR)/$(ENETLIB)
	$(LINK_STATUS)
	$(CC) $(CFLAGS) $(OURCFLAGS) -o $@ $^ $(STDCPPLIB) $(MISCLINKOPTS) -lSDL_mixer -lSDL -logg -lvorbisidec

include Makefile.deps

.PHONY: enginelib editorlib
enginelib editorlib:
	-mkdir -p $(EOBJ)	
	$(MAKE) -C $(EROOT)/ "OBJ=../$(EOBJ)" \
		SUPERBUILD=$(SUPERBUILD) POLYMOST=$(POLYMOST) DEBUGANYWAY=$(DEBUGANYWAY) KRANDDEBUG=$(KRANDDEBUG)\
		USE_OPENGL=$(USE_OPENGL) BUILD32_ON_64=$(BUILD32_ON_64) PROFILER=$(PROFILER)\
		NOASM=$(NOASM) RELEASE=$(RELEASE) OPTLEVEL=$(OPTLEVEL) $@
$(EOBJ)/$(ENGINELIB): enginelib
$(EOBJ)/$(EDITORLIB): editorlib
$(JAUDIOLIBDIR)/$(JAUDIOLIB):
	$(MAKE) -C $(JAUDIOLIBDIR) PRETTY_OUTPUT=$(PRETTY_OUTPUT) EROOT=$(EROOT) RELEASE=$(RELEASE) OPTLEVEL=$(OPTLEVEL) DEBUGANYWAY=$(DEBUGANYWAY)
$(ENETDIR)/$(ENETLIB):
	$(MAKE) -C $(ENETDIR) PRETTY_OUTPUT=$(PRETTY_OUTPUT) EROOT=$(EROOT) RELEASE=$(RELEASE) OPTLEVEL=$(OPTLEVEL) 


# RULES
$(OBJ)/%.$o: $(SRC)/%.nasm
	$(COMPILE_STATUS)
	$(AS) $(NASMFLAGS) $< -o $@

$(OBJ)/%.$o: $(SRC)/%.c
	$(COMPILE_STATUS)
	if $(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@; then $(COMPILE_OK); else $(COMPILE_FAILED); fi

$(OBJ)/%.$o: $(SRC)/%.cpp
	$(COMPILE_STATUS)
	if $(CXX) $(CXXFLAGS) $(OURCXXFLAGS) $(OURCFLAGS) -c $< -o $@; then $(COMPILE_OK); else $(COMPILE_FAILED); fi

$(OBJ)/%.$o: $(SRC)/jmact/%.c
	$(COMPILE_STATUS)
	if $(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@; then $(COMPILE_OK); else $(COMPILE_FAILED); fi

$(OBJ)/%.$o: $(SRC)/misc/%.rc
	$(COMPILE_STATUS)
	if $(RC) -i $< -o $@ --include-dir=$(EINC) --include-dir=$(SRC) -DPOLYMER=$(POLYMER); then $(COMPILE_OK); else $(COMPILE_FAILED); fi

$(OBJ)/%.$o: $(SRC)/util/%.c
	$(COMPILE_STATUS)
	if $(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@; then $(COMPILE_OK); else $(COMPILE_FAILED); fi

$(OBJ)/%.$o: $(RSRC)/%.c
	$(COMPILE_STATUS)
	if $(CC) $(CFLAGS) $(OURCFLAGS) -c $< -o $@; then $(COMPILE_OK); else $(COMPILE_FAILED); fi

$(OBJ)/game_banner.$o: $(RSRC)/game_banner.c
$(OBJ)/editor_banner.$o: $(RSRC)/editor_banner.c
$(RSRC)/game_banner.c: $(RSRC)/game.bmp
	echo "#include <gdk-pixbuf/gdk-pixdata.h>" > $@
	gdk-pixbuf-csource --extern --struct --raw --name=startbanner_pixdata $^ | sed 's/load_inc//' >> $@
$(RSRC)/editor_banner.c: $(RSRC)/build.bmp
	echo "#include <gdk-pixbuf/gdk-pixdata.h>" > $@
	gdk-pixbuf-csource --extern --struct --raw --name=startbanner_pixdata $^ | sed 's/load_inc//' >> $@

# PHONIES	

clean:
	-rm -f $(OBJ)/* eduke32/eduke32$(EXESUFFIX) eduke32/mapster32$(EXESUFFIX) core* duke3d_w32$(EXESUFFIX) && $(MAKE) -C $(JAUDIOLIBDIR) clean && $(MAKE) -C $(ENETDIR) clean

veryclean: clean
	-rm -f $(EOBJ)/* $(RSRC)/*banner*

ipk: all
	@rm -rf /tmp/.eduke32-ipk/ && mkdir -p /tmp/.eduke32-ipk/root/home/retrofw/games/eduke32 /tmp/.eduke32-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@cp -r eduke32/eduke32.elf eduke32/eduke32.png eduke32/duke3d.grp eduke32/eduke32.cfg eduke32/eduke32.man.txt eduke32/mapster32.elf eduke32/settings.cfg /tmp/.eduke32-ipk/root/home/retrofw/games/eduke32
	@cp eduke32/eduke32.lnk /tmp/.eduke32-ipk/root/home/retrofw/apps/gmenu2x/sections/games
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" eduke32/control > /tmp/.eduke32-ipk/control
	@cp eduke32/conffiles /tmp/.eduke32-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.eduke32-ipk/control.tar.gz -C /tmp/.eduke32-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.eduke32-ipk/data.tar.gz -C /tmp/.eduke32-ipk/root/ .
	@echo 2.0 > /tmp/.eduke32-ipk/debian-binary
	@ar r eduke32/eduke32.ipk /tmp/.eduke32-ipk/control.tar.gz /tmp/.eduke32-ipk/data.tar.gz /tmp/.eduke32-ipk/debian-binary