NAME = argon2
LIBNAME = lib$(NAME)

CC = gcc
LUA ?= lua5.1
LIBFLAG ?= -shared
CFLAGS ?= -O2 -Wall -Werror
LUA_INC ?= $(shell pkg-config $(LUA) --cflags)
LUA_LIB ?= $(shell pkg-config $(LUA) --libs)
ARGON2_INC ?= -I/usr/local/include
ARGON2_LIB ?= -L/usr/local/lib -largon2

INC = $(LUA_INC) $(ARGON2_INC)
LIB = $(LUA_LIB) $(ARGON2_LIB)

.PHONY: all install test clean

all: $(LIBNAME).so

%.so: %.o
	$(CC) $(LIBFLAG) $(LIB) -o $@ $<

%.o: %.c
	@echo $(ARGON2_INC)
	$(CC) -c $(CFLAGS) -fPIC $(INC) $< -o $@

install:
	cp $(LIBNAME).so $(INST_LIBDIR)
	cp $(NAME).lua $(INST_LUADIR)

test:
	@busted test.lua

clean:
	rm -f *.so *.o
