NAME = argon2
LIBNAME = lua_$(NAME)

CC ?= gcc
LUA_VERSION ?= 5.1

PREFIX ?=        /usr/local
LUA_INCDIR ?=    $(PREFIX)/include
LUA_LIBDIR ?=    $(PREFIX)/lib/lua/$(LUA_VERSION)
ARGON2_INCDIR ?= $(PREFIX)/include
ARGON2_LIBDIR ?= $(PREFIX)/lib

BUILD_CFLAGS = -I$(LUA_INCDIR) -I$(ARGON2_INCDIR)
BUILD_LDFLAGS = -L$(LUA_LIBDIR) -L$(ARGON2_LIBDIR) -largon2

LIBFLAG ?= -shared
CFLAGS ?= -O2 -Wall -Werror -fPIC

.PHONY: all install test clean

all: $(LIBNAME).so

%.so: %.o
	$(CC) $(LIBFLAG) -o $@ $< $(BUILD_LDFLAGS)

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@ $(BUILD_CFLAGS)

install:
	cp $(LIBNAME).so $(INST_LIBDIR)
	cp $(NAME).lua $(INST_LUADIR)

test:
	@busted test.lua

clean:
	rm -f *.so *.o
