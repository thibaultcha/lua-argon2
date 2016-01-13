LIB_NAME = argon2
BRIDGE_NAME = l$(LIB_NAME)

CC            ?= gcc
LUA_VERSION   ?= 5.1
LIBFLAG       ?= -shared
LUA_CFLAGS    ?= -O2 -Wall -Werror -fPIC

PREFIX        ?= /usr/local
LUA_INCDIR    ?= -I$(PREFIX)/include
LUA_LIBDIR    ?= -L$(PREFIX)/lib/lua/$(LUA_VERSION)
ARGON2_INCDIR ?= -I$(PREFIX)/include
ARGON2_LIBDIR ?= -L$(PREFIX)/lib/

BUILD_CFLAGS   = $(LUA_INCDIR) $(ARGON2_INCDIR)
BUILD_LDFLAGS  = $(LUA_LIBDIR) $(ARGON2_LIBDIR) -largon2

.PHONY: all install test clean $(LIB_NAME)

all: $(BRIDGE_NAME).so

$(BRIDGE_NAME).so: $(BRIDGE_NAME).o
	$(CC) $(LIBFLAG) -o $@ $< $(BUILD_LDFLAGS) $(SO_LDFLAGS)

$(BRIDGE_NAME).o: $(BRIDGE_NAME).c
	$(CC) -c $(LUA_CFLAGS) $< -o $@ $(BUILD_CFLAGS)

install:
	cp $(BRIDGE_NAME).so $(INST_LIBDIR)
	cp $(LIB_NAME).lua $(INST_LUADIR)

test:
	@busted test.lua

clean:
	rm -f *.so *.o
