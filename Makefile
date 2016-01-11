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
ARGON2_INCDIR ?= $(PWD)/$(LIB_NAME)/src
ARGON2_LIBDIR ?= $(PWD)/$(LIB_NAME)
BUILD_CFLAGS   = -I$(LUA_INCDIR) -I$(ARGON2_INCDIR)
BUILD_LDFLAGS  = -L$(LUA_LIBDIR) -L$(ARGON2_LIBDIR) -l:libargon2.so

KERNEL_NAME := $(shell uname -s)
ifeq ($(KERNEL_NAME), Linux)
	LIB_EXT := so
endif
ifeq ($(KERNEL_NAME), Darwin)
	LIB_EXT := dylib
	SO_LDFLAGS := -Wl,-rpath,.
endif

.PHONY: all install test clean $(LIB_NAME)

all: $(LIB_NAME) $(BRIDGE_NAME).so

$(LIB_NAME):
	$(MAKE) -C $(LIB_NAME)
	cp $(ARGON2_LIBDIR)/lib$(LIB_NAME).$(LIB_EXT) $(PWD)

$(BRIDGE_NAME).so: $(BRIDGE_NAME).o
	$(CC) $(LIBFLAG) -o $@ $< $(BUILD_LDFLAGS) $(SO_LDFLAGS)

$(BRIDGE_NAME).o: $(BRIDGE_NAME).c
	$(CC) -c $(LUA_CFLAGS) $< -o $@ $(BUILD_CFLAGS)

install:
	cp lib$(LIB_NAME).$(LIB_EXT) $(INST_LIBDIR)
	cp $(BRIDGE_NAME).so $(INST_LIBDIR)
	cp $(LIB_NAME).lua $(INST_LUADIR)

test:
	@busted test.lua

clean:
	$(MAKE) -C $(LIB_NAME) clean
	rm -f *.so *.o
