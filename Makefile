DEBUG=0

ifeq ($(platform),)
platform = unix
ifeq ($(shell uname -a),)
   platform = win
else ifneq ($(findstring MINGW,$(shell uname -a)),)
   platform = win
else ifneq ($(findstring Darwin,$(shell uname -a)),)
   platform = osx
else ifneq ($(findstring win,$(shell uname -a)),)
   platform = win
endif
endif

CC         = gcc
DOOMSRC    = src
PORTSRCDIR = src
LMADSRCDIR = libmad

ifeq ($(platform), unix)
   TARGET := libretro.so
   fpic := -fPIC
   SHARED := -shared -Wl,--version-script=src/libretro/link.T -Wl,-no-undefined
   CFLAGS += -D_GNU_SOURCE=1 -DHAVE_LIBMAD -DMUSIC_SUPPORT
else ifeq ($(platform), osx)
   TARGET := libretro.dylib
   fpic := -fPIC
   SHARED := -dynamiclib
else ifeq ($(platform), ps3)
   TARGET := libretro.a
   CC = $(CELL_SDK)/host-win32/ppu/bin/ppu-lv2-gcc.exe
   AR = $(CELL_SDK)/host-win32/ppu/bin/ppu-lv2-ar.exe
   CFLAGS += -DWORDS_BIGENDIAN=1 -D_GNU_SOURCE=1 -DHAVE_LIBMAD -DMUSIC_SUPPORT
else ifeq ($(platform), sncps3)
   TARGET := libretro.a
   CC = $(CELL_SDK)/host-win32/sn/bin/ps3ppusnc.exe
   AR = $(CELL_SDK)/host-win32/sn/bin/ps3snarl.exe
   CFLAGS += -DWORDS_BIGENDIAN=1 -D_GNU_SOURCE=1 -DHAVE_LIBMAD -DMUSIC_SUPPORT
else ifeq ($(platform), xenon)
   TARGET := libretro.a
   CC = xenon-gcc
   AR = xenon-ar
   CFLAGS += -D__LIBXENON__ -m32 -D__ppc__ -DWORDS_BIGENDIAN=1 -D_GNU_SOURCE=1 -DHAVE_LIBMAD -DMUSIC_SUPPORT
else ifeq ($(platform), wii)
   TARGET := libretro.a
   CC = $(DEVKITPPC)/bin/powerpc-eabi-gcc
   AR = $(DEVKITPPC)/bin/powerpc-eabi-ar
   CFLAGS += -DGEKKO -mrvl -mcpu=750 -meabi -mhard-float -DWORDS_BIGENDIAN=1 -D_GNU_SOURCE=1 -DHAVE_LIBMAD -DMUSIC_SUPPORT
else
   TARGET := retro.dll
   CC = gcc
   SHARED := -shared -static-libgcc -static-libstdc++ -s -Wl,--version-script=src/libretro/link.T
   CFLAGS += -D__WIN32__ -D__WIN32_LIBRETRO__ -DHAVE_LIBMAD -DMUSIC_SUPPORT -Wno-missing-field-initializers -DHAVE_STRLWR -DNO_ASM_BYTEORDER
endif

ifeq ($(DEBUG), 1)
CFLAGS += -O0 -g
else
CFLAGS += -O3
endif

PORTOBJECTS = ./$(DOOMSRC)/libretro.o

LIBMADOBJECTS = ./$(LMADSRCDIR)/bit.o ./$(LMADSRCDIR)/decoder.o ./$(LMADSRCDIR)/fixed.o ./$(LMADSRCDIR)/frame.o ./$(LMADSRCDIR)/huffman.o ./$(LMADSRCDIR)/layer3.o ./$(LMADSRCDIR)/layer12.o ./$(LMADSRCDIR)/stream.o ./$(LMADSRCDIR)/synth.o ./$(LMADSRCDIR)/timer.o

OBJECTS    = ./$(DOOMSRC)/am_map.o ./$(DOOMSRC)/d_deh.o ./$(DOOMSRC)/d_items.o ./$(DOOMSRC)/d_main.o ./$(DOOMSRC)/doomstat.o ./$(DOOMSRC)/dstrings.o ./$(DOOMSRC)/f_finale.o ./$(DOOMSRC)/f_wipe.o ./$(DOOMSRC)/g_game.o ./$(DOOMSRC)/hu_lib.o ./$(DOOMSRC)/hu_stuff.o     ./$(DOOMSRC)/info.o ./$(DOOMSRC)/m_argv.o ./$(DOOMSRC)/m_bbox.o ./$(DOOMSRC)/m_cheat.o ./$(DOOMSRC)/m_menu.o ./$(DOOMSRC)/m_misc.o ./$(DOOMSRC)/m_random.o ./$(DOOMSRC)/p_ceilng.o ./$(DOOMSRC)/p_doors.o ./$(DOOMSRC)/p_enemy.o ./$(DOOMSRC)/p_floor.o ./$(DOOMSRC)/p_inter.o ./$(DOOMSRC)/p_lights.o ./$(DOOMSRC)/p_map.o ./$(DOOMSRC)/p_maputl.o ./$(DOOMSRC)/p_mobj.o ./$(DOOMSRC)/p_plats.o ./$(DOOMSRC)/p_pspr.o ./$(DOOMSRC)/p_saveg.o ./$(DOOMSRC)/p_setup.o ./$(DOOMSRC)/p_sight.o ./$(DOOMSRC)/p_spec.o ./$(DOOMSRC)/p_switch.o ./$(DOOMSRC)/p_telept.o ./$(DOOMSRC)/p_tick.o ./$(DOOMSRC)/p_user.o ./$(DOOMSRC)/r_bsp.o ./$(DOOMSRC)/r_data.o ./$(DOOMSRC)/r_draw.o ./$(DOOMSRC)/r_main.o ./$(DOOMSRC)/r_plane.o ./$(DOOMSRC)/r_segs.o ./$(DOOMSRC)/r_sky.o ./$(DOOMSRC)/r_things.o ./$(DOOMSRC)/r_patch.o ./$(DOOMSRC)/s_sound.o ./$(DOOMSRC)/sounds.o ./$(DOOMSRC)/st_lib.o ./$(DOOMSRC)/st_stuff.o ./$(DOOMSRC)/tables.o ./$(DOOMSRC)/v_video.o ./$(DOOMSRC)/w_wad.o ./$(DOOMSRC)/z_zone.o ./$(DOOMSRC)/w_memcache.o ./$(DOOMSRC)/r_fps.o ./$(DOOMSRC)/r_filter.o ./$(DOOMSRC)/p_genlin.o ./$(DOOMSRC)/r_demo.o ./$(DOOMSRC)/z_bmalloc.o ./$(DOOMSRC)/lprintf.o ./$(DOOMSRC)/wi_stuff.o ./$(DOOMSRC)/p_checksum.o ./$(DOOMSRC)/md5.o ./$(DOOMSRC)/version.o ./$(DOOMSRC)/d_client.o ./$(DOOMSRC)/mmus2mid.o $(PORTOBJECTS) $(DOOMSRC)/madplayer.o $(LIBMADOBJECTS)

INCLUDES   = -I. -I.. -Isrc -Ilibmad
DEFINES    = -DHAVE_INTTYPES_H -D__LIBRETRO__ -DHAVE_MEMORY_H -DINLINE=inline -DFPM_DEFAULT -DSIZEOF_INT=4 -DSIZEOF_LONG=4 -DSIZEOF_LONG_LONG=8

ifeq ($(platform), sncps3)
WARNINGS_DEFINES =
CODE_DEFINES =
else
WARNINGS_DEFINES = -Wall -W -Wno-unused-parameter
CODE_DEFINES = -fomit-frame-pointer -std=gnu99
endif

COMMON_DEFINES += $(CODE_DEFINES) $(WARNINGS_DEFINES) -DNDEBUG=1 $(fpic)

CFLAGS     += $(DEFINES) $(COMMON_DEFINES)

all: $(TARGET)

$(TARGET): $(OBJECTS)
ifeq ($(platform), ps3)
	$(AR) rcs $@ $(OBJECTS)
else ifeq ($(platform), sncps3)
	$(AR) rcs $@ $(OBJECTS)
else ifeq ($(platform), xenon)
	$(AR) rcs $@ $(OBJECTS)
else ifeq ($(platform), wii)
	$(AR) rcs $@ $(OBJECTS)
else
	$(CC) $(fpic) $(SHARED) $(INCLUDES) -o $@ $(OBJECTS) -lm
endif

%.o: %.c
	$(CC) $(INCLUDES) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJECTS) $(TARGET)

.PHONY: clean

