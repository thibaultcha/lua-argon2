PWD = $(shell pwd)
LIB_NAME = argon2
BRIDGE_NAME = l$(LIB_NAME)

CC            ?= gcc
LUA_VERSION   ?= 5.1
LIBFLAG       ?= -shared
LUA_CFLAGS    ?= -O2 -Wall -Werror -fPIC

PREFIX        ?= /usr/local
LUA_INCDIR    ?= $(PREFIX)/include
LUA_LIBDIR    ?= $(PREFIX)/lib/lua/$(LUA_VERSION)
ARGON2_INCDIR ?= $(PREFIX)/include
ARGON2_LIBDIR ?= $(PREFIX)/lib/
BUILD_CFLAGS   = -I$(LUA_INCDIR) -I$(ARGON2_INCDIR)
BUILD_LDFLAGS  = -L$(LUA_LIBDIR) -L$(ARGON2_LIBDIR) -largon2

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
