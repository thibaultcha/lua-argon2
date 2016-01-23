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
ARGON2_LIBDIR ?= -L$(PREFIX)/lib/ -largon2

BUILD_CFLAGS   = $(LUA_INCDIR) $(ARGON2_INCDIR)
BUILD_LDFLAGS  = $(LUA_LIBDIR) $(ARGON2_LIBDIR)

.PHONY: all install test clean format $(LIB_NAME)

all: $(BRIDGE_NAME).so

$(BRIDGE_NAME).so: $(BRIDGE_NAME).o
	$(CC) $(LIBFLAG) -o $@ $< $(BUILD_LDFLAGS) $(SO_LDFLAGS)

$(BRIDGE_NAME).o: src/$(BRIDGE_NAME).c
	$(CC) -c $(LUA_CFLAGS) $< -o $@ $(BUILD_CFLAGS)

install:
	cp $(BRIDGE_NAME).so $(INST_LIBDIR)
	cp $(LIB_NAME).lua $(INST_LUADIR)

test:
	@busted spec

clean:
	rm -f *.so *.o

format:
	clang-format -style="{BasedOnStyle: llvm, IndentWidth: 4}" -i src/$(BRIDGE_NAME).c
