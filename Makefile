RUN = argon2

CC = gcc
LUA ?= luajit
LUA_LIBDIR ?= $(shell pkg-config $(LUA) --libs)
LUA_INCDIR ?= $(shell pkg-config $(LUA) --cflags)

CFLAGS ?= -O2 -Wall -Werror

ARGON2_INCDIR ?= -I../../tmp/phc-winner-argon2/src
ARGON2_LIBDIR ?= -L../../tmp/phc-winner-argon2 -largon2

INCDIR = $(LUA_INCDIR) $(ARGON2_INCDIR)
LIBDIR = $(LUA_LIBDIR) $(ARGON2_LIBDIR)

.PHONY: all clean argon2 test

all: $(RUN)

$(RUN): $(RUN).so test

%.so: %.o
	@$(CC) -shared $(LIBDIR) -o $@ $<

%.o: %.c
	@$(CC) -c $(CFLAGS) -fPIC $(INCDIR) $< -o $@

test:
	@busted test.lua

clean:
	rm -f *.so *.o *.rock
