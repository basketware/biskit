.DEFAULT_GOAL := build

NAME = template
RDNN = io.github.basketware.$(NAME)

TARGET ?= native
CC ?= gcc
OUT = out/$(TARGET)
OUTPUT = $(OUT)/$(NAME)$(EXTENSION)

# Correctly create the output directory during the build, not at parsing
$(OUTPUT): | $(OUT)

PKG_CONFIG ?= pkg-config
LDFLAGS ?= -l:libbasket.a $(shell $(PKG_CONFIG) --libs sdl2)

# Add the path to the basket library
CFLAGS += -L$(OUT)/basket

ifndef IGNORE_LIBM
	LDFLAGS += -lm
endif

SOURCES := $(wildcard src/*.c)
OBJECTS := $(patsubst src/%.c,$(OUT)/%.o,$(SOURCES))

build: build-basket $(OUTPUT)

mingw64:
	make build \
	    CC=x86_64-w64-mingw32-gcc \
		PKG_CONFIG=x86_64-w64-mingw32-pkg-config \
		IGNORE_LIBM=1 \
		TARGET=windows-x86_64 \

run: build
	@BASKET_TEMPLATE_PACKAGE=package ./$(OUTPUT)

# WARNING, ONLY WORKS IN LINURGTS
PREFIX ?= /usr
SHARE = $(PREFIX)/share/$(RDNN)

install: build
	# ONLY VALID FOR LINUX!

	@mkdir -p $(PREFIX)/bin
	@mkdir -p $(SHARE)/
	@install -D $(OUTPUT) $(SHARE)/game
	@ln -s $(SHARE)/game $(PREFIX)/bin/$(RDNN)

	@install -D platform/game.desktop $(PREFIX)/share/applications/$(RDNN).desktop
	@install -D platform/game.svg $(PREFIX)/share/icons/$(RDNN).svg

$(OUTPUT): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(CFLAGS) $(LDFLAGS)

$(OUT)/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

# Build the basket library
build-basket:
	make -C basket static \
		CC=$(CC) \
	    OUT=$(abspath $(OUT)/basket) \
		IGNORE_LIBM=1 \
		TARGET=$(TARGET) \

# Ensure the output directory exists
$(OUT):
	@mkdir -p $(OUT)

clean:
	rm -rf $(OUT)
