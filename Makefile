LIB_NAME = argon2

CC            ?= gcc
LUA_VERSION   ?= 5.1
LIBFLAG       ?= -shared
LUA_CFLAGS    ?= -O2 -Wall -Werror -fPIC

PREFIX        ?= /usr/local
LUA_INCDIR    ?= -I$(PREFIX)/include
LUA_LIBDIR    ?= -L$(PREFIX)/lib/lua/$(LUA_VERSION)
ARGON2_INCDIR ?= -I$(PREFIX)/include
ARGON2_LIBDIR ?= -L$(PREFIX)/lib/ -largon2

BUILD_CFLAGS   = $(LUA_INCDIR) $(ARGON2_INCDIR)
BUILD_LDFLAGS  = $(LUA_LIBDIR) $(ARGON2_LIBDIR)

.PHONY: all install test clean format doc $(LIB_NAME)

all: $(LIB_NAME).so

$(LIB_NAME).so: $(LIB_NAME).o
	$(CC) $(LIBFLAG) -o $@ $< $(BUILD_LDFLAGS) $(SO_LDFLAGS)

$(LIB_NAME).o: src/$(LIB_NAME).c
	$(CC) -c $(LUA_CFLAGS) $< -o $@ $(BUILD_CFLAGS)

install:
	cp $(LIB_NAME).so $(INST_LIBDIR)

test:
	@busted -v spec

clean:
	rm -f *.so *.o

format:
	clang-format -style="{BasedOnStyle: llvm, IndentWidth: 4}" -i src/$(LIB_NAME).c

doc:
	ldoc -c doc/config.ld src
