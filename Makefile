PWD = $(shell pwd)
NAME = argon2
LIBNAME = l$(NAME)

CC            ?= gcc
LUA_VERSION   ?= 5.1
LIBFLAG       ?= -shared
LUA_CFLAGS    ?= -O2 -Wall -Werror -fPIC
PREFIX        ?= /usr/local
LUA_INCDIR    ?= $(PREFIX)/include
LUA_LIBDIR    ?= $(PREFIX)/lib/lua/$(LUA_VERSION)
ARGON2_INCDIR ?= $(PWD)/$(NAME)/src
ARGON2_LIBDIR ?= $(PWD)/$(NAME)
BUILD_CFLAGS   = -I$(LUA_INCDIR) -I$(ARGON2_INCDIR)
BUILD_LDFLAGS  = -L$(LUA_LIBDIR) -L$(ARGON2_LIBDIR) -largon2

.PHONY: all install test clean $(NAME)

all: $(NAME) $(LIBNAME).so

$(NAME):
	$(MAKE) -C $(NAME)
	@rm -rf $(ARGON2_LIBDIR)/*.dylib*
	@rm -f $(ARGON2_LIBDIR)/*.so

$(LIBNAME).so: $(LIBNAME).o
	$(CC) $(LIBFLAG) -o $@ $< $(BUILD_LDFLAGS)

$(LIBNAME).o: $(LIBNAME).c
	$(CC) -c $(LUA_CFLAGS) $< -o $@ $(BUILD_CFLAGS)

install:
	cp $(LIBNAME).so $(INST_LIBDIR)
	cp $(NAME).lua $(INST_LUADIR)

test:
	@busted test.lua

clean:
	$(MAKE) -C $(NAME) clean
	rm -f *.so *.o
