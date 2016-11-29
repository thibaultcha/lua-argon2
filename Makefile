LIB_NAME = argon2

CC            ?= gcc
LUA_VERSION   ?= 5.1
LIBFLAG       ?= -shared
LUA_CFLAGS    ?= -O2 -fPIC -Wall -Werror

PREFIX        ?= /usr/local
LUA_INCDIR    ?= $(PREFIX)/include
LUA_LIBDIR    ?= $(PREFIX)/lib/lua/$(LUA_VERSION)
ARGON2_INCDIR ?= $(PREFIX)/include
ARGON2_LIBDIR ?= $(PREFIX)/lib/

BUILD_CFLAGS   = -I$(LUA_INCDIR) -I$(ARGON2_INCDIR)
BUILD_LDFLAGS  = -L$(LUA_LIBDIR) -L$(ARGON2_LIBDIR) -llua -largon2

.PHONY: all install test clean doc $(LIB_NAME)

all: $(LIB_NAME).so

$(LIB_NAME).so: $(LIB_NAME).o
	$(CC) $(LIBFLAG) -o $@ $< $(BUILD_LDFLAGS) $(SO_LDFLAGS)

$(LIB_NAME).o: src/$(LIB_NAME).c
	$(CC) $(LUA_CFLAGS) -c $< -o $@ $(BUILD_CFLAGS)

install:
	cp $(LIB_NAME).so $(INST_LIBDIR)

test:
	@busted -v spec

clean:
	rm -f *.so *.o

doc:
	ldoc -c docs/config.ld src
