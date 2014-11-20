HAVE_LIBUNWIND=1
WITH_ORIGINS_TRACE=1

ifeq ($(HAVE_LIBUNWIND), 1)
	optional_libs=-lunwind
	BUILD_OPTIONS+=-DHAVE_LIBUNWIND
else
	optional_libs=
endif

CC ?= cc
CFLAGS=`pkg-config --cflags glib-2.0`
LIBS=`pkg-config --libs glib-2.0` $(optional_libs)

OBJS = gobject-list.o

ifeq ($(WITH_ORIGINS_TRACE), 1)
	BUILD_OPTIONS+=-DWITH_ORIGINS_TRACE
	OBJS += bt-tree.o
endif

all: libgobject-list.so
clean:
	rm -f libgobject-list.so $(OBJS)

%.o: %.c
	$(CC) -fPIC -rdynamic -g -c -Wall -Wextra ${CFLAGS} ${BUILD_OPTIONS} $<

libgobject-list.so: $(OBJS)
ifeq ($(HAVE_LIBUNWIND), 1)
	@echo "Building with backtrace support (libunwind)"
else
	@echo "Building without backtrace support (libunwind disabled)"
endif
	$(CC) -shared -Wl,-soname,$@ -o $@ $^ -lc -ldl ${LIBS}
