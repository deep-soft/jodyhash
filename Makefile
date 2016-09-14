CC=gcc
#CFLAGS=-Os -flto -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables
CFLAGS=-O2
#CFLAGS=-Og -g3
BUILD_CFLAGS = -std=gnu99 -I. -D_FILE_OFFSET_BITS=64 -pipe -fstrict-aliasing
BUILD_CFLAGS += -Wall -Wextra -Wcast-align -Wstrict-aliasing -pedantic -Wstrict-overflow
#LDFLAGS=-s -Wl,--gc-sections
#LDFLAGS=

prefix=/usr
exec_prefix=${prefix}
bindir=${exec_prefix}/bin
mandir=${prefix}/man
datarootdir=${prefix}/share
datadir=${datarootdir}
sysconfdir=${prefix}/etc

# MinGW needs this for printf() conversions to work
ifeq ($(OS), Windows_NT)
	WIN_CFLAGS += -D__USE_MINGW_ANSI_STDIO=1 -municode
endif

all: jodyhash

benchmark: jody_hash.o benchmark.o
	$(CC) -c benchmark.c $(BUILD_CFLAGS) $(CFLAGS) $(CFLAGS_EXTRA) -o benchmark.o
	$(CC) $(CFLAGS) $(LDFLAGS) $(BUILD_CFLAGS) $(CFLAGS_EXTRA) -o benchmark jody_hash.o benchmark.o
	./benchmark 1000000

jodyhash: jody_hash.o main.o
	$(CC) $(CFLAGS) $(LDFLAGS) $(BUILD_CFLAGS) $(WIN_CFLAGS) $(CFLAGS_EXTRA) -o jodyhash jody_hash.o main.o

.c.o:
	$(CC) -c $(BUILD_CFLAGS) $(CFLAGS) $(WIN_CFLAGS) $(CFLAGS_EXTRA) $<

clean:
	rm -f *.o *~ .*un~ benchmark jodyhash debug.log *.?.gz

distclean:
	rm -f *.o *~ .*un~ benchmark jodyhash debug.log *.?.gz *.pkg.tar.*

install: all
	install -D -o root -g root -m 0755 -s jodyhash $(DESTDIR)/$(bindir)/jodyhash

package:
	+./chroot_build.sh
