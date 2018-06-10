LIB_NAME = argon2

CC      ?= gcc
LDFLAGS ?= -shared
CFLAGS  ?= -O2 -fPIC -ansi -Wall -Werror -Wpedantic

PREFIX        ?= /usr/local
ARGON2_INCDIR ?= $(PREFIX)/include
ARGON2_LIBDIR ?= $(PREFIX)/lib/
LUA_INCDIR    ?= $(PREFIX)/include

BUILD_CFLAGS  = -I$(LUA_INCDIR) -I$(ARGON2_INCDIR)
BUILD_LDFLAGS = -L$(ARGON2_LIBDIR) -largon2

.PHONY: all install test clean doc $(LIB_NAME)

all: $(LIB_NAME).so

$(LIB_NAME).so: $(LIB_NAME).o
	$(CC) $(LDFLAGS) -o $@ $< $(BUILD_LDFLAGS)

$(LIB_NAME).o: src/$(LIB_NAME).c
	$(CC) $(CFLAGS) -c $< -o $@ $(BUILD_CFLAGS)

install:
	cp $(LIB_NAME).so $(INST_LIBDIR)

test:
	@busted -v spec

clean:
	rm -f *.so *.o

doc:
	ldoc -c docs/config.ld src
